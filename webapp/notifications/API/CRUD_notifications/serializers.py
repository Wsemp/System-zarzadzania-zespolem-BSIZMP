from rest_framework import serializers
from notifications.services.notifications_services import create_notification
from ...models import Notification

class NotificationSerializer(serializers.HyperlinkedModelSerializer):
    url = serializers.HyperlinkedIdentityField(
        view_name='notification-detail'
    )

    class Meta:
        model = Notification
        fields = ['url', 'id', 'recipient', 'task', 'type', 'message', 'is_read', 'created_at', 'read_at']

    def create(self, validated_data):
        return create_notification(**validated_data)
