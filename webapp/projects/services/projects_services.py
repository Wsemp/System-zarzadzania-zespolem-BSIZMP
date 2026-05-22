from django.db import transaction

from projects.models import Project


@transaction.atomic
def create_project(**kwargs) -> Project:
    # wyciągnij members z kwargs, jeśli są podane
    members = kwargs.pop('members', None)
    project = Project.objects.create(**kwargs)
    if members:
        project.members.set(members)
    owner = kwargs.get('owner')  # jeśli owner był przekazany w kwargs
    if owner:
        project.members.add(owner)
    return project


@transaction.atomic
def update_project(project: Project, **kwargs) -> Project:

    members = kwargs.pop('members', None)

    for attr, value in kwargs.items():
        setattr(project, attr, value)
    project.save()

    if members is not None:
        project.members.set(members)

    return project
