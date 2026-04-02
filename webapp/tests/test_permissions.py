from django.contrib.auth import get_user_model
from django.test import TestCase, Client
from rest_framework.test import APIClient

User = get_user_model()

class TestsProtectedUrl(TestCase):

    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username="test",
            password="123",
            is_staff=False
        )

    def test_API_CRUD_user_access(self):

        # Create user

        token_url = "/api/token"
        data = {
            "username": "test",
            "password": "123"
        }

        response = self.client.post(token_url, data)

        # Check if received access token

        self.assertEqual(response.status_code, 200)
        self.assertIn("access", response.json())
        access_token = response.json()["access"]


        protected_url = "/api/users/"
        response = self.client.post(
            protected_url,
            {
                "username": "trainer",
                "email": "trainer@gmail.com",
                "is_staff": False,
                "password": "test2"
            },
            HTTP_AUTHORIZATION=f"Bearer {access_token}"
        )

        self.assertEqual(response.status_code, 403)

        # Delete user

        protected_url = f"/api/users/{self.user.id}/"

        response = self.client.delete(
            protected_url,
            {},
            HTTP_AUTHORIZATION=f"Bearer {access_token}"
        )

        self.assertEqual(response.status_code, 403)


        # Update user

        protected_url = f"/api/users/{self.user.id}/"
        response = self.client.patch(
            protected_url,
            {
                "username": "trainer1",
                "email": "trainer1@gmail.com",
                "is_staff": False,
                "password": "trainer1"
            },
            HTTP_AUTHORIZATION=f"Bearer {access_token}"
        )

        self.assertEqual(response.status_code, 403)


    def test_API_CRUD_admin_access(self):

        self.user.is_staff=True
        self.user.save()

        # Get access token

        token_url = "/api/token"
        data = {
            "username": "test",
            "password": "123"
        }

        response = self.client.post(
            token_url,
            data,
            format="json"
        )

        # Check if received access token

        self.assertEqual(response.status_code, 200)
        self.assertIn("access", response.json())
        access_token = response.json()["access"]

        # Create user

        protected_url = "/api/users/"
        response = self.client.post(
            protected_url,
            {
                "username": "trainer",
                "email": "trainer@gmail.com",
                "is_staff": False,
                "password": "test2"
            },
            HTTP_AUTHORIZATION=f"Bearer {access_token}"
        )

        self.assertEqual(response.status_code, 201)
        self.assertTrue(User.objects.filter(username="trainer").exists())

        user_dummy = User.objects.get(username="trainer")

        # Update user

        protected_url = f"/api/users/{user_dummy.id}/"
        response = self.client.patch(
            protected_url,
            {
                "username": "trainer1",
                "email": "trainer1@gmail.com",
                "is_staff": False,
                "password": "trainer1"
            },
            format="json",
            HTTP_AUTHORIZATION=f"Bearer {access_token}"
        )

        self.assertEqual(response.status_code, 200)

        # Delete user

        protected_url = f"/api/users/{user_dummy.id}/"
        response = self.client.delete(
            protected_url,
            {},
            HTTP_AUTHORIZATION=f"Bearer {access_token}"
        )

        self.assertEqual(response.status_code, 204)


    def test_registration_API(self):

        url = "/api/auth/register/"

        data = {
            "username": "dummy",
            "email": "dummyuser@gmail.com",
            "password": "dummy"
        }

        response = self.client.post(
            url,
            data,
            format="json"
        )

        self.assertEqual(response.status_code, 201)
        self.assertIn("access", response.json())
        self.assertIn("refresh", response.json())

    def test_login_API(self):

        url_register = "/api/auth/register/"

        data = {
            "username": "dummy",
            "email": "dummyuser@gmail.com",
            "password": "dummy"
        }

        response = self.client.post(
            url_register,
            data,
            format="json"
        )

        self.assertEqual(response.status_code, 201)
        self.assertIn("access", response.json())
        self.assertIn("refresh", response.json())

        url_login = "/api/auth/login/"

        data = {
            "username": "dummy",
            "password": "dummy"
        }

        response = self.client.post(
            url_login,
            data,
            format="json"
        )

        self.assertEqual(response.status_code, 200)
        self.assertIn("access", response.json())
        self.assertIn("refresh", response.json())
