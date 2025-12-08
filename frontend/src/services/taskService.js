import axios from '@/services/api'

export default {
    async list(projectId) {
        let response = null
        await axios.get(`/api/projects/${projectId}/tasks/`)
            .then(res => response = res)
            .catch(error => response = error.response || error)
        return response
    },

    async create(projectId, taskData) {
        let response = null
        await axios.post(`/api/projects/${projectId}/tasks/`, taskData)
            .then(res => response = res)
            .catch(error => response = error.response || error)
        return response
    },

    async get(projectId, taskId) {
        let response = null
        await axios.get(`/api/projects/${projectId}/tasks/${taskId}/`)
            .then(res => response = res)
            .catch(error => response = error.response || error)
        return response
    },

    async update(projectId, taskId, taskData) {
        let response = null
        await axios.patch(`/api/projects/${projectId}/tasks/${taskId}/`, taskData)
            .then(res => response = res)
            .catch(error => response = error.response || error)
        return response
    },

    async delete(projectId, taskId) {
        let response = null
        await axios.delete(`/api/projects/${projectId}/tasks/${taskId}/`)
            .then(res => response = res)
            .catch(error => response = error.response || error)
        return response
    }
}
