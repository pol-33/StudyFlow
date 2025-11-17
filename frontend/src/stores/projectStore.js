import { defineStore } from 'pinia'
import { projectsAPI } from '@/services/api'

export const useProjectStore = defineStore('project', {
  state: () => ({
    projects: [],
    currentProject: null,
    loading: false,
    error: null,
  }),

  getters: {
    allProjects: (state) => state.projects,
    selectedProject: (state) => state.currentProject,
    isLoading: (state) => state.loading,
  },

  actions: {
    async fetchProjects() {
      this.loading = true
      this.error = null
      try {
        const response = await projectsAPI.list()
        this.projects = response.data
        return response.data
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async createProject(projectData) {
      this.loading = true
      this.error = null
      try {
        const response = await projectsAPI.create(projectData)
        this.projects.push(response.data)
        return response.data
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async updateProject(projectId, projectData) {
      this.loading = true
      this.error = null
      try {
        const response = await projectsAPI.update(projectId, projectData)
        const index = this.projects.findIndex((p) => p.id === projectId)
        if (index !== -1) {
          this.projects[index] = response.data
        }
        if (this.currentProject?.id === projectId) {
          this.currentProject = response.data
        }
        return response.data
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async deleteProject(projectId) {
      this.loading = true
      this.error = null
      try {
        await projectsAPI.delete(projectId)
        this.projects = this.projects.filter((p) => p.id !== projectId)
        if (this.currentProject?.id === projectId) {
          this.currentProject = null
        }
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async selectProject(projectId) {
      this.loading = true
      this.error = null
      try {
        const response = await projectsAPI.get(projectId)
        this.currentProject = response.data
        return response.data
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    clearCurrentProject() {
      this.currentProject = null
    },

    clearProjects() {
      this.projects = []
      this.currentProject = null
    },
  },
})
