from django.urls import path
from .views import GlobalLogoutView, LogoutView

urlpatterns = [
    path('', LogoutView.as_view()),
    path('all/', GlobalLogoutView.as_view(), name="logout_all"),
]
