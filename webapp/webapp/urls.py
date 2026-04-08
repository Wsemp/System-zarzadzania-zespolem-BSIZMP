from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView


urlpatterns = [
    path('admin/', admin.site.urls),
    path('login/', include('admin_login.urls')),
    path('', include('main_page.urls')),
    path('users/', include('users.urls')),
    path('tasks/', include('tasks.urls')),
    path("api/users", include("users.API.CRUD_users.urls")),
    path("api/tasks", include("tasks.API.CRUD_tasks.urls")),
    path("api/auth/", include("users.API.register_users.urls")),
    path('api/token', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh', TokenRefreshView.as_view(), name='token_refresh'),
]
