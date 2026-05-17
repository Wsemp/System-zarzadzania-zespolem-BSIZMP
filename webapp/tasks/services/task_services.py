from ..models import Task
from django.db import transaction
from ..selectors import get_task_byid
from django.contrib.auth.models import User
from notifications.models import Notification
# from datetime import datetime
# from django.shortcuts import get_object_or_404

@transaction.atomic
def create_task(
    *,
    created_by: User,
    title: str,
    description: str,
    status: str,
    assigned_to,
    tags=None,
    due_date,
    project
) -> Task:

    if assigned_to and not project.members.filter(id=assigned_to.id).exists():
        raise ValueError("User not in project")

    task = Task.objects.create(
        created_by=created_by,
        title=title,
        description=description,
        status=status,
        assigned_to=assigned_to,
        due_date=due_date,
        project=project,
        is_deleted=False,
    )

    if tags:
        task.tags.set(tags)

    # assigment notification

    Notification.objects.create(
        recipient=assigned_to,
        task=task,
        type=Notification.Type.TASK_ASSIGNED,
        message=f"You were assigned to task '{task.title}'"
    )

    return task

@transaction.atomic
def delete_task(*, task_id: int) -> bool:
    task = get_task_byid(task_id=task_id)

    task.delete()
    return True


@transaction.atomic
def update_task(*, task_id: int, **data):
    task = get_task_byid(task_id=task_id)

    old_assigned_to = task.assigned_to
    old_status = task.status

    tags = data.pop("tags", None)

    for field, value in data.items():
        setattr(task, field, value)

    task.save()

    if tags is not None:
        task.tags.set(tags)

    # assigment notification

    if (
            old_assigned_to != task.assigned_to
            and task.assigned_to is not None
    ):
        Notification.objects.create(
            recipient=task.assigned_to,
            task=task,
            type=Notification.Type.TASK_ASSIGNED,
            message=f"You were assigned to task '{task.title}'"
        )

    # completed notification

    if (
            old_status != task.status
            and task.status == Task.Status.DONE
    ):
        Notification.objects.create(
            recipient=task.created_by,
            task=task,
            type=Notification.Type.TASK_COMPLETED,
            message=f"Task '{task.title}' was completed"
        )

    return task
