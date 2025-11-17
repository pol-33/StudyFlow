# StudyFlow
Plataforma web para estudiantes que centraliza la gestión de tareas, proyectos y documentos, con notificaciones automáticas y flujo de trabajo organizado.

## 🚀 Inicio Rápido

### Requisitos Previos Recomendados
- Python 3.13
- Node.js 22.x
- npm 10.x

### Backend (Django)

```bash
# Navegar al directorio del backend
cd backend

# Crear y activar entorno virtual
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt

# Configurar variables de entorno
cp .env.example .env

# Ejecutar migraciones
python manage.py migrate

# Iniciar servidor
python manage.py runserver
```

El backend estará disponible en `http://127.0.0.1:8000`

### Frontend (Vue.js 3)

```bash
# En otra terminal, navegar al directorio del frontend
cd frontend

# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env

# Iniciar servidor de desarrollo
npm run dev
```

El frontend estará disponible en `http://localhost:5173`

## 📋 Configuración de CORS

El backend está configurado para aceptar peticiones desde:
- `http://localhost:5173`
- `http://127.0.0.1:5173`

Si necesitas añadir más orígenes, edita `CORS_ALLOWED_ORIGINS` en el fichero de entorno.

## 🎯 Uso de la Aplicación

1. Abre `http://localhost:5173` en tu navegador
2. Regístrate con un nuevo usuario o inicia sesión
3. Crea tu primer proyecto
4. Añade tareas a tu proyecto
5. Adjunta documentos a tus tareas
6. ¡Organiza tu flujo de estudio!

## 📚 Documentación

- [Documentación del Backend](./backend/README.md)
- [Documentación del Frontend](./frontend/README.md)
- [Colección de Postman (para importar)](./backend/StudyFlow_Postman_Collection.json)


## 📝 Licencia

Este proyecto está bajo la licencia especificada en el archivo LICENSE.
