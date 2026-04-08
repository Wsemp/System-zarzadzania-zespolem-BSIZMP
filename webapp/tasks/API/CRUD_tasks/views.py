# from django.contrib.auth.models import User
# from ...services.task_services import
from ...selectors import get_tasks
from rest_framework import viewsets
from .serializers import TaskSerializer
from rest_framework.permissions import IsAuthenticated, IsAdminUser

class TaskViewSet(viewsets.ModelViewSet):
    queryset = get_tasks()
    serializer_class = TaskSerializer
    permission_classes = [IsAuthenticated]

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [IsAuthenticated()]
        else:
            return [IsAdminUser()]