import { defineStore } from 'pinia'
import { authAPI } from '@/services/api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    accessToken: localStorage.getItem('accessToken') || null,
    refreshToken: localStorage.getItem('refreshToken') || null,
  }),

  getters: {
    isAuthenticated: (state) => !!state.accessToken,
    currentUser: (state) => state.user,
  },

  actions: {
    async register(userData) {
      try {
        const response = await authAPI.register(userData)
        return response.data
      } catch (error) {
        throw error
      }
    },

    async login(credentials) {
      try {
        const response = await authAPI.login(credentials)
        this.accessToken = response.data.access
        this.refreshToken = response.data.refresh
        
        // Guardar tokens en localStorage
        localStorage.setItem('accessToken', response.data.access)
        localStorage.setItem('refreshToken', response.data.refresh)
        
        // Guardar información del usuario si viene en la respuesta
        if (response.data.user) {
          this.user = response.data.user
          localStorage.setItem('user', JSON.stringify(response.data.user))
        }
        
        return response.data
      } catch (error) {
        throw error
      }
    },

    async refreshAccessToken() {
      try {
        if (!this.refreshToken) {
          throw new Error('No refresh token available')
        }
        
        const response = await authAPI.refresh(this.refreshToken)
        this.accessToken = response.data.access
        localStorage.setItem('accessToken', response.data.access)
        
        return response.data
      } catch (error) {
        this.logout()
        throw error
      }
    },

    logout() {
      this.user = null
      this.accessToken = null
      this.refreshToken = null
      
      localStorage.removeItem('accessToken')
      localStorage.removeItem('refreshToken')
      localStorage.removeItem('user')
    },

    // Restaurar sesión desde localStorage
    restoreSession() {
      const savedUser = localStorage.getItem('user')
      if (savedUser) {
        try {
          this.user = JSON.parse(savedUser)
        } catch (e) {
          console.error('Error parsing saved user:', e)
        }
      }
    },
  },
})
