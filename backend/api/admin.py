from django.contrib import admin
from .models import Project, Task, Document


@admin.register(Project)
class ProjectAdmin(admin.ModelAdmin):
    list_display = ['name', 'owner', 'created_at']
    list_filter = ['created_at', 'owner']
    search_fields = ['name', 'description']
    readonly_fields = ['created_at']


@admin.register(Task)
class TaskAdmin(admin.ModelAdmin):
    list_display = ['title', 'project', 'priority', 'is_completed', 'due_date', 'created_at']
    list_filter = ['priority', 'is_completed', 'created_at', 'due_date']
    search_fields = ['title', 'description']
    readonly_fields = ['created_at']


@admin.register(Document)
class DocumentAdmin(admin.ModelAdmin):
    list_display = ['file_name', 'task', 'uploaded_at']
    list_filter = ['uploaded_at']
    search_fields = ['file_name']
    readonly_fields = ['uploaded_at']
