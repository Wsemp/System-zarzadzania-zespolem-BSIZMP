from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.contrib.auth import get_user_model

User = get_user_model()


@receiver(post_save, sender=User)
def user_created_handler(sender, instance, created, **kwargs):
    if created:
        pass
        # print(f"User created: {instance.username}")


@receiver(post_delete, sender=User)
def user_deleted_handler(sender, instance, **kwargs):
    pass
    # print(f"User deleted: {instance.username}")
