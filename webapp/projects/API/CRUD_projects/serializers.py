from rest_framework import serializers
from ...models import Project

class ProjectSerializer(serializers.HyperlinkedModelSerializer):
    url = serializers.HyperlinkedIdentityField(
        view_name='project-detail'
    )

    class Meta:
        model = Project
        fields = ['url', 'id', 'name', 'description']
        read_only_fields = ['owner']

    def create(self, validated_data):
        user = self.context['request'].user
        return Project.objects.create(owner=user, **validated_data)