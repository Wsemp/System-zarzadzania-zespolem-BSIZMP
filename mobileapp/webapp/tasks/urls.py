from django.urls import path
from . import views

urlpatterns = [
    path('', views.show_tasks, name='tasks_view'),
    path('create/', views.create_task_view, name='create_task'),
    path('delete/<int:task_id>/', views.delete_task_view, name='delete_task'),
    path('update/<int:task_id>/', views.update_task_view, name='update_task'),

    path('sort-by-due-date/', views.tasks_sort_by_due_date, name="tasks-sort-by-due-date")
]
