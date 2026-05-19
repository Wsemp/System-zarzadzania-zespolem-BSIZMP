from django.urls import path
from .views import show_projects

urlpatterns = [
    path('', show_projects, name='projects_view'),
    # path('create/', create_task_view, name='create_task'),
    # path('delete/<int:task_id>/', delete_task_view, name='delete_task'),
    # path('update/<int:task_id>/', update_task_view, name='update_task'),
]
