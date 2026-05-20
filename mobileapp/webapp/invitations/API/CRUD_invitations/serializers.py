from rest_framework import serializers
# from notifications.services.notifications_services import create_notification
from ...models import Invitation

class InvitationSerializer(serializers.HyperlinkedModelSerializer):
    url = serializers.HyperlinkedIdentityField(
        view_name='invitation-detail'
    )

    class Meta:
        model = Invitation
        fields = ['url', 'id', 'email', 'inviter', 'project', 'message', 'created_at', 'expires_at', 'accepted', 'accepted_by', 'accepted_at']

#    def create(self, validated_data):
#        return create_notification(**validated_data)
