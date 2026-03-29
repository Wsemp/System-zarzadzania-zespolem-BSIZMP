from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from .selectors import get_all_users
from .services.user_service import create_user, update_user, delete_user
from .forms import UserCreateForm

@login_required
def show_users(request):

    # fetch data from db via ORM

    users = get_all_users()
    users_count = users.count()
    admin_users_count = users.filter(is_staff=True).count()
    common_users_count = users_count - admin_users_count

    return render(request, "users/users.html", {
        "users": users,
        "users_count": users_count,
        "common_users_count": common_users_count,
        "admin_users_count": admin_users_count
    })

@login_required
def create_user_view(request):
    if request.method == "POST":
        form = UserCreateForm(request.POST)
        if form.is_valid():
            create_user(**form.cleaned_data)
            return redirect("/")
    else:
        form = UserCreateForm()

    return render(request, "users/create_user.html", {"form": form})
