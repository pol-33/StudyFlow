from rest_framework import permissions


class IsOwner(permissions.BasePermission):
    """
    Custom permission to only allow owners of an object to view/edit it.
    """
    
    def has_object_permission(self, request, view, obj):
        # Check if the object has an owner attribute
        if hasattr(obj, 'owner'):
            return obj.owner == request.user
        # For Task objects, check the project owner
        elif hasattr(obj, 'project'):
            return obj.project.owner == request.user
        # For Document objects, check the task's project owner
        elif hasattr(obj, 'task'):
            return obj.task.project.owner == request.user
        return False


class IsProjectOwner(permissions.BasePermission):
    """
    Custom permission to only allow owners of a project to perform actions.
    """
    
    def has_permission(self, request, view):
        # Check if project_pk is in the URL kwargs
        project_pk = view.kwargs.get('project_pk')
        if project_pk:
            from .models import Project
            try:
                project = Project.objects.get(pk=project_pk)
                return project.owner == request.user
            except Project.DoesNotExist:
                return False
        return True
    
    def has_object_permission(self, request, view, obj):
        # For nested resources, check the parent project
        if hasattr(obj, 'project'):
            return obj.project.owner == request.user
        return False


class IsTaskOwner(permissions.BasePermission):
    """
    Custom permission to only allow owners of a task's project to perform actions.
    """
    
    def has_permission(self, request, view):
        # Check if task_pk is in the URL kwargs
        task_pk = view.kwargs.get('task_pk')
        if task_pk:
            from .models import Task
            try:
                task = Task.objects.get(pk=task_pk)
                return task.project.owner == request.user
            except Task.DoesNotExist:
                return False
        return True
    
    def has_object_permission(self, request, view, obj):
        # For documents, check the task's project owner
        if hasattr(obj, 'task'):
            return obj.task.project.owner == request.user
        return False
