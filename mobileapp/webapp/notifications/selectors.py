from .models import Notification
from django.shortcuts import get_object_or_404

def get_notification_byid(notification_id: int) -> Notification:
    return get_object_or_404(Notification, pk=notification_id)
