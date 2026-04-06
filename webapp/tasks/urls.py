from django.urls import path
from .views import show_tasks, create_task_view

urlpatterns = [
    path('', show_tasks, name='tasks_view'),
    path('create/', create_task_view, name='create_task'),
]