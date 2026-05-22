from rest_framework import serializers
from ...models import Invitation


class InvitationSerializer(serializers.ModelSerializer):
    project_name = serializers.SerializerMethodField()
    inviter_username = serializers.SerializerMethodField()

    class Meta:
        model = Invitation
        fields = [
            'id', 'email', 'inviter', 'project', 'project_name',
            'inviter_username', 'message', 'created_at', 'expires_at',
            'accepted', 'accepted_by', 'accepted_at',
        ]

        read_only_fields = [
            'inviter', 'accepted', 'accepted_by', 'accepted_at', 'created_at',
        ]


    def get_project_name(self, obj):
        return obj.project.name if obj.project else None

    def get_inviter_username(self, obj):
        return obj.inviter.username if obj.inviter else None
