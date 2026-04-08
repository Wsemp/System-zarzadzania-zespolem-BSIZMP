from ...models import Task, Tag
# from ...services.task_services import create_task
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
        write_only=True,
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
            'assigned_to',
            'created_by',
            'tags',
            'tag_ids',
            'due_date',
            'created_at',
            'updated_at',
        ]

    def create(self, validated_data):
        tags = validated_data.pop('tags', [])
        user = self.context['request'].user

        task = Task.objects.create(created_by=user, **validated_data)
        task.tags.set(tags)

        return task

    def update(self, instance, validated_data):
        tags = validated_data.pop('tags', None)

        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        if tags is not None:
            instance.tags.set(tags)

        instance.save()
        return instance
