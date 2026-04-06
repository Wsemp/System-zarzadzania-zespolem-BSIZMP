from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from .selectors import get_tasks, get_task_byid
from .forms import TaskForm
from django.http import HttpResponseNotAllowed, HttpResponseForbidden, HttpResponseNotFound
from .services.task_services import create_task, delete_task

# show tasks

@login_required
def show_tasks(request):
    tasks = get_tasks()
    return render(request, "tasks/tasks.html", {"tasks": tasks})

# create task

@login_required
def create_task_view(request):

    if not request.user.is_staff:
        return HttpResponseForbidden()

    if request.method == "POST":

        form = TaskForm(request.POST)

        if form.is_valid():
            logged_user = request.user
            # print(form.cleaned_data)
            create_task(created_by=logged_user, **form.cleaned_data)
            return redirect("/tasks/")
    else:
        form = TaskForm()

    return render(request, "tasks/create_task.html", context={"form": form})

@login_required
def delete_task_view(request, task_id):

    if not request.user.is_staff:
        return HttpResponseForbidden()

    if request.method == "POST":
        success = delete_task(task_id=task_id)
        if success:
            return redirect("/tasks/")

    task = get_task_byid(task_id=task_id)
    return render(request, "tasks/delete_task.html", context={"task": task})
