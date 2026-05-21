from django.urls import path
from .views import show_projects, show_projects_members, create_project, create_project_view, update_project_view

urlpatterns = [
    path('', show_projects, name='projects_view'),
    path('members/<int:project_id>/', show_projects_members, name='projects_members_view'),
    path('create/', create_project_view, name='create_project'),
    # path('delete/<int:task_id>/', delete_task_view, name='delete_task'),
    path('update/<int:project_id>/', update_project_view, name='update_project'),
]
