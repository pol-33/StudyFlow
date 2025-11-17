from django.db import models
from django.conf import settings
from django.db.models.signals import post_delete, pre_save
from django.dispatch import receiver
import os
import uuid
from datetime import datetime


def document_upload_path(instance, filename):
    """
    Generate a unique path for uploaded documents.
    Format: documents/YYYY/MM/DD/uuid_filename.ext
    This prevents filename conflicts and organizes files by date.
    """
    # Get file extension
    ext = filename.split('.')[-1] if '.' in filename else ''
    # Generate unique filename with timestamp and UUID
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    unique_id = uuid.uuid4().hex[:8]
    
    if ext:
        new_filename = f"{timestamp}_{unique_id}_{filename}"
    else:
        new_filename = f"{timestamp}_{unique_id}"
    
    # Organize by date: documents/2025/11/17/filename
    date_path = datetime.now().strftime('%Y/%m/%d')
    return f'documents/{date_path}/{new_filename}'



class Project(models.Model):
    """
    Model representing an academic project.
    Each project belongs to a specific user (owner).
    """
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='projects'
    )
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.name} - {self.owner.username}"


class Task(models.Model):
    """
    Model representing a task within a project.
    Each task belongs to a specific project.
    """
    PRIORITY_CHOICES = [
        ('Low', 'Low'),
        ('Medium', 'Medium'),
        ('High', 'High'),
    ]
    
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    due_date = models.DateTimeField(null=True, blank=True)
    priority = models.CharField(
        max_length=10,
        choices=PRIORITY_CHOICES,
        default='Medium'
    )
    is_completed = models.BooleanField(default=False)
    project = models.ForeignKey(
        Project,
        on_delete=models.CASCADE,
        related_name='tasks'
    )
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.title} - {self.project.name}"


class Document(models.Model):
    """
    Model representing a document attached to a task.
    Each document belongs to a specific task.
    Files are stored with unique names to prevent conflicts.
    """
    file_name = models.CharField(max_length=255)
    file = models.FileField(upload_to=document_upload_path)
    uploaded_at = models.DateTimeField(auto_now_add=True)
    task = models.ForeignKey(
        Task,
        on_delete=models.CASCADE,
        related_name='documents'
    )
    
    class Meta:
        ordering = ['-uploaded_at']
    
    def __str__(self):
        return f"{self.file_name} - {self.task.title}"
    
    def delete(self, *args, **kwargs):
        """
        Override delete method to remove the file from storage
        when the Document instance is deleted.
        """
        # Delete the file from storage
        if self.file:
            if os.path.isfile(self.file.path):
                os.remove(self.file.path)
        
        # Call the parent delete method
        super().delete(*args, **kwargs)


# Signal to delete file when Document is deleted
@receiver(post_delete, sender=Document)
def delete_document_file(sender, instance, **kwargs):
    """
    Delete the file from storage when a Document instance is deleted.
    This handles cascading deletes (e.g., when a Task is deleted).
    """
    if instance.file:
        if os.path.isfile(instance.file.path):
            os.remove(instance.file.path)


# Signal to delete old file when Document file is updated
@receiver(pre_save, sender=Document)
def delete_old_file_on_update(sender, instance, **kwargs):
    """
    Delete the old file when a Document's file field is updated.
    """
    if not instance.pk:
        return False

    try:
        old_file = Document.objects.get(pk=instance.pk).file
    except Document.DoesNotExist:
        return False

    # Check if the file has changed
    new_file = instance.file
    if old_file and old_file != new_file:
        if os.path.isfile(old_file.path):
            os.remove(old_file.path)
