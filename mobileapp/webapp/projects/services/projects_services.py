from django.db import transaction

from projects.models import Project


@transaction.atomic
def create_project(**kwargs) -> Project:
    return Project.objects.create(**kwargs)

