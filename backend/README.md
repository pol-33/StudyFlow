# StudyFlow Backend API

Backend completo para la aplicación de gestión de proyectos académicos **StudyFlow**. API RESTful construida con Django, Django REST Framework y autenticación JWT.

## 📋 Tabla de Contenidos

- [Características](#características)
- [Tecnologías](#tecnologías)
- [Instalación](#instalación)
- [Configuración](#configuración)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [API Endpoints](#api-endpoints)
- [Ejemplos de Uso](#ejemplos-de-uso)
- [Pruebas](#pruebas)

## ✨ Características

- ✅ Autenticación JWT (JSON Web Tokens)
- ✅ CRUD completo para Proyectos, Tareas y Documentos
- ✅ Endpoints anidados (nested resources)
- ✅ Permisos personalizados (solo propietarios pueden acceder a sus recursos)
- ✅ Subida y gestión de archivos
- ✅ Validación de datos robusta
- ✅ Base de datos SQLite
- ✅ Panel de administración de Django

## 🛠 Tecnologías

- **Python**: 3.13
- **Django**: 5.2.8
- **Django REST Framework**: 3.16.1
- **djangorestframework-simplejwt**: 5.5.1
- **drf-nested-routers**: 0.95.0
- **Base de datos**: SQLite3

## 📦 Instalación

### 1. Clonar el repositorio y entrar en la carpeta del backend

```bash
cd backend
```

### 2. Crear y activar entorno virtual

```bash
python3 -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
```

### 3. Instalar dependencias

```bash
pip install -r requirements.txt
```

### 4. Aplicar migraciones

```bash
python manage.py migrate
```

### 5. Crear superusuario (opcional, para acceder al admin)

```bash
python manage.py createsuperuser
```

### 6. Iniciar el servidor

```bash
python manage.py runserver
```

El servidor estará disponible en: `http://127.0.0.1:8000/`

## ⚙️ Configuración

### Variables de Entorno

Crea un archivo `.env` en la raíz del backend (puedes copiar `.env.example`):

```bash
cp .env.example .env
```


### Media Files

Los archivos subidos se almacenan en la carpeta `media/documents/`. La configuración ya está lista en `settings.py`:

```python
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'
```

### JWT Configuration

Los tokens JWT están configurados con los siguientes tiempos de vida:

- **Access Token**: 60 minutos
- **Refresh Token**: 1 día

## 📁 Estructura del Proyecto

```
backend/
├── api/
│   ├── migrations/
│   ├── __init__.py
│   ├── admin.py           # Configuración del panel admin
│   ├── models.py          # Modelos: Project, Task, Document
│   ├── serializers.py     # Serializadores DRF
│   ├── views.py           # ViewSets y vistas
│   ├── permissions.py     # Permisos personalizados
│   └── urls.py            # Rutas de la API
├── studyflow/
│   ├── __init__.py
│   ├── settings.py        # Configuración del proyecto
│   ├── urls.py            # URLs principales
│   └── wsgi.py
├── media/                 # Archivos subidos (creado automáticamente)
├── manage.py
├── requirements.txt
└── README.md
```

## 🌐 API Endpoints

### Autenticación

| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| POST | `/api/auth/register/` | Registro de nuevo usuario | No |
| POST | `/api/auth/token/` | Obtener access y refresh tokens | No |
| POST | `/api/auth/token/refresh/` | Renovar access token | No |

### Proyectos

| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/projects/` | Lista todos los proyectos del usuario | Sí |
| POST | `/api/projects/` | Crear nuevo proyecto | Sí |
| GET | `/api/projects/{id}/` | Detalle de un proyecto | Sí |
| PUT/PATCH | `/api/projects/{id}/` | Actualizar proyecto | Sí |
| DELETE | `/api/projects/{id}/` | Eliminar proyecto | Sí |

### Tareas (Nested)

| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/projects/{project_id}/tasks/` | Lista tareas del proyecto | Sí |
| POST | `/api/projects/{project_id}/tasks/` | Crear tarea en proyecto | Sí |
| GET | `/api/projects/{project_id}/tasks/{id}/` | Detalle de tarea | Sí |
| PUT/PATCH | `/api/projects/{project_id}/tasks/{id}/` | Actualizar tarea | Sí |
| DELETE | `/api/projects/{project_id}/tasks/{id}/` | Eliminar tarea | Sí |

### Documentos (Nested)

| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| GET | `/api/projects/{project_id}/tasks/{task_id}/documents/` | Lista documentos | Sí |
| POST | `/api/projects/{project_id}/tasks/{task_id}/documents/` | Subir documento | Sí |
| GET | `/api/projects/{project_id}/tasks/{task_id}/documents/{id}/` | Detalle de documento | Sí |
| DELETE | `/api/projects/{project_id}/tasks/{task_id}/documents/{id}/` | Eliminar documento | Sí |

## 📝 Ejemplos de Uso

### 1. Registrar un nuevo usuario

```bash
curl -X POST http://127.0.0.1:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "estudiante1",
    "email": "estudiante1@example.com",
    "password": "password123",
    "password2": "password123",
    "first_name": "Juan",
    "last_name": "Pérez"
  }'
```

**Respuesta exitosa:**
```json
{
  "user": {
    "id": 1,
    "username": "estudiante1",
    "email": "estudiante1@example.com",
    "first_name": "Juan",
    "last_name": "Pérez"
  },
  "message": "User created successfully. You can now login."
}
```

### 2. Obtener tokens de autenticación

```bash
curl -X POST http://127.0.0.1:8000/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "estudiante1",
    "password": "password123"
  }'
```

**Respuesta:**
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Nota:** Guarda el `access` token para usarlo en las siguientes peticiones.

### 3. Crear un proyecto

```bash
curl -X POST http://127.0.0.1:8000/api/projects/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "name": "Proyecto Final de Base de Datos",
    "description": "Diseño e implementación de un sistema de gestión"
  }'
```

**Respuesta:**
```json
{
  "id": 1,
  "name": "Proyecto Final de Base de Datos",
  "description": "Diseño e implementación de un sistema de gestión",
  "created_at": "2025-11-16T10:30:00Z",
  "owner": "estudiante1",
  "tasks": [],
  "tasks_count": 0,
  "completed_tasks_count": 0
}
```

### 4. Listar proyectos

```bash
curl -X GET http://127.0.0.1:8000/api/projects/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 5. Crear una tarea en un proyecto

```bash
curl -X POST http://127.0.0.1:8000/api/projects/1/tasks/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "title": "Diseñar el modelo ER",
    "description": "Crear el diagrama entidad-relación de la base de datos",
    "priority": "High",
    "due_date": "2025-11-25T23:59:00Z"
  }'
```

**Respuesta:**
```json
{
  "id": 1,
  "title": "Diseñar el modelo ER",
  "description": "Crear el diagrama entidad-relación de la base de datos",
  "created_at": "2025-11-16T10:35:00Z",
  "due_date": "2025-11-25T23:59:00Z",
  "priority": "High",
  "is_completed": false,
  "project": 1,
  "documents": [],
  "documents_count": 0
}
```

### 6. Subir un documento a una tarea

```bash
curl -X POST http://127.0.0.1:8000/api/projects/1/tasks/1/documents/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -F "file=@/path/to/documento.pdf" \
  -F "file_name=Diagrama ER v1"
```

**Respuesta:**
```json
{
  "id": 1,
  "file_name": "Diagrama ER v1",
  "file": "/media/documents/documento.pdf",
  "file_url": "http://127.0.0.1:8000/media/documents/documento.pdf",
  "uploaded_at": "2025-11-16T10:40:00Z",
  "task": 1
}
```

### 7. Marcar tarea como completada

```bash
curl -X PATCH http://127.0.0.1:8000/api/projects/1/tasks/1/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "is_completed": true
  }'
```

### 8. Renovar el access token

```bash
curl -X POST http://127.0.0.1:8000/api/auth/token/refresh/ \
  -H "Content-Type: application/json" \
  -d '{
    "refresh": "YOUR_REFRESH_TOKEN"
  }'
```

## 🧪 Pruebas

### Flujo completo de prueba

1. **Registrar un usuario**
```bash
curl -X POST http://127.0.0.1:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@test.com","password":"test1234","password2":"test1234"}'
```

2. **Obtener tokens**
```bash
curl -X POST http://127.0.0.1:8000/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"test1234"}'
```

3. **Crear un proyecto** (usando el token obtenido)
```bash
curl -X POST http://127.0.0.1:8000/api/projects/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{"name":"Test Project","description":"Testing the API"}'
```

4. **Verificar que el proyecto se creó**
```bash
curl -X GET http://127.0.0.1:8000/api/projects/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Probar con herramientas GUI

También puedes usar **Postman**, **Insomnia** o **Thunder Client** para probar la API de forma más visual:

1. Importa la colección de endpoints
2. Configura el Bearer Token en las cabeceras
3. Prueba los diferentes endpoints


## 🚀 Siguientes Pasos

- [ ] Añadir paginación a los listados
- [ ] Implementar filtros y búsqueda
- [ ] Añadir validación de tipos de archivo
- [ ] Implementar límites de tamaño de archivos
