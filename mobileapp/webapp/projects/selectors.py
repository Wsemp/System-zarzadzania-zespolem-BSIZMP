from .apps import ProjectsConfig
from .models import Project
from django.shortcuts import get_object_or_404

def get_projects():
    return Project.objects.all()

def get_project(project_id: int) -> Project | None:
    project = get_object_or_404(Project, id=project_id)
    return project