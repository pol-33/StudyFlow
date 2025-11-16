from django.urls import path, include
from rest_framework_nested import routers
from .views import ProjectViewSet, TaskViewSet, DocumentViewSet, register_user

# Main router for projects
router = routers.SimpleRouter()
router.register(r'projects', ProjectViewSet, basename='project')

# Nested router for tasks within projects
projects_router = routers.NestedSimpleRouter(router, r'projects', lookup='project')
projects_router.register(r'tasks', TaskViewSet, basename='project-tasks')

# Nested router for documents within tasks
tasks_router = routers.NestedSimpleRouter(projects_router, r'tasks', lookup='task')
tasks_router.register(r'documents', DocumentViewSet, basename='task-documents')

urlpatterns = [
    # User registration endpoint
    path('auth/register/', register_user, name='register'),
    
    # Include all router URLs
    path('', include(router.urls)),
    path('', include(projects_router.urls)),
    path('', include(tasks_router.urls)),
]
