import { defineStore } from 'pinia'
import projectService from '@/services/projectService'

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
      const response = await projectService.list()
      this.loading = false
      if (response.status >= 200 && response.status < 300) {
        this.projects = response.data
        return response.data
      }
      this.error = response.data?.detail || 'Error fetching projects'
      throw response
    },

    async createProject(projectData) {
      this.loading = true
      this.error = null
      const response = await projectService.create(projectData)
      this.loading = false
      if (response.status >= 200 && response.status < 300) {
        this.projects.push(response.data)
        return response.data
      }
      this.error = response.data?.detail || 'Error creating project'
      throw response
    },

    async updateProject(projectId, projectData) {
      this.loading = true
      this.error = null
      const response = await projectService.update(projectId, projectData)
      this.loading = false
      if (response.status >= 200 && response.status < 300) {
        const index = this.projects.findIndex((p) => p.id === projectId)
        if (index !== -1) {
          this.projects[index] = response.data
        }
        if (this.currentProject?.id === projectId) {
          this.currentProject = response.data
        }
        return response.data
      }
      this.error = response.data?.detail || 'Error updating project'
      throw response
    },

    async deleteProject(projectId) {
      this.loading = true
      this.error = null
      const response = await projectService.delete(projectId)
      this.loading = false
      if (response.status >= 200 && response.status < 300) {
        this.projects = this.projects.filter((p) => p.id !== projectId)
        if (this.currentProject?.id === projectId) {
          this.currentProject = null
        }
        return
      }
      this.error = response.data?.detail || 'Error deleting project'
      throw response
    },

    async selectProject(projectId) {
      this.loading = true
      this.error = null
      const response = await projectService.get(projectId)
      this.loading = false
      if (response.status >= 200 && response.status < 300) {
        this.currentProject = response.data
        return response.data
      }
      this.error = response.data?.detail || 'Error fetching project'
      throw response
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
