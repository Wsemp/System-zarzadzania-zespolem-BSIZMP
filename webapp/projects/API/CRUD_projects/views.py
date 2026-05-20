from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth import get_user_model

from ...models import Project
from .serializers import ProjectSerializer, ProjectMemberActionSerializer

User = get_user_model()

class ProjectViewSet(viewsets.ModelViewSet):
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer
    permission_classes = [IsAuthenticated]

    def _can_manage_members(self, request, project: Project) -> bool:
        return request.user == project.owner or request.user.is_staff

    @action(detail=True, methods=['post'], url_path='add-member', serializer_class=ProjectMemberActionSerializer)
    def add_member(self, request, pk=None):
        project = self.get_object()
        if not self._can_manage_members(request, project):
            return Response({"detail": "Brak uprawnień."}, status=status.HTTP_403_FORBIDDEN)

        serializer = ProjectMemberActionSerializer(data=request.data)
        if serializer.is_valid(raise_exception=True):
            user_id = serializer.validated_data['user_id']
            try:
                user = User.objects.get(id=user_id)
            except User.DoesNotExist:
                return Response({"detail": "Użytkownik nie znaleziony."}, status=status.HTTP_404_NOT_FOUND)

            if project.members.filter(id=user.id).exists():
                return Response({"detail": "Użytkownik już należy do projektu."}, status=status.HTTP_400_BAD_REQUEST)

            project.members.add(user)
            project.save()
            return Response({"detail": "Użytkownik dodany."}, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
