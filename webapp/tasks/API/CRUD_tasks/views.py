from ...selectors import get_tasks
from rest_framework import viewsets
from .serializers import TaskSerializer
from rest_framework.permissions import IsAuthenticated
from notifications.services.notifications_services import create_notification
from notifications.models import Notification


class TaskViewSet(viewsets.ModelViewSet):
    queryset = get_tasks()
    serializer_class = TaskSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        task = serializer.save()
        if task.assigned_to and task.assigned_to != self.request.user:
            create_notification(
                recipient=task.assigned_to,
                notification_type=Notification.Type.TASK_ASSIGNED,
                message=f'Przypisano Ci nowe zadanie: {task.title}',
                task=task,
                project=task.project if hasattr(task, 'project') else None,
            )

    def perform_update(self, serializer):
        old_status = serializer.instance.status
        old_assigned = serializer.instance.assigned_to
        task = serializer.save()

        # Notification on new assignee
        if task.assigned_to and task.assigned_to != old_assigned and task.assigned_to != self.request.user:
            create_notification(
                recipient=task.assigned_to,
                notification_type=Notification.Type.TASK_ASSIGNED,
                message=f'Przypisano Ci nowe zadanie: {task.title}',
                task=task,
                project=task.project if hasattr(task, 'project') else None,
            )

        # Notification on status change to the original assignee
        if task.status != old_status and task.assigned_to and task.assigned_to != self.request.user:
            create_notification(
                recipient=task.assigned_to,
                notification_type=Notification.Type.STATUS_CHANGED,
                message=f'Zmieniono status zadania "{task.title}" na: {task.status}',
                task=task,
                project=task.project if hasattr(task, 'project') else None,
            )
