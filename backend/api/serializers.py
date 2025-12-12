from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Project, Task, Document, UserProfile


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ['email_notifications_enabled']


class UserSettingsSerializer(serializers.ModelSerializer):
    """Serializer for User settings (username, email, notifications)"""
    email_notifications_enabled = serializers.BooleanField(source='profile.email_notifications_enabled')

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'email_notifications_enabled']
        read_only_fields = ['id']

    def update(self, instance, validated_data):
        profile_data = validated_data.pop('profile', {})
        email_notifications_enabled = profile_data.get('email_notifications_enabled')

        # Update User fields
        instance.username = validated_data.get('username', instance.username)
        instance.email = validated_data.get('email', instance.email)
        instance.save()

        # Update UserProfile fields
        if email_notifications_enabled is not None:
            profile, created = UserProfile.objects.get_or_create(user=instance)
            profile.email_notifications_enabled = email_notifications_enabled
            profile.save()

        return instance


class UserSerializer(serializers.ModelSerializer):
    """Serializer for User model - used for registration"""
    password = serializers.CharField(write_only=True, required=True, style={'input_type': 'password'})
    password2 = serializers.CharField(write_only=True, required=True, style={'input_type': 'password'}, label='Confirm Password')
    
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'password', 'password2', 'first_name', 'last_name']
        extra_kwargs = {
            'email': {'required': True},
        }
    
    def validate(self, attrs):
        """Validate that passwords match"""
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Password fields didn't match."})
        return attrs
    
    def create(self, validated_data):
        """Create a new user"""
        validated_data.pop('password2')
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', '')
        )
        return user


class DocumentSerializer(serializers.ModelSerializer):
    """Serializer for Document model"""
    file_url = serializers.SerializerMethodField(read_only=True)
    
    class Meta:
        model = Document
        fields = ['id', 'file_name', 'file', 'file_url', 'uploaded_at', 'task', 'file_size']
        read_only_fields = ['uploaded_at', 'task', 'file_size']
    
    def get_file_url(self, obj):
        """Return the URL of the file"""
        if obj.file:
            request = self.context.get('request')
            if request is not None:
                return request.build_absolute_uri(obj.file.url)
            return obj.file.url
        return None
    
    def validate(self, attrs):
        """Validate that the file is not a duplicate."""
        file = attrs.get('file')
        task = self.context.get('task')  # Task from view context
        
        if file and task:
            # Calculate hash of uploaded file
            import hashlib
            hash_sha256 = hashlib.sha256()
            for chunk in file.chunks():
                hash_sha256.update(chunk)
            file_hash = hash_sha256.hexdigest()
            file.seek(0)  # Reset file pointer
            
            # Check if a document with same hash exists in this task
            duplicate = Document.objects.filter(
                task=task,
                file_hash=file_hash
            ).first()
            
            if duplicate:
                raise serializers.ValidationError({
                    'file': f'This file has already been uploaded as "{duplicate.file_name}".'
                })
        
        return attrs


class TaskSerializer(serializers.ModelSerializer):
    """Serializer for Task model"""
    documents = DocumentSerializer(many=True, read_only=True)
    documents_count = serializers.SerializerMethodField(read_only=True)
    
    class Meta:
        model = Task
        fields = [
            'id', 'title', 'description', 'created_at', 'updated_at', 'due_date',
            'priority', 'is_completed', 'notification_sent', 'project', 'documents', 'documents_count'
        ]
        read_only_fields = ['created_at', 'updated_at', 'notification_sent', 'project']
    
    def get_documents_count(self, obj):
        """Return the number of documents attached to this task"""
        return obj.documents.count()


class ProjectSerializer(serializers.ModelSerializer):
    """Serializer for Project model"""
    owner = serializers.ReadOnlyField(source='owner.username')
    tasks = TaskSerializer(many=True, read_only=True)
    tasks_count = serializers.SerializerMethodField(read_only=True)
    completed_tasks_count = serializers.SerializerMethodField(read_only=True)
    
    class Meta:
        model = Project
        fields = [
            'id', 'name', 'description', 'created_at', 'owner',
            'tasks', 'tasks_count', 'completed_tasks_count'
        ]
        read_only_fields = ['created_at', 'owner']
    
    def get_tasks_count(self, obj):
        """Return the total number of tasks in this project"""
        return obj.tasks.count()
    
    def get_completed_tasks_count(self, obj):
        """Return the number of completed tasks in this project"""
        return obj.tasks.filter(is_completed=True).count()
