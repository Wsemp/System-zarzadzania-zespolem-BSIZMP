from django import forms
from .models import Task
from projects.models import Project
from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Row, Column, Field, Submit


class TaskForm(forms.ModelForm):
    class Meta:
        model = Task
        fields = ["title", "description", "status", "assigned_to", "tags", "due_date", "project"]
        widgets = {
            "due_date": forms.DateInput(attrs={"type": "date"}),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.fields["assigned_to"].error_messages = {
            "invalid_choice": "Ten użytkownik nie należy do wybranego projektu."
        }

        project = self.data.get("project") or self.initial.get("project")

        if project:
            try:
                project_obj = Project.objects.get(id=project)
                self.fields["assigned_to"].queryset = project_obj.members.all()
            except Project.DoesNotExist:
                pass

        self.helper = FormHelper()
        self.helper.form_method = "post"

        self.helper.layout = Layout(
            "title",
                "project",

            Row(
                Column("status", css_class="col-md-4"),
                Column("assigned_to", css_class="col-md-4"),
                Column("due_date", css_class="col-md-4"),
            ),

            Field(
        "description",
            css_class="form-control",
            style="height: 60px;"
            ),

            "tags",

            Submit("submit", "Zapisz", css_class="btn btn-primary w-100")
        )

    def clean(self):
        cleaned_data = super().clean()

        project = cleaned_data.get("project")
        assigned_to = cleaned_data.get("assigned_to")

        if project and assigned_to:
            if not project.members.filter(id=assigned_to.id).exists():
                raise forms.ValidationError(
                    "Ten użytkownik nie należy do wybranego projektu."
                )

        return cleaned_data

