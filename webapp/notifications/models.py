from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()


class Notification(models.Model):

    class Type(models.TextChoices):
        TASK_ASSIGNED = "task_assigned", "Task assigned"
        TASK_UPDATED = "task_updated", "Task updated"
        TASK_COMPLETED = "task_completed", "Task completed"
        TASK_OVERDUE = "task_overdue", "Task overdue"
        COMMENT_ADDED = "comment_added", "Comment added"
        STATUS_CHANGED = "status_changed", "Status changed"
        INVITATION_SENT = "invitation_sent", "Invitation sent"
        PROJECT_JOINED = "project_joined", "Project joined"

    recipient = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="notifications"
    )

    task = models.ForeignKey(
        "tasks.Task",
        on_delete=models.SET_NULL,
        related_name="notifications",
        null=True,
        blank=True,
    )

    project = models.ForeignKey(
        "projects.Project",
        on_delete=models.SET_NULL,
        related_name="notifications",
        null=True,
        blank=True,
    )

    type = models.CharField(
        max_length=50,
        choices=Type.choices
    )

    message = models.TextField()

    is_read = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)

    read_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        task_info = self.task.title if self.task else "no task"
        return f"{self.recipient} - {self.type} - ({task_info})"
