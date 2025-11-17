# StudyFlow - Frontend

Frontend de la aplicación StudyFlow construido con Vue 3, Vite, Pinia y Element Plus.

## 📁 Estructura del Proyecto

```
src/
├── assets/           # Recursos estáticos
├── components/       # Componentes reutilizables
│   ├── AppLayout.vue
│   ├── ProjectList.vue
│   ├── ProjectDetail.vue
│   ├── TaskList.vue
│   ├── TaskItem.vue
│   └── DocumentManager.vue
├── router/          # Configuración de rutas
│   └── index.js
├── services/        # Servicios API
│   └── api.js
├── stores/          # Pinia stores
│   ├── authStore.js
│   ├── projectStore.js
│   └── taskStore.js
├── views/           # Vistas/Páginas
│   ├── LandingView.vue
│   ├── LoginView.vue
│   ├── RegisterView.vue
│   └── DashboardView.vue
├── App.vue
├── main.js
└── style.css
```

## 🛠️ Instalación

```bash
# Instalar dependencias
npm install

# Configurar variables de entorno en el archivo .env
```

## 🏃‍♂️ Comandos Disponibles

```bash
# Desarrollo
npm run dev

# Build para producción
npm run build
```

## 🎨 Características

### Autenticación
- ✅ Registro de usuarios
- ✅ Login con JWT
- ✅ Persistencia de sesión con localStorage
- ✅ Protección de rutas

### Gestión de Proyectos
- ✅ Listar proyectos
- ✅ Crear nuevo proyecto
- ✅ Editar proyecto
- ✅ Eliminar proyecto
- ✅ Selección de proyecto activo

### Gestión de Tareas
- ✅ Listar tareas por proyecto
- ✅ Crear nueva tarea
- ✅ Editar tarea
- ✅ Eliminar tarea
- ✅ Marcar como completada
- ✅ Cambiar prioridad
- ✅ Filtrar por estado
- ✅ Fechas límite

### Gestión de Documentos
- ✅ Listar documentos por tarea
- ✅ Subir documento
- ✅ Descargar documento
- ✅ Eliminar documento


## 🚦 Inicio Rápido

1. Asegúrate de que el backend esté corriendo en `http://127.0.0.1:8000`
2. Ejecuta `npm run dev`
3. Abre `http://localhost:5173`
4. ¡Comienza a usar StudyFlow!
