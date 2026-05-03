from rest_framework import serializers
from ...models import Project

class ProjectSerializer(serializers.HyperlinkedModelSerializer):
    url = serializers.HyperlinkedIdentityField(
        view_name='project-detail'
    )
    class Meta:
        model = Project
        fields = ['url', 'id', 'name', 'description']