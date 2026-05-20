from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from .selectors import get_all_users
from .services.user_service import create_user, update_user, delete_user
from .forms import UserCreateForm, UserUpdateForm
from django.contrib.auth import get_user_model
from django.http import HttpResponseNotAllowed, HttpResponseForbidden, HttpResponseNotFound

User = get_user_model()

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
    if not request.user.is_staff:
        return HttpResponseForbidden()
    if request.method == "POST":
        form = UserCreateForm(request.POST)
        if form.is_valid():
            data = form.cleaned_data.copy()
            data.pop("password2", None)
            create_user(**data)
            return redirect("/users/")
    else:
        form = UserCreateForm()

    return render(request, "users/create_user.html", {"form": form})

@login_required
def delete_user_view(request, user_id):
    if not request.user.is_staff:
        return HttpResponseForbidden()

    if request.user.id == user_id:
        return HttpResponseForbidden("Nie możesz usunąć samego siebie")

    if request.method == "GET":
        user = get_object_or_404(User, id=user_id)
        return render(request, "users/delete_user.html", {"user": user})

    if request.method == "POST":

        success = delete_user(user_id=user_id)

        if not success:
            return HttpResponseNotFound()

    return redirect("users_view")

@login_required
def update_user_view(request, user_id):
    if not request.user.is_staff:
        return HttpResponseForbidden("Tylko administrator może edytować użytkowników.")

    user = get_object_or_404(User, id=user_id)

    if request.method == "POST":
        form = UserUpdateForm(request.POST, instance=user)
        if form.is_valid():

            data = form.cleaned_data
            update_user(user_id=user.id, **data)
            return redirect("users_view")
    else:
        form = UserUpdateForm(instance=user)
    return render(request, "users/update_user.html", {"form": form, "user": user})
