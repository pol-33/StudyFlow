<template>
  <AppLayout :page-title="pageTitle">
    <!-- Show overview when no project is selected, otherwise show project detail -->
    <DashboardOverview v-if="!projectStore.currentProject" />
    <ProjectDetail v-else />
  </AppLayout>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useProjectStore } from '@/stores/projectStore'
import AppLayout from '@/components/AppLayout.vue'
import DashboardOverview from '@/components/DashboardOverview.vue'
import ProjectDetail from '@/components/ProjectDetail.vue'

const projectStore = useProjectStore()

const pageTitle = computed(() => {
  if (projectStore.currentProject) {
    return projectStore.currentProject.name
  }
  return 'Dashboard - StudyFlow'
})

// Load projects on mount
onMounted(async () => {
  if (projectStore.projects.length === 0) {
    try {
      await projectStore.fetchProjects()
    } catch (error) {
      console.error('Error loading projects:', error)
      ElMessage.error('Error al cargar los proyectos')
    }
  }
})
</script>

<style scoped>
/* Dashboard view wrapper styles if needed */
</style>
