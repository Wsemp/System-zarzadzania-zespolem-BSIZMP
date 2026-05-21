from django import forms
from projects.models import Project
from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Row, Column, Field, Submit


class ProjectForm(forms.ModelForm):
    class Meta:
        model = Project
        exclude = ['is_deleted']
