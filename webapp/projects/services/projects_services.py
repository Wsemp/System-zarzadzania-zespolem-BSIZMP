from django.db import transaction

from projects.models import Project


@transaction.atomic
def create_project(**kwargs) -> Project:
    return Project.objects.create(**kwargs)


@transaction.atomic
def update_project(project: Project, **kwargs) -> Project:
    for attr, value in kwargs.items():
        setattr(project, attr, value)
    project.save()
    return project
