<template>
  <div class="dashboard-overview">
    <!-- Statistics Cards -->
    <el-row :gutter="20" class="stats-row">
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <el-icon class="stat-icon" color="#409EFF"><Folder /></el-icon>
            <div class="stat-text">
              <div class="stat-value">{{ projectStore.projects.length }}</div>
              <div class="stat-label">Total Proyectos</div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <el-icon class="stat-icon" color="#67C23A"><Select /></el-icon>
            <div class="stat-text">
              <div class="stat-value">{{ totalTasks }}</div>
              <div class="stat-label">Total Tareas</div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <el-icon class="stat-icon" color="#67C23A"><CircleCheck /></el-icon>
            <div class="stat-text">
              <div class="stat-value">{{ totalCompletedTasks }}</div>
              <div class="stat-label">Tareas Completadas</div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <el-icon class="stat-icon" color="#E6A23C"><Clock /></el-icon>
            <div class="stat-text">
              <div class="stat-value">{{ totalPendingTasks }}</div>
              <div class="stat-label">Tareas Pendientes</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- Projects Overview -->
    <el-card class="projects-overview-card" shadow="never">
      <template #header>
        <div class="card-header">
          <h2>Resumen de Proyectos</h2>
          <el-tag type="info">{{ projectStore.projects.length }} proyectos</el-tag>
        </div>
      </template>

      <div v-if="projectStore.loading" class="loading-container">
        <el-skeleton :rows="5" animated />
      </div>

      <div v-else-if="projectStore.projects.length === 0" class="empty-state">
        <el-empty description="No hay proyectos aún">
          <el-text>Crea tu primer proyecto usando el botón en la barra lateral</el-text>
        </el-empty>
      </div>

      <div v-else class="projects-grid">
        <el-card
          v-for="project in projectStore.projects"
          :key="project.id"
          class="project-card"
          shadow="hover"
          @click="selectProject(project)"
        >
          <template #header>
            <div class="project-card-header">
              <div class="project-title">
                <el-icon><Folder /></el-icon>
                <span>{{ project.name }}</span>
              </div>
              <el-tag 
                :type="getProgressTagType(project)" 
                size="small"
              >
                {{ getProjectProgress(project) }}%
              </el-tag>
            </div>
          </template>

          <div class="project-card-body">
            <p class="project-description">
              {{ project.description || 'Sin descripción' }}
            </p>

            <div class="project-stats">
              <div class="stat-item">
                <el-icon><List /></el-icon>
                <span>{{ project.tasks_count || 0 }} tareas</span>
              </div>
              <div class="stat-item">
                <el-icon color="#67C23A"><CircleCheck /></el-icon>
                <span>{{ project.completed_tasks_count || 0 }} completadas</span>
              </div>
            </div>

            <div class="progress-section">
              <div class="progress-label">
                <span>Progreso</span>
                <span class="progress-percentage">{{ getProjectProgress(project) }}%</span>
              </div>
              <el-progress
                :percentage="getProjectProgress(project)"
                :color="getProgressColor(project)"
                :stroke-width="10"
              />
            </div>

            <div class="project-date">
              <el-icon><Calendar /></el-icon>
              <span>Creado: {{ formatDate(project.created_at) }}</span>
            </div>
          </div>
        </el-card>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { ElMessage } from 'element-plus'
import { 
  Folder, 
  Select, 
  CircleCheck, 
  Clock, 
  List, 
  Calendar 
} from '@element-plus/icons-vue'
import { useProjectStore } from '@/stores/projectStore'
import { useTaskStore } from '@/stores/taskStore'

const projectStore = useProjectStore()
const taskStore = useTaskStore()

// Computed statistics
const totalTasks = computed(() => {
  return projectStore.projects.reduce((sum, project) => {
    return sum + (project.tasks_count || 0)
  }, 0)
})

const totalCompletedTasks = computed(() => {
  return projectStore.projects.reduce((sum, project) => {
    return sum + (project.completed_tasks_count || 0)
  }, 0)
})

const totalPendingTasks = computed(() => {
  return totalTasks.value - totalCompletedTasks.value
})

// Helper functions
const getProjectProgress = (project) => {
  if (!project.tasks_count || project.tasks_count === 0) return 0
  return Math.round((project.completed_tasks_count / project.tasks_count) * 100)
}

const getProgressColor = (project) => {
  const progress = getProjectProgress(project)
  if (progress === 100) return '#67C23A'
  if (progress >= 70) return '#409EFF'
  if (progress >= 40) return '#E6A23C'
  return '#F56C6C'
}

const getProgressTagType = (project) => {
  const progress = getProjectProgress(project)
  if (progress === 100) return 'success'
  if (progress >= 70) return 'primary'
  if (progress >= 40) return 'warning'
  return 'danger'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleDateString('es-ES', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const selectProject = async (project) => {
  try {
    await projectStore.selectProject(project.id)
    await taskStore.fetchTasks(project.id)
  } catch (error) {
    console.error('Error selecting project:', error)
    ElMessage.error('Error al cargar el proyecto')
  }
}
</script>

<style scoped>
.dashboard-overview {
  padding: 20px;
}

.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  border-radius: 8px;
  margin-bottom: 10px;
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 15px;
}

.stat-icon {
  font-size: 36px;
}

.stat-text {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  margin-top: 4px;
}

.projects-overview-card {
  border-radius: 8px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header h2 {
  margin: 0;
  font-size: 20px;
  color: #303133;
}

.loading-container {
  padding: 20px;
}

.empty-state {
  padding: 40px 20px;
  text-align: center;
}

.projects-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 20px;
}

.project-card {
  cursor: pointer;
  transition: all 0.3s ease;
  border-radius: 8px;
}

.project-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.project-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.project-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  font-size: 16px;
  color: #303133;
}

.project-card-body {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.project-description {
  color: #606266;
  font-size: 14px;
  margin: 0;
  line-height: 1.5;
  min-height: 42px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}

.project-stats {
  display: flex;
  gap: 16px;
  padding: 12px;
  background-color: #f5f7fa;
  border-radius: 6px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  color: #606266;
}

.progress-section {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.progress-label {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14px;
  color: #606266;
}

.progress-percentage {
  font-weight: 600;
  color: #303133;
}

.project-date {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: #909399;
  padding-top: 8px;
  border-top: 1px solid #e4e7ed;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .dashboard-overview {
    padding: 10px;
  }
  
  .projects-grid {
    grid-template-columns: 1fr;
  }
  
  .stat-value {
    font-size: 24px;
  }
  
  .stat-icon {
    font-size: 28px;
  }
}
</style>
