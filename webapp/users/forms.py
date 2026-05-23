from django import forms
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError

User = get_user_model()


class UserCreateForm(forms.ModelForm):

    password = forms.CharField(widget=forms.PasswordInput, label="Hasło")
    password2 = forms.CharField(widget=forms.PasswordInput, label="Powtórz hasło")

    class Meta:
        model = User
        fields = ["username", "email", "is_staff", "password"]
        help_texts = {
            "username": "",
        }
    def clean_email(self):
        email = self.cleaned_data["email"]
        if email == "":
            return email
        if User.objects.filter(email=email).exists():
            raise forms.ValidationError("Email already exist")
        return email

    def clean_password(self):
        password = self.cleaned_data.get("password")

        if password:
            try:
                validate_password(password)
            except ValidationError as e:
                raise forms.ValidationError(e.messages)

        return password

    def clean(self):
        cleaned_data = super().clean()
        password = cleaned_data.get("password")
        password2 = cleaned_data.get("password2")

        if password and password2 and password != password2:
            raise forms.ValidationError("Hasła nie są takie same")

        return cleaned_data

class UserUpdateForm(forms.ModelForm):
    class Meta:
        model = User
        fields = ['username', 'email', 'is_staff', 'is_active']
        help_texts = {
            "username": "",
        }