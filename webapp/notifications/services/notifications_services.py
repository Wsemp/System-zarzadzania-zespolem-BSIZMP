from django.db import transaction
from ..models import Notification


@transaction.atomic
def create_notification(recipient, notification_type, message, task=None, project=None):
    return Notification.objects.create(
        recipient=recipient,
        type=notification_type,
        message=message,
        task=task,
        project=project,
    )
