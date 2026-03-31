from django.urls import path
from .views import show_users, create_user_view, delete_user_view

urlpatterns = [
    path('', show_users, name='users_view'),
    path('create/', create_user_view, name='user_create'),
    path("delete/<int:user_id>/", delete_user_view, name="delete_user"),
]
