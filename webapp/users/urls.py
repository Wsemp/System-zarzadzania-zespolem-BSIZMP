from django.urls import path
from .views import show_users, create_user_view

urlpatterns = [
    path('', show_users, name='users_view'),
    path('create/', create_user_view, name='user_create'),
]
