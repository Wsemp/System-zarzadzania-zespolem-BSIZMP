from .models import Task
# from django.http import Http404
from django.shortcuts import get_object_or_404

def get_tasks():
    return Task.objects.all()

def get_task_byid(task_id: int) -> Task | None:
    task = get_object_or_404(Task, id=task_id)
    return task
