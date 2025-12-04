<template>
  <el-container class="app-layout">
    <!-- Menú Lateral -->
    <el-aside :width="isCollapse ? '64px' : '250px'" class="app-aside">
      <div class="aside-header">
        <h1 v-show="!isCollapse" class="logo">
          <el-icon :size="24"><Notebook /></el-icon>
          StudyFlow
        </h1>
        <el-icon v-show="isCollapse" :size="24"><Notebook /></el-icon>
      </div>

      <el-menu
        :default-active="activeMenu"
        :collapse="isCollapse"
        class="aside-menu"
      >
        <el-menu-item index="dashboard" @click="handleMenuClick('dashboard')">
          <el-icon><HomeFilled /></el-icon>
          <span>Dashboard</span>
        </el-menu-item>

        <el-divider v-show="!isCollapse" content-position="left">
          <span style="font-size: 12px; color: #909399">PROYECTOS</span>
        </el-divider>

        <ProjectList :is-collapse="isCollapse" />
      </el-menu>

      <div class="aside-footer">
        <el-button
          :icon="isCollapse ? Expand : Fold"
          circle
          @click="isCollapse = !isCollapse"
        />
      </div>
    </el-aside>

    <!-- Contenido Principal -->
    <el-container>
      <!-- Header -->
      <el-header class="app-header">
        <div class="header-content">
          <div class="header-left">
            <el-button
              v-if="projectStore.currentProject"
              :icon="ArrowLeft"
              @click="goBackToDashboard"
              text
            >
              Volver al Dashboard
            </el-button>
            <h2 class="page-title">{{ pageTitle }}</h2>
          </div>
          <div class="header-actions">
            <el-dropdown @command="handleUserMenuCommand">
              <el-button circle>
                <el-icon><User /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item disabled>
                    {{ authStore.user?.username || 'Usuario' }}
                  </el-dropdown-item>
                  <el-dropdown-item divided command="logout">
                    <el-icon><SwitchButton /></el-icon>
                    Cerrar Sesión
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </div>
      </el-header>

      <!-- Main Content -->
      <el-main class="app-main">
        <slot />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Notebook,
  HomeFilled,
  User,
  SwitchButton,
  Expand,
  Fold,
  ArrowLeft,
} from '@element-plus/icons-vue'
import { useAuthStore } from '@/stores/authStore'
import { useProjectStore } from '@/stores/projectStore'
import { useTaskStore } from '@/stores/taskStore'
import ProjectList from './ProjectList.vue'

const props = defineProps({
  pageTitle: {
    type: String,
    default: 'Dashboard',
  },
})

const router = useRouter()
const authStore = useAuthStore()
const projectStore = useProjectStore()
const taskStore = useTaskStore()

const isCollapse = ref(false)
const activeMenu = ref('dashboard')

const handleMenuClick = (menu) => {
  activeMenu.value = menu
  if (menu === 'dashboard') {
    goBackToDashboard()
  }
}

const goBackToDashboard = () => {
  projectStore.clearCurrentProject()
  taskStore.clearTasks()
}

const handleUserMenuCommand = async (command) => {
  if (command === 'logout') {
    try {
      await ElMessageBox.confirm(
        '¿Estás seguro de que deseas cerrar sesión?',
        'Confirmar',
        {
          confirmButtonText: 'Sí, cerrar sesión',
          cancelButtonText: 'Cancelar',
          type: 'warning',
        }
      )

      // Limpiar stores
      projectStore.clearProjects()
      taskStore.clearTasks()
      authStore.logout()

      ElMessage.success('Sesión cerrada correctamente')
      router.push('/login')
    } catch {
      // Usuario canceló
    }
  }
}
</script>

<style scoped>
.app-layout {
  height: 100vh;
}

.app-aside {
  background: #fff;
  border-right: 1px solid #e4e7ed;
  display: flex;
  flex-direction: column;
  transition: width 0.3s;
}

.aside-header {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 1px solid #e4e7ed;
}

.logo {
  margin: 0;
  font-size: 20px;
  font-weight: bold;
  color: #409eff;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.aside-menu {
  flex: 1;
  border-right: none;
  overflow-y: auto;
}

.aside-footer {
  padding: 16px;
  border-top: 1px solid #e4e7ed;
  display: flex;
  justify-content: center;
}

.app-header {
  background: #fff;
  border-bottom: 1px solid #e4e7ed;
  padding: 0 24px;
}

.header-content {
  height: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.page-title {
  margin: 0;
  font-size: 20px;
  color: #303133;
}

.header-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

.app-main {
  background: #f5f7fa;
  padding: 24px;
  overflow-y: auto;
}
</style>
