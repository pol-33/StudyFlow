from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Project, Task, Document


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
        fields = ['id', 'file_name', 'file', 'file_url', 'uploaded_at', 'task']
        read_only_fields = ['uploaded_at', 'task']
    
    def get_file_url(self, obj):
        """Return the URL of the file"""
        if obj.file:
            request = self.context.get('request')
            if request is not None:
                return request.build_absolute_uri(obj.file.url)
            return obj.file.url
        return None


class TaskSerializer(serializers.ModelSerializer):
    """Serializer for Task model"""
    documents = DocumentSerializer(many=True, read_only=True)
    documents_count = serializers.SerializerMethodField(read_only=True)
    
    class Meta:
        model = Task
        fields = [
            'id', 'title', 'description', 'created_at', 'due_date',
            'priority', 'is_completed', 'project', 'documents', 'documents_count'
        ]
        read_only_fields = ['created_at', 'project']
    
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
