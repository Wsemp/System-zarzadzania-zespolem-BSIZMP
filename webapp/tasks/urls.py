from django.urls import path
from .views import show_tasks, create_task_view, delete_task_view, update_task_view

urlpatterns = [
    path('', show_tasks, name='tasks_view'),
    path('create/', create_task_view, name='create_task'),
    path('delete/<int:task_id>/', delete_task_view, name='delete_task'),
    path('update/<int:task_id>/', update_task_view, name='update_task'),
]