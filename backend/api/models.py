from django.db import models
from django.conf import settings
from django.db.models.signals import post_delete, pre_save
from django.dispatch import receiver
import uuid
from datetime import datetime
import os
from pathlib import Path
import hashlib


def cleanup_empty_dirs(file_path):
    """
    Remove empty directories after file deletion.
    Only works with local storage, safely ignores S3.
    """
    try:
        # Only cleanup for local storage
        if not settings.USE_S3 and hasattr(settings, 'MEDIA_ROOT'):
            # Get the directory containing the file
            file_dir = Path(file_path).parent
            
            # Walk up the directory tree and remove empty directories
            # Stop at MEDIA_ROOT to avoid deleting the media folder itself
            media_root = Path(settings.MEDIA_ROOT)
            current_dir = file_dir
            
            while current_dir != media_root and current_dir.exists():
                try:
                    # Check if directory is empty
                    if not any(current_dir.iterdir()):
                        current_dir.rmdir()
                        current_dir = current_dir.parent
                    else:
                        # Directory not empty, stop here
                        break
                except (OSError, PermissionError):
                    # Can't remove directory, stop trying
                    break
    except Exception:
        # Silently ignore any errors during cleanup
        pass


def document_upload_path(instance, filename):
    """
    Generate a unique path for uploaded documents.
    Format: documents/YYYY_MM_DD/uuid_filename.ext
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
    
    # Organize by date: documents/2025_12_09/filename
    date_folder = datetime.now().strftime('%Y_%m_%d')
    return f'documents/{date_folder}/{new_filename}'


class UserProfile(models.Model):
    """
    Model to store additional user information.
    """
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='profile'
    )
    email_notifications_enabled = models.BooleanField(default=True)

    def __str__(self):
        return f"Profile for {self.user.username}"


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
    updated_at = models.DateTimeField(auto_now=True)
    due_date = models.DateTimeField(null=True, blank=True)
    priority = models.CharField(
        max_length=10,
        choices=PRIORITY_CHOICES,
        default='Medium'
    )
    is_completed = models.BooleanField(default=False)
    notification_sent = models.BooleanField(default=False)
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
    file_hash = models.CharField(max_length=64, blank=True, db_index=True)  # SHA256 hash
    file_size = models.PositiveIntegerField(default=0)  # Size in bytes
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
    
    def calculate_file_hash(self):
        """Calculate SHA256 hash of the file content."""
        if not self.file:
            return ''
        
        hash_sha256 = hashlib.sha256()
        try:
            # Read file in chunks to handle large files
            self.file.seek(0)
            for chunk in iter(lambda: self.file.read(4096), b''):
                hash_sha256.update(chunk)
            self.file.seek(0)
            return hash_sha256.hexdigest()
        except Exception:
            return ''
    
    def save(self, *args, **kwargs):
        """Override save to calculate hash and size on creation."""
        if not self.pk:  # Only on creation
            if self.file:
                self.file_hash = self.calculate_file_hash()
                self.file.seek(0, os.SEEK_END)
                self.file_size = self.file.tell()
                self.file.seek(0)
        super().save(*args, **kwargs)
    
    def delete(self, *args, **kwargs):
        """
        Override delete method to remove the file from storage
        when the Document instance is deleted.
        Works with both local and S3 storage.
        """
        # Store file path before deletion for cleanup
        file_path = self.file.path if self.file and hasattr(self.file, 'path') else None
        
        # Delete the file from storage (works with any storage backend)
        if self.file:
            self.file.delete(save=False)
        
        # Call the parent delete method
        super().delete(*args, **kwargs)
        
        # Clean up empty directories (local storage only)
        if file_path:
            cleanup_empty_dirs(file_path)


# Signal to delete file when Document is deleted (e.g., cascading delete)
@receiver(post_delete, sender=Document)
def delete_document_file(sender, instance, **kwargs):
    """
    Delete the file from storage when a Document instance is deleted.
    This handles cascading deletes (e.g., when a Task is deleted).
    Works with both local and S3 storage backends.
    """
    # Store file path before deletion for cleanup
    file_path = instance.file.path if instance.file and hasattr(instance.file, 'path') else None
    
    if instance.file:
        instance.file.delete(save=False)
    
    # Clean up empty directories (local storage only)
    if file_path:
        cleanup_empty_dirs(file_path)


# Signal to delete old file when Document file is updated
@receiver(pre_save, sender=Document)
def delete_old_file_on_update(sender, instance, **kwargs):
    """
    Delete the old file when a Document's file field is updated.
    Works with both local and S3 storage backends.
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
        # Store old file path before deletion for cleanup
        old_file_path = old_file.path if hasattr(old_file, 'path') else None
        
        old_file.delete(save=False)
        
        # Clean up empty directories (local storage only)
        if old_file_path:
            cleanup_empty_dirs(old_file_path)


@receiver(models.signals.post_save, sender=settings.AUTH_USER_MODEL)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.create(user=instance)


@receiver(models.signals.post_save, sender=settings.AUTH_USER_MODEL)
def save_user_profile(sender, instance, **kwargs):
    instance.profile.save()


