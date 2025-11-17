import axios from 'axios'
import { useAuthStore } from '@/stores/authStore'
import router from '@/router'

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Interceptor de peticiones - añadir token automáticamente
apiClient.interceptors.request.use(
  (config) => {
    const authStore = useAuthStore()
    if (authStore.accessToken) {
      config.headers.Authorization = `Bearer ${authStore.accessToken}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Interceptor de respuestas - manejar errores 401
apiClient.interceptors.response.use(
  (response) => {
    return response
  },
  (error) => {
    if (error.response && error.response.status === 401) {
      const authStore = useAuthStore()
      authStore.logout()
      router.push('/login')
    }
    return Promise.reject(error)
  }
)

// Auth API
export const authAPI = {
  register(userData) {
    return apiClient.post('/api/auth/register/', userData)
  },
  login(credentials) {
    return apiClient.post('/api/auth/token/', credentials)
  },
  refresh(refreshToken) {
    return apiClient.post('/api/auth/token/refresh/', { refresh: refreshToken })
  },
}

// Projects API
export const projectsAPI = {
  list() {
    return apiClient.get('/api/projects/')
  },
  create(projectData) {
    return apiClient.post('/api/projects/', projectData)
  },
  get(projectId) {
    return apiClient.get(`/api/projects/${projectId}/`)
  },
  update(projectId, projectData) {
    return apiClient.patch(`/api/projects/${projectId}/`, projectData)
  },
  delete(projectId) {
    return apiClient.delete(`/api/projects/${projectId}/`)
  },
}

// Tasks API
export const tasksAPI = {
  list(projectId) {
    return apiClient.get(`/api/projects/${projectId}/tasks/`)
  },
  create(projectId, taskData) {
    return apiClient.post(`/api/projects/${projectId}/tasks/`, taskData)
  },
  get(projectId, taskId) {
    return apiClient.get(`/api/projects/${projectId}/tasks/${taskId}/`)
  },
  update(projectId, taskId, taskData) {
    return apiClient.patch(`/api/projects/${projectId}/tasks/${taskId}/`, taskData)
  },
  delete(projectId, taskId) {
    return apiClient.delete(`/api/projects/${projectId}/tasks/${taskId}/`)
  },
}

// Documents API
export const documentsAPI = {
  list(projectId, taskId) {
    return apiClient.get(`/api/projects/${projectId}/tasks/${taskId}/documents/`)
  },
  upload(projectId, taskId, formData) {
    return apiClient.post(`/api/projects/${projectId}/tasks/${taskId}/documents/`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    })
  },
  delete(projectId, taskId, documentId) {
    return apiClient.delete(`/api/projects/${projectId}/tasks/${taskId}/documents/${documentId}/`)
  },
}

export default apiClient
