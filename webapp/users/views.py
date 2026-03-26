from django.shortcuts import render
from django.contrib.auth.decorators import login_required


@login_required
def view_users(request):
    print(request)
    return render(request, 'users/users.html')
