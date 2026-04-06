from .models import Task

def get_tasks():
    return Task.objects.all()