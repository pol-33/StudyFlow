<template>
  <div class="register-container">
    <el-card class="register-card">
      <template #header>
        <div class="card-header">
          <el-icon :size="40" color="#67C23A"><UserFilled /></el-icon>
          <h2>Crear Cuenta</h2>
        </div>
      </template>

      <el-form
        ref="registerFormRef"
        :model="registerForm"
        :rules="rules"
        label-position="top"
        @submit.prevent="handleRegister"
      >
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="Nombre" prop="first_name">
              <el-input
                v-model="registerForm.first_name"
                placeholder="Tu nombre"
                size="large"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="Apellido" prop="last_name">
              <el-input
                v-model="registerForm.last_name"
                placeholder="Tu apellido"
                size="large"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="Usuario" prop="username">
          <el-input
            v-model="registerForm.username"
            placeholder="Elige un nombre de usuario"
            size="large"
          >
            <template #prefix>
              <el-icon><User /></el-icon>
            </template>
          </el-input>
        </el-form-item>

        <el-form-item label="Email" prop="email">
          <el-input
            v-model="registerForm.email"
            type="email"
            placeholder="tu@email.com"
            size="large"
          >
            <template #prefix>
              <el-icon><Message /></el-icon>
            </template>
          </el-input>
        </el-form-item>

        <el-form-item label="Contraseña" prop="password">
          <el-input
            v-model="registerForm.password"
            type="password"
            placeholder="Mínimo 6 caracteres"
            size="large"
            show-password
          >
            <template #prefix>
              <el-icon><Lock /></el-icon>
            </template>
          </el-input>
        </el-form-item>

        <el-form-item label="Confirmar Contraseña" prop="password2">
          <el-input
            v-model="registerForm.password2"
            type="password"
            placeholder="Repite tu contraseña"
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
            Registrarse
          </el-button>
        </el-form-item>
      </el-form>

      <div class="register-footer">
        <el-divider />
        <p>
          ¿Ya tienes cuenta?
          <el-link type="primary" @click="$router.push('/login')">
            Inicia sesión aquí
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
import { UserFilled, User, Message, Lock } from '@element-plus/icons-vue'
import { useAuthStore } from '@/stores/authStore'

const router = useRouter()
const authStore = useAuthStore()

const registerFormRef = ref(null)
const loading = ref(false)

const registerForm = reactive({
  username: '',
  email: '',
  password: '',
  password2: '',
  first_name: '',
  last_name: '',
})

const validatePasswordMatch = (rule, value, callback) => {
  if (value === '') {
    callback(new Error('Por favor confirma tu contraseña'))
  } else if (value !== registerForm.password) {
    callback(new Error('Las contraseñas no coinciden'))
  } else {
    callback()
  }
}

const rules = {
  first_name: [
    { required: true, message: 'Por favor ingresa tu nombre', trigger: 'blur' },
  ],
  last_name: [
    { required: true, message: 'Por favor ingresa tu apellido', trigger: 'blur' },
  ],
  username: [
    { required: true, message: 'Por favor elige un usuario', trigger: 'blur' },
    { min: 3, message: 'El usuario debe tener al menos 3 caracteres', trigger: 'blur' },
  ],
  email: [
    { required: true, message: 'Por favor ingresa tu email', trigger: 'blur' },
    { type: 'email', message: 'Por favor ingresa un email válido', trigger: 'blur' },
  ],
  password: [
    { required: true, message: 'Por favor ingresa una contraseña', trigger: 'blur' },
    { min: 6, message: 'La contraseña debe tener al menos 6 caracteres', trigger: 'blur' },
  ],
  password2: [
    { required: true, message: 'Por favor confirma tu contraseña', trigger: 'blur' },
    { validator: validatePasswordMatch, trigger: 'blur' },
  ],
}

const handleRegister = async () => {
  if (!registerFormRef.value) return

  await registerFormRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        await authStore.register(registerForm)
        
        ElMessage.success('¡Cuenta creada exitosamente! Por favor inicia sesión.')
        
        // Redirigir al login después del registro exitoso
        setTimeout(() => {
          router.push('/login')
        }, 1500)
      } catch (error) {
        console.error('Register error:', error)
        
        // Manejar errores específicos del backend
        const errorData = error.response?.data
        if (errorData) {
          if (errorData.username) {
            ElMessage.error(`Usuario: ${errorData.username[0]}`)
          } else if (errorData.email) {
            ElMessage.error(`Email: ${errorData.email[0]}`)
          } else if (errorData.password) {
            ElMessage.error(`Contraseña: ${errorData.password[0]}`)
          } else {
            ElMessage.error('Error al crear la cuenta. Por favor verifica los datos.')
          }
        } else {
          ElMessage.error('Error al crear la cuenta. Inténtalo de nuevo.')
        }
      } finally {
        loading.value = false
      }
    }
  })
}
</script>

<style scoped>
.register-container {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.register-card {
  width: 100%;
  max-width: 550px;
}

.card-header {
  text-align: center;
}

.card-header h2 {
  margin: 12px 0 0;
  color: #303133;
}

.register-footer {
  text-align: center;
}

.register-footer p {
  margin: 16px 0 8px;
  color: #606266;
}
</style>
