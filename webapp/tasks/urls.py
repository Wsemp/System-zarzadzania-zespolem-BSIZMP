from django.urls import path
from .views import show_tasks

urlpatterns = [
    path('tasks/', show_tasks, name='tasks_view'),
]