# Backend Email Service Configuration

This document details the backend implementation of the email notification service, which integrates with AWS SES.

## Overview

The system is configured to send email notifications to users when their tasks are due within the next 24 hours. It uses `django-ses` to communicate with Amazon Simple Email Service (SES).

## 1. Dependencies

We use the `django-ses` package, which is a drop-in replacement for Django's default email backend. It handles the communication with AWS SES using `boto3` under the hood. This simplifies a lot of the low-level details of sending emails through AWS.

## 2. Configuration

### Settings (`settings.py`)
The email backend is configured in `backend/studyflow/settings/base.py`:

```python
# AWS Configuration
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
```

```python
# Email Configuration (AWS SES)
EMAIL_BACKEND = 'django_ses.SESBackend'

AWS_SES_REGION_NAME = os.getenv('AWS_SES_REGION_NAME', 'eu-west-3')
AWS_SES_REGION_ENDPOINT = os.getenv('AWS_SES_REGION_ENDPOINT', 'email.eu-west-3.amazonaws.com')
DEFAULT_FROM_EMAIL = os.getenv('DEFAULT_FROM_EMAIL', 'noreply@polplana.work')
```

### Environment Variables (`.env`)
The sensitive credentials and region-specific settings are stored in the `.env` file:

```dotenv
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_SES_REGION_NAME=eu-west-3
AWS_SES_REGION_ENDPOINT=email.eu-west-3.amazonaws.com
DEFAULT_FROM_EMAIL=StudyFlow <noreply@polplana.work>
```

*   **Region:** Configured to `eu-west-3` (Paris) to match the SES identity setup, according to our Route 53 and SES configuration.
*   **Sender:** Configured as `StudyFlow <noreply@polplana.work>` for brand recognition.

## 3. Notification Logic

### Database Model
We added a `notification_sent` boolean field to the `Task` model to track whether a notification has already been sent for a specific task. This prevents duplicate emails.

### Management Command
A custom Django management command `send_due_notifications` implements the logic:
*   **Path:** `backend/api/management/commands/send_due_notifications.py`
*   **Logic:**
    1.  Calculates the time range: `now` to `now + 24 hours`.
    2.  Queries tasks that:
        *   Are due within this range.
        *   Are NOT completed (`is_completed=False`).
        *   Have NOT been notified yet (`notification_sent=False`).
    3.  Iterates through tasks and sends an email to the project owner.
    4.  Marks `notification_sent = True` upon success.

## 4. Automation

To run this automatically, a cron job (or Kubernetes CronJob) should be set up to execute the command periodically (e.g., every hour). It has not been automated yet.

**Manual Execution:**
```bash
python manage.py send_due_notifications
```

**Docker Execution:**
```bash
docker compose --profile dev exec backend python manage.py send_due_notifications
```
