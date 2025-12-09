import axios from '@/services/api'

export default {
    async register(userData) {
        let response = null
        await axios.post('/api/auth/register/', userData)
            .then(res => response = res)
            .catch(error => response = error.response || error)
        return response
    },

    async login(username, password) {
        const data = {
            username: username,
            password: password
        }
        let response = null
        await axios.post('/api/auth/token/', data)
            .then(res => response = res)
            .catch(error => response = error.response || error)
        return response
    },

    async refresh(refreshToken) {
        let response = null
        await axios.post('/api/auth/token/refresh/', { refresh: refreshToken })
            .then(res => response = res)
            .catch(error => response = error.response || error)
        return response
    },

    async getSettings() {
        let response = null
        await axios.get('/api/auth/settings/')
            .then(res => response = res)
            .catch(error => response = error.response || error)
        return response
    },

    async updateSettings(settingsData) {
        let response = null
        await axios.put('/api/auth/settings/', settingsData)
            .then(res => response = res)
            .catch(error => response = error.response || error)
        return response
    }
}
