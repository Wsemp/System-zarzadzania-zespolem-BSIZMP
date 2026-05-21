from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('notifications', '0001_initial'),
        ('projects', '0001_initial'),
        ('tasks', '0003_alter_task_status'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.AlterField(
            model_name='notification',
            name='task',
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.SET_NULL,
                related_name='notifications',
                to='tasks.task',
            ),
        ),
        migrations.AddField(
            model_name='notification',
            name='project',
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.SET_NULL,
                related_name='notifications',
                to='projects.project',
            ),
        ),
        migrations.AlterField(
            model_name='notification',
            name='type',
            field=models.CharField(
                choices=[
                    ('task_assigned', 'Task assigned'),
                    ('task_updated', 'Task updated'),
                    ('task_completed', 'Task completed'),
                    ('task_overdue', 'Task overdue'),
                    ('comment_added', 'Comment added'),
                    ('status_changed', 'Status changed'),
                    ('invitation_sent', 'Invitation sent'),
                    ('project_joined', 'Project joined'),
                ],
                max_length=50,
            ),
        ),
    ]
