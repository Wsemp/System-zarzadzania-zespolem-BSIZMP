from django.contrib.auth import get_user_model

User = get_user_model()

def get_all_users():
    return User.objects.all()

def get_user_by_id(user_id: int) -> User | None:
    return User.objects.filter(id=user_id).first()


def get_user_by_email(email: str):
    return User.objects.filter(email=email).first()
