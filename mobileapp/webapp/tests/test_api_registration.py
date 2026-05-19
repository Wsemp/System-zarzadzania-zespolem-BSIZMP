from django.test import TestCase
from rest_framework.test import APIClient

class TestApiRegistration(TestCase):

    def setUp(self):
        self.client = APIClient()

        self.url_register = "/api/auth/register/"
        self.url_login = "/api/auth/login/"


    def test_registration_API(self):

        data = {
            "username": "dummy",
            "email": "dummyuser@gmail.com",
            "password": "dummy"
        }

        response = self.client.post(
            self.url_register,
            data,
            format="json"
        )

        self.assertEqual(response.status_code, 201)
        self.assertIn("access", response.json())
        self.assertIn("refresh", response.json())


    def test_login_API(self):

        data = {
            "username": "dummy",
            "email": "dummyuser@gmail.com",
            "password": "dummy"
        }

        response = self.client.post(
            self.url_register,
            data,
            format="json"
        )

        self.assertEqual(response.status_code, 201)
        self.assertIn("access", response.json())
        self.assertIn("refresh", response.json())


        data = {
            "username": "dummy",
            "password": "dummy"
        }

        response = self.client.post(
            self.url_login,
            data,
            format="json"
        )

        self.assertEqual(response.status_code, 200)
        self.assertIn("access", response.json())
        self.assertIn("refresh", response.json())
