from django.urls import path
from .views import show_users, create_user_view, delete_user_view, update_user_view

urlpatterns = [
    path('', show_users, name='users_view'),
    path('create/', create_user_view, name='user_create'),
    path('update/<int:user_id>/', update_user_view, name='user_update'),
    path("delete/<int:user_id>/", delete_user_view, name="delete_user"),
]
