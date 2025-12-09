<template>
  <div class="settings-page">
    <div class="settings-header">
      <el-page-header @back="goBack">
        <template #content>
          <span class="text-large font-600 mr-3"> Configuración </span>
        </template>
      </el-page-header>
    </div>

    <div class="settings-content">
      <el-card class="settings-card">
        <template #header>
          <div class="card-header">
            <span>Perfil de Usuario</span>
          </div>
        </template>
        
        <el-form
          ref="formRef"
          :model="form"
          :rules="rules"
          label-position="top"
          v-loading="loading"
        >
          <el-form-item label="Nombre de Usuario" prop="username">
            <el-input v-model="form.username" />
          </el-form-item>
          
          <el-form-item label="Correo Electrónico" prop="email">
            <el-input v-model="form.email" />
          </el-form-item>
          
          <el-divider />
          
          <div class="notification-section">
            <h3>Notificaciones</h3>
            <el-form-item>
              <div class="switch-container">
                <span>Recibir notificaciones por correo electrónico</span>
                <el-switch v-model="form.email_notifications_enabled" />
              </div>
              <p class="help-text">
                Te enviaremos un correo cuando tus tareas estén próximas a vencer (24h antes).
              </p>
            </el-form-item>
          </div>
          
          <el-form-item class="actions">
            <el-button @click="goBack">Cancelar</el-button>
            <el-button type="primary" @click="saveSettings">Guardar Cambios</el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import authService from '@/services/authService'
import { useAuthStore } from '@/stores/authStore'

const router = useRouter()
const authStore = useAuthStore()
const loading = ref(false)
const formRef = ref(null)

const form = ref({
  username: '',
  email: '',
  email_notifications_enabled: true
})

const rules = {
  username: [
    { required: true, message: 'Por favor ingresa tu nombre de usuario', trigger: 'blur' },
    { min: 3, message: 'El nombre de usuario debe tener al menos 3 caracteres', trigger: 'blur' }
  ],
  email: [
    { required: true, message: 'Por favor ingresa tu correo electrónico', trigger: 'blur' },
    { type: 'email', message: 'Por favor ingresa un correo válido', trigger: 'blur' }
  ]
}

const goBack = () => {
  router.push('/dashboard')
}

const fetchSettings = async () => {
  loading.value = true
  const response = await authService.getSettings()
  loading.value = false
  if (response.status >= 200 && response.status < 300) {
    form.value = {
      username: response.data.username,
      email: response.data.email,
      email_notifications_enabled: response.data.email_notifications_enabled
    }
  } else {
    ElMessage.error('Error al cargar la configuración')
    console.error(response)
  }
}

const saveSettings = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      const response = await authService.updateSettings(form.value)
      loading.value = false
      if (response.status >= 200 && response.status < 300) {
        ElMessage.success('Configuración actualizada correctamente')
        
        // Update auth store if username changed
        if (authStore.user) {
          authStore.user.username = response.data.username
          authStore.user.email = response.data.email
        }
      } else {
        ElMessage.error('Error al guardar la configuración')
        console.error(response)
      }
    }
  })
}

onMounted(() => {
  fetchSettings()
})
</script>

<style scoped>
.settings-page {
  min-height: 100vh;
  background-color: #f5f7fa;
}

.settings-header {
  background-color: #fff;
  padding: 16px 24px;
  border-bottom: 1px solid #e4e7ed;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.settings-content {
  max-width: 800px;
  margin: 40px auto;
  padding: 0 20px;
}

.settings-card {
  border-radius: 8px;
}

.card-header {
  font-weight: bold;
  font-size: 18px;
}

.notification-section h3 {
  margin-top: 0;
  margin-bottom: 16px;
  font-size: 16px;
  color: #303133;
}

.switch-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.help-text {
  font-size: 12px;
  color: #909399;
  margin-top: 8px;
  line-height: 1.4;
}

.actions {
  margin-top: 32px;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}
</style>
