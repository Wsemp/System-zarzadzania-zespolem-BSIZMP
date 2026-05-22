from django.core.exceptions import ValidationError
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from ...models import Invitation
from .serializers import InvitationSerializer


class InvitationViewSet(viewsets.ModelViewSet):
    queryset = Invitation.objects.all()
    serializer_class = InvitationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # Pokazuj tylko zaproszenia skierowane do zalogowanego użytkownika (dla admina pokazuj wszystkie zaproszenia)
        if self.request.user.is_staff:
            return Invitation.objects.all()
        else:
            return Invitation.objects.filter(email=self.request.user.email)

    def perform_create(self, serializer):
        # Automatycznie ustaw zapraszającego jako aktualnego użytkownika
        serializer.save(inviter=self.request.user)

    @action(detail=True, methods=['post'])
    def accept(self, request, pk=None):
        invitation = self.get_object()
        try:
            invitation.accept(request.user)
            serializer = self.get_serializer(invitation)
            return Response(serializer.data)
        except ValidationError as e:
            msg = e.message if hasattr(e, 'message') else str(e)
            return Response({'detail': msg}, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        invitation = self.get_object()
        if invitation.accepted:
            return Response(
                {'detail': 'Zaproszenie zostało już zaakceptowane.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        invitation.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
