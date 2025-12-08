import axios from '@/services/api'

export default {
    async list(projectId, taskId) {
        let response = null
        await axios.get(`/api/projects/${projectId}/tasks/${taskId}/documents/`)
            .then(res => response = res)
            .catch(error => response = error.response || error)
        return response
    },

    async upload(projectId, taskId, formData) {
        let response = null
        await axios.post(`/api/projects/${projectId}/tasks/${taskId}/documents/`, formData, {
            headers: {
                'Content-Type': 'multipart/form-data'
            }
        })
            .then(res => response = res)
            .catch(error => response = error.response || error)
        return response
    },

    async delete(projectId, taskId, documentId) {
        let response = null
        await axios.delete(`/api/projects/${projectId}/tasks/${taskId}/documents/${documentId}/`)
            .then(res => response = res)
            .catch(error => response = error.response || error)
        return response
    }
}
