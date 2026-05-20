from ...models import Invitation
from rest_framework import viewsets
from .serializers import InvitationSerializer
from rest_framework.permissions import IsAuthenticated, IsAdminUser

class InvitationViewSet(viewsets.ModelViewSet):
    queryset = Invitation.objects.all()
    serializer_class = InvitationSerializer
    permission_classes = [IsAuthenticated]
