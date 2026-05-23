from django.test import TestCase
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError


User = get_user_model()


class PasswordValidatorTests(TestCase):

    def setUp(self):
        self.user = User.objects.create(
            username="john",
            email="john@test.com",
            first_name="John",
            last_name="Doe"
        )

    # -------------------------
    #   HAPPY PATH
    # -------------------------
    def test_valid_password(self):
        try:
            validate_password("StrongPass1!", user=self.user)
        except ValidationError:
            self.fail("Valid password raised ValidationError")

    # -------------------------
    # BUILT-IN VALIDATORS
    # -------------------------

    def test_too_short_password(self):
        with self.assertRaises(ValidationError):
            validate_password("Aa1!", user=self.user)

    def test_common_password(self):
        with self.assertRaises(ValidationError):
            validate_password("password", user=self.user)

    def test_numeric_password(self):
        with self.assertRaises(ValidationError):
            validate_password("12345678", user=self.user)

    def test_similar_to_username(self):
        with self.assertRaises(ValidationError):
            validate_password("john12345A!", user=self.user)

    def test_similar_to_email(self):
        with self.assertRaises(ValidationError):
            validate_password("john@test123A!", user=self.user)

    # -------------------------
    # CUSTOM VALIDATORS
    # -------------------------

    def test_missing_uppercase(self):
        with self.assertRaises(ValidationError):
            validate_password("strongpass1!", user=self.user)

    def test_missing_lowercase(self):
        with self.assertRaises(ValidationError):
            validate_password("STRONGPASS1!", user=self.user)

    def test_missing_digit(self):
        with self.assertRaises(ValidationError):
            validate_password("StrongPass!", user=self.user)

    def test_missing_special_char(self):
        with self.assertRaises(ValidationError):
            validate_password("StrongPass1", user=self.user)

    def test_whitespace_not_allowed(self):
        with self.assertRaises(ValidationError):
            validate_password("Strong Pass1!", user=self.user)

    def test_repeated_characters(self):
        with self.assertRaises(ValidationError):
            validate_password("Stronnnnng1!", user=self.user)

    # -------------------------
    # MULTI FAILURE TEST
    # -------------------------

    def test_multiple_failures(self):
        with self.assertRaises(ValidationError) as ctx:
            validate_password("123", user=self.user)

        self.assertTrue(len(ctx.exception.messages) > 0)
