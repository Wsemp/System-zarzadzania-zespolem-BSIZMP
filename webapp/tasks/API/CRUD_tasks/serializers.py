from ...models import Task, Tag
from ...services.task_services import create_task, update_task
from rest_framework import serializers
from django.contrib.auth.models import User


class TagSerializer(serializers.ModelSerializer):
    class Meta:
        model = Tag
        fields = ['id', 'name']


class TaskSerializer(serializers.HyperlinkedModelSerializer):

    tags = TagSerializer(many=True, read_only=True)


    tag_ids = serializers.PrimaryKeyRelatedField(
        queryset=Tag.objects.all(),
        many=True,
        write_only=False,
        source='tags'
    )

    assigned_to = serializers.PrimaryKeyRelatedField(
        queryset=User.objects.all(),
        required=False,
        allow_null=True
    )

    created_by = serializers.PrimaryKeyRelatedField(
        read_only=True
    )

    class Meta:
        model = Task
        fields = [
            'url',
            'id',
            'title',
            'description',
            'status',
            'priority',
            'assigned_to',
            'created_by',
            'tags',
            'tag_ids',
            'due_date',
            'created_at',
            'updated_at',
            'project',
        ]

    def create(self, validated_data):

        user = self.context['request'].user
        task = create_task(created_by=user, **validated_data)

        return task

    def update(self, instance, validated_data):
        return update_task(task_id=instance.id, **validated_data)
