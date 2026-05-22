from ..models import Task
from django.db import transaction
from ..selectors import get_task_byid
from django.contrib.auth.models import User

# from django.shortcuts import get_object_or_404

@transaction.atomic
def create_task(
    *,
    created_by: User,
    title: str,
    description: str,
    priority: str,
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
        priority=priority,
        status=status,
        assigned_to=assigned_to,
        due_date=due_date,
        project=project,
        is_deleted=False,
    )

    if tags:
        task.tags.set(tags)

    return task

@transaction.atomic
def delete_task(*, task_id: int) -> bool:
    task = get_task_byid(task_id=task_id)

    task.delete()
    return True


@transaction.atomic
def update_task(*, task_id: int, **data):
    task = get_task_byid(task_id=task_id)

    tags = data.pop("tags", None)

    for field, value in data.items():
        setattr(task, field, value)

    task.save()

    if tags is not None:
        task.tags.set(tags)

    return task
