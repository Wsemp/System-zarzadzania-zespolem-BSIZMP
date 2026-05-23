from django.core.exceptions import ValidationError
from django.utils.translation import gettext as _
import re

class UppercaseValidator:
    def validate(self, password, user=None):
        if not re.search(r'[A-Z]', password):
            raise ValidationError(
                _("Hasło musi zawierać co najmniej jedną wielką literę."),
                code='no_uppercase'
            )

    def get_help_text(self):
        return _("Dodaj co najmniej jedną wielką literę.")

class LowercaseValidator:
    def validate(self, password, user=None):
        if not re.search(r'[a-z]', password):
            raise ValidationError(
                _("Hasło musi zawierać małą literę."),
                code='no_lowercase'
            )

    def get_help_text(self):
        return _("Dodaj co najmniej jedną małą literę.")

class DigitValidator:
    def validate(self, password, user=None):
        if not re.search(r'\d', password):
            raise ValidationError(
                _("Hasło musi zawierać co najmniej jedną cyfrę."),
                code='no_digit'
            )

    def get_help_text(self):
        return _("Dodaj co najmniej jedną cyfrę.")

class SpecialCharacterValidator:
    def validate(self, password, user=None):
        if not re.search(r'[!@#$%^&*(),.?":{}|<>_\-\\[\]\\/]', password):
            raise ValidationError(
                _("Hasło musi zawierać znak specjalny."),
                code='no_special_char'
            )

    def get_help_text(self):
        return _("Dodaj znak specjalny (!@#$ itd.).")

class NoWhitespaceValidator:
    def validate(self, password, user=None):
        if " " in password:
            raise ValidationError(
                _("Hasło nie może zawierać spacji."),
                code='contains_space'
            )

    def get_help_text(self):
        return _("Nie używaj spacji w haśle.")

class NoRepeatedCharactersValidator:
    def validate(self, password, user=None):
        if re.search(r'(.)\1{3,}', password):
            raise ValidationError(
                _("Hasło nie może zawierać powtarzających się znaków (np. 1111)."),
                code='repeated_chars'
            )

    def get_help_text(self):
        return _("Unikaj powtarzających się znaków.")
