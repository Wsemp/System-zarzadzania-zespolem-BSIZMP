from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from .selectors import get_tasks
from .forms import TaskForm
from django.http import HttpResponseNotAllowed, HttpResponseForbidden, HttpResponseNotFound
from .services.task_services import create_task

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
            print(form.cleaned_data)
            create_task(created_by=logged_user, **form.cleaned_data)
            return redirect("/tasks/")
    else:
        form = TaskForm()

    return render(request, "tasks/create_task.html", context={"form": form})
