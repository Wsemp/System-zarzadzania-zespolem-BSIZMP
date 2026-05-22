from django.urls import path
from .views import show_tasks, create_task_view, delete_task_view, update_task_view, tasks_sort_by_due_date

urlpatterns = [
    path('', show_tasks, name='tasks_view'),
    path('create/', create_task_view, name='create_task'),
    path('delete/<int:task_id>/', delete_task_view, name='delete_task'),
    path('update/<int:task_id>/', update_task_view, name='update_task'),
    path('sort-by-due-date/', tasks_sort_by_due_date, name="tasks-sort-by-due-date")
]
