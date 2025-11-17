import { defineStore } from 'pinia'
import { tasksAPI, documentsAPI } from '@/services/api'

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
      try {
        const response = await tasksAPI.list(projectId)
        this.tasks = response.data
        return response.data
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async createTask(projectId, taskData) {
      this.loading = true
      this.error = null
      try {
        const response = await tasksAPI.create(projectId, taskData)
        this.tasks.push(response.data)
        return response.data
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async updateTask(projectId, taskId, taskData) {
      this.loading = true
      this.error = null
      try {
        const response = await tasksAPI.update(projectId, taskId, taskData)
        const index = this.tasks.findIndex((t) => t.id === taskId)
        if (index !== -1) {
          this.tasks[index] = response.data
        }
        if (this.currentTask?.id === taskId) {
          this.currentTask = response.data
        }
        return response.data
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async deleteTask(projectId, taskId) {
      this.loading = true
      this.error = null
      try {
        await tasksAPI.delete(projectId, taskId)
        this.tasks = this.tasks.filter((t) => t.id !== taskId)
        if (this.currentTask?.id === taskId) {
          this.currentTask = null
          this.documents = []
        }
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
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
      try {
        const response = await documentsAPI.list(projectId, taskId)
        this.documents = response.data
        return response.data
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async uploadDocument(projectId, taskId, formData) {
      this.loading = true
      this.error = null
      try {
        const response = await documentsAPI.upload(projectId, taskId, formData)
        this.documents.push(response.data)
        return response.data
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async deleteDocument(projectId, taskId, documentId) {
      this.loading = true
      this.error = null
      try {
        await documentsAPI.delete(projectId, taskId, documentId)
        this.documents = this.documents.filter((d) => d.id !== documentId)
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
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
