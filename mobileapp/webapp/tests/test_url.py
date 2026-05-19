from django.contrib.auth import get_user_model
from django.test import TestCase, Client
from django.utils import timezone

User = get_user_model()

class URLTests(TestCase):

    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user(
            username="test",
            password="123",
            is_staff=True
        )

    def test_authenticated_urls(self):
        self.client.login(username="test", password="123")

        dummy_user = User.objects.create_user(
            username="dummy",
            password="dummy"
        )

        urls = [
            "/",
            "/users/",
            "/users/create/",
            f"/users/delete/{dummy_user.id}/",
            f"/users/update/{dummy_user.id}/",
        ]

        for url in urls:
            response = self.client.get(url)
            # print(response, url)
            self.assertEqual(response.status_code, 200)


    def test_get_api_urls(self):
        self.client.login(username="test", password="123")

        urls = [
            "/api/users/",
            "/api/users/1/",
        ]

        for url in urls:
            response = self.client.get(url)
            self.assertEqual(response.status_code, 200)

    def test_token_flow(self):

        url = "/api/token"

        data = {
            "username": "test",
            "password": "123"
        }

        # get refresh/access token

        response = self.client.post(url, data)
        self.assertEqual(response.status_code, 200)
        json_data = response.json()
        refresh_token = json_data.get("refresh")

        # refresh access token

        refresh_url = "/api/token/refresh"

        refresh_response = self.client.post(refresh_url, {"refresh": refresh_token})
        self.assertEqual(refresh_response.status_code, 200)
        new_access = refresh_response.json().get("access")


    def test_public_urls(self):

        url = "/login/"

        response = self.client.get(url)
        self.assertIn(response.status_code, [200, 302])
