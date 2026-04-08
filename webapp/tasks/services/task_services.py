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
    status: str,
    assigned_to,
    tags,
    due_date
) -> Task:

    task = Task.objects.create(
        created_by=created_by,
        title=title,
        description=description,
        status=status,
        assigned_to=assigned_to,
        # tags=None,
        due_date=due_date,
        is_deleted=False,
    )

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
"""
@transaction.atomic
def update_user(*, user_id: int, **data) -> User | None:
    user = User.objects.filter(id=user_id).first()
    if not user:
        return None

    if "password" in data:
        user.set_password(data.pop("password"))

    for field, value in data.items():
        setattr(user, field, value)

    user.save()
    return user


@transaction.atomic
def delete_user(*, user_id: int) -> bool:
    user = User.objects.filter(id=user_id).first()
    if not user:
        return False

    user.delete()
    return True
"""