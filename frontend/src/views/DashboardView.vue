<template>
  <AppLayout :page-title="pageTitle">
    <ProjectDetail />
  </AppLayout>
</template>

<script setup>
import { computed } from 'vue'
import { useProjectStore } from '@/stores/projectStore'
import AppLayout from '@/components/AppLayout.vue'
import ProjectDetail from '@/components/ProjectDetail.vue'

const projectStore = useProjectStore()

const pageTitle = computed(() => {
  if (projectStore.currentProject) {
    return projectStore.currentProject.name
  }
  return 'Dashboard - StudyFlow'
})
</script>

<style scoped>
/* Estilos específicos del dashboard si se necesitan */
</style>
