from ..models import Task
from django.db import transaction

@transaction.atomic
def create_task(
    *,
    created_by,
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