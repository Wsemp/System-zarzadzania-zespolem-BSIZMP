from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.http import HttpResponseNotAllowed, HttpResponseForbidden, HttpResponseNotFound
from .selectors import get_projects, get_project
from .forms import ProjectForm
from .services.projects_services import create_project, update_project

# show tasks

@login_required
def show_projects(request):
    projects = get_projects()
    return render(request, "projects/projects.html", {"projects": projects})

@login_required
def create_project_view(request):
    if not request.user.is_staff:
        return HttpResponseForbidden()

    if request.method == "POST":
        form = ProjectForm(request.POST)
        if form.is_valid():
            create_project(**form.cleaned_data)
            return redirect('projects_view')
    else:
        form = ProjectForm()

    return render(request, "projects/create_project.html", {"form": form})

@login_required
def update_project_view(request, project_id: int):
    if not request.user.is_staff:
        return HttpResponseForbidden()

    project = get_project(project_id)

    if request.method == "POST":
        form = ProjectForm(request.POST, instance=project)
        if form.is_valid():
            update_project(project, **form.cleaned_data)
            return redirect('projects_view')
    else:
        form = ProjectForm(instance=project)

    return render(request, "projects/create_project.html", {"form": form})

@login_required
def show_projects_members(request, project_id: int):
    project = get_project(project_id)
    return render(request, "projects/project_members.html", {"project": project})
