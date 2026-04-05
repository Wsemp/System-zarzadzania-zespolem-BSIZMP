from django.shortcuts import render
from django.contrib.auth.decorators import login_required

@login_required
def show_tasks(self, request):
    return render(request, "tasks/tasks.html")
