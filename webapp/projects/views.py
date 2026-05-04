from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.http import HttpResponseNotAllowed, HttpResponseForbidden, HttpResponseNotFound
from .selectors import get_projects, get_project

# show tasks

@login_required
def show_projects(request):
    projects = get_projects()
    return render(request, "projects/projects.html", {"projects": projects})
