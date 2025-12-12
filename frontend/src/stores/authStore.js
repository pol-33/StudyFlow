import { defineStore } from 'pinia'
import authService from '@/services/authService'

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
      const response = await authService.register(userData)
      if (response.status >= 200 && response.status < 300) {
        return response.data
      }
      throw response
    },

    async login(username, password) {
      const response = await authService.login(username, password)
      if (response.status >= 200 && response.status < 300) {
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
      }
      throw response
    },

    async refreshAccessToken() {
      if (!this.refreshToken) {
        throw new Error('No refresh token available')
      }
      
      const response = await authService.refresh(this.refreshToken)
      if (response.status >= 200 && response.status < 300) {
        this.accessToken = response.data.access
        localStorage.setItem('accessToken', response.data.access)
        return response.data
      }
      this.logout()
      throw response
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
