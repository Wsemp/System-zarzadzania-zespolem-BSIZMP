from django.db import models


class Tag(models.Model):
    name = models.CharField(max_length=50, unique=True)

    def __str__(self):
        return self.name


class Task(models.Model):

    class Status(models.TextChoices):
        TODO = 'todo', 'To do'
        IN_PROGRESS = 'In progress', 'In progress'
        DONE = 'done', 'Done'

    class Priority(models.TextChoices):
        LOW = 'low', 'Low'
        MEDIUM = 'medium', 'Medium'
        HIGH = 'high', 'High'

    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)

    status = models.CharField(max_length=20, choices=Status.choices)

    priority = models.CharField(max_length=20, choices=Priority.choices, default=Priority.LOW)

    assigned_to = models.ForeignKey(
        "auth.User",
        on_delete=models.SET_NULL,
        null=True,
        related_name="assigned_tasks"
    )

    created_by = models.ForeignKey(
        "auth.User",
        on_delete=models.CASCADE,
        related_name="created_tasks"
    )

    tags = models.ManyToManyField(Tag, blank=True)

    due_date = models.DateTimeField(null=True, blank=True)

    is_deleted = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    project = models.ForeignKey(
        "projects.Project",
        on_delete=models.CASCADE,
        related_name="tasks",
    )

    @property
    def overdue(self):
        from django.utils import timezone
        return (
                self.due_date is not None
                and self.due_date < timezone.now()
                and self.status != self.Status.DONE
        )

    @property
    def done(self):
        return self.status == self.Status.DONE

    def __str__(self):
        return self.title
