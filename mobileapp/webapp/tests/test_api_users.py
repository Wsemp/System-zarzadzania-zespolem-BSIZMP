from django.contrib.auth import get_user_model
from django.test import TestCase
from rest_framework.test import APIClient

User = get_user_model()

class TestsApiUsers(TestCase):

    def setUp(self):
        self.client = APIClient()

        self.token_url = "/api/token"
        self.users_url = "/api/users/"

        self.admin_password = "admin"
        self.user_password = "user"

        self.admin = User.objects.create_user(
            username="admin",
            password=self.admin_password,
            is_staff=True
        )

        self.user = User.objects.create_user(
            username="user",
            password=self.user_password,
            is_staff=False
        )

    # ---------- helpers ---------- #

    def get_token(self, username, password):
        response = self.client.post(self.token_url, {
            "username": username,
            "password": password
        })
        self.assertEqual(response.status_code, 200)
        return response.data["access"]

    def auth_headers(self, token):
        return {"HTTP_AUTHORIZATION": f"Bearer {token}"}

    def create_user_api(self, token, **overrides):
        data = {
            "username": "trainer",
            "email": "trainer@gmail.com",
            "password": "test2",
            "is_staff": False
        }
        data.update(overrides)

        return self.client.post(
            self.users_url,
            data,
            **self.auth_headers(token)
        )

    # ---------- tests ---------- #

    def test_create_user_forbidden_for_non_admin(self):
        token = self.get_token(self.user.username, self.user_password)

        response = self.create_user_api(token)

        self.assertEqual(response.status_code, 403)

    def test_delete_user(self):
        token = self.get_token(self.admin.username, self.admin_password)

        response = self.create_user_api(token)
        self.assertEqual(response.status_code, 201)

        user_id = response.data["id"]

        response = self.client.delete(
            f"{self.users_url}{user_id}/",
            **self.auth_headers(token)
        )

        self.assertEqual(response.status_code, 204)

    def test_update_user(self):
        token = self.get_token(self.admin.username, self.admin_password)

        response = self.create_user_api(token)
        self.assertEqual(response.status_code, 201)

        user_id = response.data["id"]

        response = self.client.patch(
            f"{self.users_url}{user_id}/",
            {
                "username": "trainer1",
                "email": "trainer1@gmail.com",
                "password": "trainer1"
            },
            **self.auth_headers(token)
        )

        self.assertEqual(response.status_code, 200)
