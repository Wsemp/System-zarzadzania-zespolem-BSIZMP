from django.contrib.auth import get_user_model
from django.db import transaction
from ..selectors import get_user_by_id

User = get_user_model()


@transaction.atomic
def create_user(*, username: str, email: str, is_staff:str, password: str) -> User:
    user = User.objects.create_user(
        username=username,
        email=email,
        is_staff=is_staff,
        password=password
    )
    return user


@transaction.atomic
def update_user(*, user: User, **data) -> User | None:

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
