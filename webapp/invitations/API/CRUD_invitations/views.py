from django.core.exceptions import ValidationError
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from ...models import Invitation
from .serializers import InvitationSerializer
from notifications.services.notifications_services import create_notification
from notifications.models import Notification


class InvitationViewSet(viewsets.ModelViewSet):
    queryset = Invitation.objects.all()
    serializer_class = InvitationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Invitation.objects.filter(email=self.request.user.email)

    def perform_create(self, serializer):
        invitation = serializer.save(inviter=self.request.user)
        # Notify the invited user if they have an account
        from django.contrib.auth import get_user_model
        User = get_user_model()
        try:
            invitee = User.objects.get(email=invitation.email)
            create_notification(
                recipient=invitee,
                notification_type=Notification.Type.INVITATION_SENT,
                message=f'Zaproszono Cię do projektu "{invitation.project.name}"',
                project=invitation.project,
            )
        except User.DoesNotExist:
            pass

    @action(detail=True, methods=['post'])
    def accept(self, request, pk=None):
        invitation = self.get_object()
        try:
            invitation.accept(request.user)
            create_notification(
                recipient=invitation.inviter,
                notification_type=Notification.Type.PROJECT_JOINED,
                message=f'{request.user.username} dołączył do projektu "{invitation.project.name}"',
                project=invitation.project,
            )
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
