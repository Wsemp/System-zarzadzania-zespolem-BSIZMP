from ...models import Notification
from rest_framework import viewsets
from .serializers import NotificationSerializer
from rest_framework.permissions import IsAuthenticated, IsAdminUser

class NotificationViewSet(viewsets.ModelViewSet):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]
