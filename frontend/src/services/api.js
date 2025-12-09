import axios from 'axios'
import { useAuthStore } from '@/stores/authStore'
import router from '@/router'

axios.interceptors.request.use(
    config => {
        config.headers['Accept'] = 'application/json'
        config.headers['Content-Type'] = 'application/json'
        
        // Add auth token if logged in
        const authStore = useAuthStore()
        if (authStore.isAuthenticated) {
            config.headers['Authorization'] = 'Bearer ' + authStore.accessToken
        }
        
        // Use environment variable for API base URL
        config.baseURL = import.meta.env.VITE_API_BASE_URL
        
        return config
    },
    error => {
        return Promise.reject(error)
    }
)

axios.interceptors.response.use(
    response => {
        return response
    },
    error => {
        if (error.response && error.response.status === 401) {
            const authStore = useAuthStore()
            authStore.logout()
            router.push('/login')
        }
        return Promise.reject(error)
    }
)

export default axios
