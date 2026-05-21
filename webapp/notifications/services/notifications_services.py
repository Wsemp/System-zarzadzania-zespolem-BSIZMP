from django.db import transaction
from ..models import Notification
from ..selectors import get_notification_byid
from django.contrib.auth.models import User

@transaction.atomic
def create_notification(**kwargs) -> Notification:
    return Notification.objects.create(**kwargs)

@transaction.atomic
def update_notification(notification_id: int):
    notification = get_notification_byid(notification_id=notification_id)
    notification.is_read = True
    notification.save()
