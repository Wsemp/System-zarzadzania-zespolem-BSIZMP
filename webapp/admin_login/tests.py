from django.test import TestCase, Client
from django.contrib.auth.models import User


class LoginViewTest(TestCase):

    def setUp(self):
        self.client = Client()
        self.url = "/login/"

        self.admin_user = User.objects.create_user(
            username="admin",
            password="admin123",
            is_staff=True
        )

        self.normal_user = User.objects.create_user(
            username="user",
            password="user123",
            is_staff=False
        )

    def test_get_request(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'admin_login/login.html')

    def test_redirect_if_authenticated(self):
        self.client.login(username="admin", password="admin123")
        response = self.client.get(self.url)
        self.assertRedirects(response, "/")

    def test_valid_admin_login(self):
        response = self.client.post(self.url, {
            "username": "admin",
            "password": "admin123"
        })

        self.assertRedirects(response, "/")

    def test_valid_admin_login_with_next(self):
        response = self.client.post(self.url + "?next=/", {
            "username": "admin",
            "password": "admin123"
        })

        self.assertRedirects(response, "/")

    def test_non_admin_user(self):
        response = self.client.post(self.url, {
            "username": "user",
            "password": "user123"
        })

        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "User is not admin!")

    def test_invalid_credentials(self):
        response = self.client.post(self.url, {
            "username": "wrong",
            "password": "wrong"
        })

        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Please enter a correct username and password")
