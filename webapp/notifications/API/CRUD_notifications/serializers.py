from rest_framework import serializers
from ...models import Notification


class NotificationSerializer(serializers.ModelSerializer):
    task_id = serializers.SerializerMethodField()
    task_title = serializers.SerializerMethodField()
    project_id = serializers.SerializerMethodField()
    project_name = serializers.SerializerMethodField()

    class Meta:
        model = Notification
        fields = [
            'id', 'recipient', 'task_id', 'task_title',
            'project_id', 'project_name',
            'type', 'message', 'is_read', 'created_at', 'read_at',
        ]

    def get_task_id(self, obj):
        return obj.task_id

    def get_task_title(self, obj):
        return obj.task.title if obj.task else None

    def get_project_id(self, obj):
        return obj.project_id

    def get_project_name(self, obj):
        return obj.project.name if obj.project else None
