import { defineStore } from 'pinia'
import taskService from '@/services/taskService'
import documentService from '@/services/documentService'

export const useTaskStore = defineStore('task', {
  state: () => ({
    tasks: [],
    currentTask: null,
    documents: [],
    loading: false,
    error: null,
  }),

  getters: {
    allTasks: (state) => state.tasks,
    selectedTask: (state) => state.currentTask,
    taskDocuments: (state) => state.documents,
    isLoading: (state) => state.loading,
    
    // Filtros útiles
    completedTasks: (state) => state.tasks.filter((t) => t.is_completed),
    pendingTasks: (state) => state.tasks.filter((t) => !t.is_completed),
    highPriorityTasks: (state) => state.tasks.filter((t) => t.priority === 'High'),
  },

  actions: {
    async fetchTasks(projectId) {
      this.loading = true
      this.error = null
      const response = await taskService.list(projectId)
      this.loading = false
      if (response.status >= 200 && response.status < 300) {
        this.tasks = response.data
        return response.data
      }
      this.error = response.data?.detail || 'Error fetching tasks'
      throw response
    },

    async createTask(projectId, taskData) {
      this.loading = true
      this.error = null
      const response = await taskService.create(projectId, taskData)
      this.loading = false
      if (response.status >= 200 && response.status < 300) {
        this.tasks.push(response.data)
        return response.data
      }
      this.error = response.data?.detail || 'Error creating task'
      throw response
    },

    async updateTask(projectId, taskId, taskData) {
      this.loading = true
      this.error = null
      const response = await taskService.update(projectId, taskId, taskData)
      this.loading = false
      if (response.status >= 200 && response.status < 300) {
        const index = this.tasks.findIndex((t) => t.id === taskId)
        if (index !== -1) {
          this.tasks[index] = response.data
        }
        if (this.currentTask?.id === taskId) {
          this.currentTask = response.data
        }
        return response.data
      }
      this.error = response.data?.detail || 'Error updating task'
      throw response
    },

    async deleteTask(projectId, taskId) {
      this.loading = true
      this.error = null
      const response = await taskService.delete(projectId, taskId)
      this.loading = false
      if (response.status >= 200 && response.status < 300) {
        this.tasks = this.tasks.filter((t) => t.id !== taskId)
        if (this.currentTask?.id === taskId) {
          this.currentTask = null
          this.documents = []
        }
        return
      }
      this.error = response.data?.detail || 'Error deleting task'
      throw response
    },

    async toggleTaskCompletion(projectId, taskId, isCompleted) {
      return this.updateTask(projectId, taskId, { is_completed: isCompleted })
    },

    async updateTaskPriority(projectId, taskId, priority) {
      return this.updateTask(projectId, taskId, { priority })
    },

    // Gestión de documentos
    async fetchDocuments(projectId, taskId) {
      this.loading = true
      this.error = null
      const response = await documentService.list(projectId, taskId)
      this.loading = false
      if (response.status >= 200 && response.status < 300) {
        this.documents = response.data
        return response.data
      }
      this.error = response.data?.detail || 'Error fetching documents'
      throw response
    },

    async uploadDocument(projectId, taskId, formData) {
      this.loading = true
      this.error = null
      const response = await documentService.upload(projectId, taskId, formData)
      this.loading = false
      if (response.status >= 200 && response.status < 300) {
        this.documents.push(response.data)
        return response.data
      }
      this.error = response.data?.detail || 'Error uploading document'
      throw response
    },

    async deleteDocument(projectId, taskId, documentId) {
      this.loading = true
      this.error = null
      const response = await documentService.delete(projectId, taskId, documentId)
      this.loading = false
      if (response.status >= 200 && response.status < 300) {
        this.documents = this.documents.filter((d) => d.id !== documentId)
        return
      }
      this.error = response.data?.detail || 'Error deleting document'
      throw response
    },

    selectTask(task) {
      this.currentTask = task
    },

    clearCurrentTask() {
      this.currentTask = null
      this.documents = []
    },

    clearTasks() {
      this.tasks = []
      this.currentTask = null
      this.documents = []
    },
  },
})
