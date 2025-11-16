from rest_framework import viewsets, status, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from django.contrib.auth.models import User
from .models import Project, Task, Document
from .serializers import (
    UserSerializer, ProjectSerializer, TaskSerializer, DocumentSerializer
)
from .permissions import IsOwner, IsProjectOwner, IsTaskOwner


@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def register_user(request):
    """
    API endpoint for user registration.
    Accepts POST request with username, email, password, and password2.
    """
    serializer = UserSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        return Response({
            'user': UserSerializer(user).data,
            'message': 'User created successfully. You can now login.'
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ProjectViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Project model.
    Provides CRUD operations for projects.
    Only authenticated users can access, and they can only see their own projects.
    """
    serializer_class = ProjectSerializer
    permission_classes = [permissions.IsAuthenticated, IsOwner]
    
    def get_queryset(self):
        """Return projects owned by the current user"""
        return Project.objects.filter(owner=self.request.user)
    
    def perform_create(self, serializer):
        """Set the owner to the current user when creating a project"""
        serializer.save(owner=self.request.user)


class TaskViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Task model.
    Provides CRUD operations for tasks within a project.
    Tasks are nested under projects.
    """
    serializer_class = TaskSerializer
    permission_classes = [permissions.IsAuthenticated, IsProjectOwner]
    
    def get_queryset(self):
        """Return tasks for the specified project if user is the owner"""
        project_pk = self.kwargs.get('project_pk')
        if project_pk:
            return Task.objects.filter(
                project_id=project_pk,
                project__owner=self.request.user
            )
        return Task.objects.none()
    
    def perform_create(self, serializer):
        """Set the project when creating a task"""
        project_pk = self.kwargs.get('project_pk')
        serializer.save(project_id=project_pk)


class DocumentViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Document model.
    Provides CRUD operations for documents within a task.
    Documents are nested under tasks.
    """
    serializer_class = DocumentSerializer
    permission_classes = [permissions.IsAuthenticated, IsTaskOwner]
    
    def get_queryset(self):
        """Return documents for the specified task if user is the owner"""
        task_pk = self.kwargs.get('task_pk')
        if task_pk:
            return Document.objects.filter(
                task_id=task_pk,
                task__project__owner=self.request.user
            )
        return Document.objects.none()
    
    def perform_create(self, serializer):
        """Set the task and extract filename when creating a document"""
        task_pk = self.kwargs.get('task_pk')
        file = self.request.FILES.get('file')
        file_name = self.request.data.get('file_name', file.name if file else 'Unnamed')
        serializer.save(task_id=task_pk, file_name=file_name)
    
    def get_serializer_context(self):
        """Add request to serializer context for building absolute URLs"""
        context = super().get_serializer_context()
        context['request'] = self.request
        return context
