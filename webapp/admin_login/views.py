from django.contrib.auth import authenticate, login
from django.shortcuts import render, redirect
from django.contrib.auth.views import LoginView


class AdminLoginView(LoginView):
    template_name = "admin_login/login.html"
    success_url = "/"  # fallback
    redirect_authenticated_user = True

    def form_valid(self, form):
        user = form.get_user()

        if not user.is_staff:
            form.add_error(None, "User is not admin!")
            return self.form_invalid(form)

        return super().form_valid(form)
