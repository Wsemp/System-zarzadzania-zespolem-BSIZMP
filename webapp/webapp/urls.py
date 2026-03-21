from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('admin_login.urls')),
    path('main/', include('main_page.urls')),
]
