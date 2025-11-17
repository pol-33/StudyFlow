<template>
  <div class="login-container">
    <el-card class="login-card">
      <template #header>
        <div class="card-header">
          <el-icon :size="40" color="#409EFF"><User /></el-icon>
          <h2>Iniciar Sesión</h2>
        </div>
      </template>

      <el-form
        ref="loginFormRef"
        :model="loginForm"
        :rules="rules"
        label-position="top"
        @submit.prevent="handleLogin"
      >
        <el-form-item label="Usuario" prop="username">
          <el-input
            v-model="loginForm.username"
            placeholder="Ingresa tu usuario"
            size="large"
          >
            <template #prefix>
              <el-icon><User /></el-icon>
            </template>
          </el-input>
        </el-form-item>

        <el-form-item label="Contraseña" prop="password">
          <el-input
            v-model="loginForm.password"
            type="password"
            placeholder="Ingresa tu contraseña"
            size="large"
            show-password
          >
            <template #prefix>
              <el-icon><Lock /></el-icon>
            </template>
          </el-input>
        </el-form-item>

        <el-form-item>
          <el-button
            type="primary"
            size="large"
            :loading="loading"
            native-type="submit"
            style="width: 100%"
          >
            Iniciar Sesión
          </el-button>
        </el-form-item>
      </el-form>

      <div class="login-footer">
        <el-divider />
        <p>
          ¿No tienes cuenta?
          <el-link type="primary" @click="$router.push('/register')">
            Regístrate aquí
          </el-link>
        </p>
        <el-link @click="$router.push('/')">Volver al inicio</el-link>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock } from '@element-plus/icons-vue'
import { useAuthStore } from '@/stores/authStore'
import { useProjectStore } from '@/stores/projectStore'

const router = useRouter()
const authStore = useAuthStore()
const projectStore = useProjectStore()

const loginFormRef = ref(null)
const loading = ref(false)

const loginForm = reactive({
  username: '',
  password: '',
})

const rules = {
  username: [
    { required: true, message: 'Por favor ingresa tu usuario', trigger: 'blur' },
  ],
  password: [
    { required: true, message: 'Por favor ingresa tu contraseña', trigger: 'blur' },
    { min: 6, message: 'La contraseña debe tener al menos 6 caracteres', trigger: 'blur' },
  ],
}

const handleLogin = async () => {
  if (!loginFormRef.value) return

  await loginFormRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        await authStore.login(loginForm)
        
        ElMessage.success('¡Bienvenido a StudyFlow!')
        
        // Cargar proyectos iniciales
        await projectStore.fetchProjects()
        
        router.push('/dashboard')
      } catch (error) {
        console.error('Login error:', error)
        ElMessage.error(
          error.response?.data?.detail || 
          'Error al iniciar sesión. Verifica tus credenciales.'
        )
      } finally {
        loading.value = false
      }
    }
  })
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.login-card {
  width: 100%;
  max-width: 450px;
}

.card-header {
  text-align: center;
}

.card-header h2 {
  margin: 12px 0 0;
  color: #303133;
}

.login-footer {
  text-align: center;
}

.login-footer p {
  margin: 16px 0 8px;
  color: #606266;
}
</style>
