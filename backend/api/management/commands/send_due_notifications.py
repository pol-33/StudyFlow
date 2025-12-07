from django.core.management.base import BaseCommand
from django.utils import timezone
from django.core.mail import send_mail
from django.conf import settings
from api.models import Task
from datetime import timedelta

class Command(BaseCommand):
    help = 'Sends email notifications for tasks due within 24 hours'

    def handle(self, *args, **options):
        now = timezone.now()
        tomorrow = now + timedelta(days=1)
        
        # Find tasks due in the next 24 hours that haven't been notified and are not completed
        # Also check if the user has enabled email notifications
        tasks = Task.objects.filter(
            due_date__gt=now,
            due_date__lte=tomorrow,
            is_completed=False,
            notification_sent=False
        ).select_related('project__owner__profile')
        
        self.stdout.write(f"Found {tasks.count()} tasks to notify.")
        
        for task in tasks:
            user = task.project.owner
            
            # Check if user has profile and notifications enabled
            if hasattr(user, 'profile') and not user.profile.email_notifications_enabled:
                self.stdout.write(f"User {user.username} has disabled notifications. Skipping.")
                continue

            if not user.email:
                self.stdout.write(self.style.WARNING(f"User {user.username} has no email. Skipping."))
                continue
                
            subject = f"Reminder: Task '{task.title}' is due soon!"
            message = f"""Hello {user.username},

This is a reminder that your task "{task.title}" in project "{task.project.name}" is due on {task.due_date.strftime('%Y-%m-%d %H:%M')} UTC.

Please make sure to complete it on time.

Best regards,
StudyFlow Team
"""
            
            try:
                send_mail(
                    subject,
                    message,
                    settings.DEFAULT_FROM_EMAIL,
                    [user.email],
                    fail_silently=False,
                )
                task.notification_sent = True
                task.save()
                self.stdout.write(self.style.SUCCESS(f"Sent notification for task '{task.title}' to {user.email}"))
            except Exception as e:
                self.stdout.write(self.style.ERROR(f"Failed to send email for task '{task.title}': {str(e)}"))
