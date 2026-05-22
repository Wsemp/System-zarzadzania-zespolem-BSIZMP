from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from django.views.generic import TemplateView


urlpatterns = [
    path('admin/', admin.site.urls),
    path('login/', include('admin_login.urls')),
    path('', include('main_page.urls')),
    path('users/', include('users.urls')),
    path('tasks/', include('tasks.urls')),
    path('projects/', include('projects.urls')),
    path("api/users", include("users.API.CRUD_users.urls")),
    path("api/users/logout/", include("users.API.logout_users.urls")),
    path("api/tasks", include("tasks.API.CRUD_tasks.urls")),
    path("api/projects", include("projects.API.CRUD_projects.urls")),
    path("api/invitations", include("invitations.API.CRUD_invitations.urls")),
    path("api/notifications", include("notifications.API.CRUD_notifications.urls")),
    path("api/", include("users.API.password_reset.urls")),
    path("api/auth/", include("users.API.register_users.urls")),
    path('api/token', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/docs/', TemplateView.as_view(template_name='apidocs/index.html'), name='api-docs'),
]
