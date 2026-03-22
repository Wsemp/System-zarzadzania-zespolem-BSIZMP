from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('login/', include('admin_login.urls')),
    path('', include('main_page.urls')),
]
