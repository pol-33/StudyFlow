import axios from '@/services/api'

export default {
    async list() {
        let response = null
        await axios.get('/api/projects/')
            .then(res => response = res)
            .catch(error => response = error.response || error)
        return response
    },

    async create(projectData) {
        let response = null
        await axios.post('/api/projects/', projectData)
            .then(res => response = res)
            .catch(error => response = error.response || error)
        return response
    },

    async get(projectId) {
        let response = null
        await axios.get(`/api/projects/${projectId}/`)
            .then(res => response = res)
            .catch(error => response = error.response || error)
        return response
    },

    async update(projectId, projectData) {
        let response = null
        await axios.patch(`/api/projects/${projectId}/`, projectData)
            .then(res => response = res)
            .catch(error => response = error.response || error)
        return response
    },

    async delete(projectId) {
        let response = null
        await axios.delete(`/api/projects/${projectId}/`)
            .then(res => response = res)
            .catch(error => response = error.response || error)
        return response
    }
}
