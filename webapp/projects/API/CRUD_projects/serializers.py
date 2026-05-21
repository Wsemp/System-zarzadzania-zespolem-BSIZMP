from django.contrib.auth.models import User
from rest_framework import serializers
from ...models import Project

class ProjectMemberActionSerializer(serializers.Serializer):
    user_id = serializers.IntegerField()

class UserShortSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email']

class ProjectSerializer(serializers.HyperlinkedModelSerializer):
    url = serializers.HyperlinkedIdentityField(view_name='project-detail')
    members = UserShortSerializer(many=True, read_only=True)

    class Meta:
        model = Project
        fields = ['url', 'id', 'name', 'description', 'members']
        read_only_fields = ['owner']

    def create(self, validated_data):
        user = self.context['request'].user
        return Project.objects.create(owner=user, **validated_data)
