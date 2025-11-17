<template>
  <div class="landing-container">
    <el-container>
      <el-header class="landing-header">
        <div class="header-content">
          <h1 class="logo">
            <el-icon :size="32"><Notebook /></el-icon>
            StudyFlow
          </h1>
          <div class="header-actions">
            <el-button type="primary" @click="$router.push('/login')">
              Iniciar Sesión
            </el-button>
            <el-button @click="$router.push('/register')">
              Registrarse
            </el-button>
          </div>
        </div>
      </el-header>

      <el-main class="landing-main">
        <div class="hero-section">
          <h2 class="hero-title">Organiza tus proyectos de estudio</h2>
          <p class="hero-subtitle">
            StudyFlow te ayuda a gestionar tus proyectos académicos, tareas y documentos
            de manera eficiente y organizada.
          </p>
          <div class="hero-actions">
            <el-button type="primary" size="large" @click="$router.push('/register')">
              Comenzar Gratis
            </el-button>
            <el-button size="large" @click="$router.push('/login')">
              Iniciar Sesión
            </el-button>
          </div>
        </div>

        <div class="features-section">
          <el-row :gutter="24">
            <el-col :xs="24" :sm="8">
              <el-card shadow="hover" class="feature-card">
                <template #header>
                  <el-icon :size="40" color="#409EFF"><Folder /></el-icon>
                </template>
                <h3>Gestión de Proyectos</h3>
                <p>Organiza todos tus proyectos académicos en un solo lugar</p>
              </el-card>
            </el-col>
            <el-col :xs="24" :sm="8">
              <el-card shadow="hover" class="feature-card">
                <template #header>
                  <el-icon :size="40" color="#67C23A"><List /></el-icon>
                </template>
                <h3>Tareas Inteligentes</h3>
                <p>Crea tareas con prioridades, fechas límite y seguimiento de progreso</p>
              </el-card>
            </el-col>
            <el-col :xs="24" :sm="8">
              <el-card shadow="hover" class="feature-card">
                <template #header>
                  <el-icon :size="40" color="#E6A23C"><Document /></el-icon>
                </template>
                <h3>Documentos</h3>
                <p>Adjunta y organiza documentos relacionados con cada tarea</p>
              </el-card>
            </el-col>
          </el-row>
        </div>
      </el-main>

      <el-footer class="landing-footer">
        <p>&copy; 2025 StudyFlow. Todos los derechos reservados.</p>
      </el-footer>
    </el-container>
  </div>
</template>

<script setup>
import { Notebook, Folder, List, Document } from '@element-plus/icons-vue'
</script>

<style scoped>
.landing-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.landing-header {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  padding: 0;
}

.header-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  height: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.logo {
  color: white;
  font-size: 24px;
  font-weight: bold;
  display: flex;
  align-items: center;
  gap: 10px;
  margin: 0;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.landing-main {
  max-width: 1200px;
  margin: 0 auto;
  padding: 60px 20px;
}

.hero-section {
  text-align: center;
  color: white;
  margin-bottom: 80px;
}

.hero-title {
  font-size: 48px;
  font-weight: bold;
  margin-bottom: 20px;
  line-height: 1.2;
}

.hero-subtitle {
  font-size: 20px;
  margin-bottom: 40px;
  opacity: 0.9;
  max-width: 600px;
  margin-left: auto;
  margin-right: auto;
}

.hero-actions {
  display: flex;
  gap: 16px;
  justify-content: center;
}

.features-section {
  margin-top: 60px;
}

.feature-card {
  text-align: center;
  margin-bottom: 20px;
}

.feature-card h3 {
  margin: 16px 0 12px;
  font-size: 20px;
}

.feature-card p {
  color: #666;
  line-height: 1.6;
}

.landing-footer {
  background: rgba(0, 0, 0, 0.2);
  text-align: center;
  color: white;
  padding: 20px;
}

@media (max-width: 768px) {
  .hero-title {
    font-size: 32px;
  }

  .hero-subtitle {
    font-size: 16px;
  }

  .hero-actions {
    flex-direction: column;
    align-items: center;
  }

  .hero-actions .el-button {
    width: 200px;
  }
}
</style>
