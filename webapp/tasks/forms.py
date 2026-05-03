from django import forms
from .models import Task
from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Row, Column, Field, Submit

class TaskForm(forms.ModelForm):
    class Meta:
        model = Task
        fields = ["title", "description", "status", "assigned_to", "tags", "due_date"]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.helper = FormHelper()
        self.helper.form_method = "post"

        self.helper.layout = Layout(
            "title",

            Row(
                Column("status", css_class="col-md-4"),
                Column("assigned_to", css_class="col-md-4"),
                Column("due_date", css_class="col-md-4"),
            ),

            Field(
        "description",
            css_class="form-control",
            style="height: 120px;"
            ),

            "tags",

            Submit("submit", "Zapisz", css_class="btn btn-primary w-100")
        )


