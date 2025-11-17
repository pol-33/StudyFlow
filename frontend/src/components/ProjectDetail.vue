<template>
  <div class="project-detail">
    <el-card v-if="projectStore.currentProject" shadow="never">
      <template #header>
        <div class="card-header">
          <div>
            <h3>{{ projectStore.currentProject.name }}</h3>
            <p class="project-description">
              {{ projectStore.currentProject.description || 'Sin descripción' }}
            </p>
          </div>
          <div class="header-actions">
            <el-button
              :icon="Edit"
              circle
              @click="handleEditProject"
            />
            <el-button
              type="danger"
              :icon="Delete"
              circle
              @click="handleDeleteProject"
            />
          </div>
        </div>
      </template>

      <!-- Task List Component -->
      <TaskList :project-id="projectStore.currentProject.id" />
    </el-card>

    <el-empty
      v-else
      description="Selecciona un proyecto del menú lateral"
      :image-size="200"
    />

    <!-- Edit Project Dialog -->
    <el-dialog
      v-model="editDialogVisible"
      title="Editar Proyecto"
      width="500px"
    >
      <el-form
        ref="editFormRef"
        :model="editForm"
        :rules="editRules"
        label-position="top"
      >
        <el-form-item label="Nombre del Proyecto" prop="name">
          <el-input v-model="editForm.name" />
        </el-form-item>

        <el-form-item label="Descripción" prop="description">
          <el-input
            v-model="editForm.description"
            type="textarea"
            :rows="4"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="editDialogVisible = false">Cancelar</el-button>
        <el-button
          type="primary"
          :loading="loading"
          @click="handleUpdateProject"
        >
          Guardar Cambios
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Edit, Delete } from '@element-plus/icons-vue'
import { useProjectStore } from '@/stores/projectStore'
import { useTaskStore } from '@/stores/taskStore'
import TaskList from './TaskList.vue'

const projectStore = useProjectStore()
const taskStore = useTaskStore()

const editDialogVisible = ref(false)
const editFormRef = ref(null)
const loading = ref(false)

const editForm = reactive({
  name: '',
  description: '',
})

const editRules = {
  name: [
    { required: true, message: 'Por favor ingresa el nombre del proyecto', trigger: 'blur' },
    { min: 3, message: 'El nombre debe tener al menos 3 caracteres', trigger: 'blur' },
  ],
}

const handleEditProject = () => {
  if (!projectStore.currentProject) return

  editForm.name = projectStore.currentProject.name
  editForm.description = projectStore.currentProject.description || ''
  editDialogVisible.value = true
}

const handleUpdateProject = async () => {
  if (!editFormRef.value || !projectStore.currentProject) return

  await editFormRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        await projectStore.updateProject(
          projectStore.currentProject.id,
          editForm
        )

        ElMessage.success('Proyecto actualizado exitosamente')
        editDialogVisible.value = false
      } catch (error) {
        console.error('Error updating project:', error)
        ElMessage.error('Error al actualizar el proyecto')
      } finally {
        loading.value = false
      }
    }
  })
}

const handleDeleteProject = async () => {
  if (!projectStore.currentProject) return

  try {
    await ElMessageBox.confirm(
      `¿Estás seguro de eliminar el proyecto "${projectStore.currentProject.name}"? Esta acción no se puede deshacer.`,
      'Confirmar eliminación',
      {
        confirmButtonText: 'Eliminar',
        cancelButtonText: 'Cancelar',
        type: 'warning',
        confirmButtonClass: 'el-button--danger',
      }
    )

    const projectId = projectStore.currentProject.id
    await projectStore.deleteProject(projectId)
    
    // Limpiar tareas del proyecto eliminado
    taskStore.clearTasks()

    ElMessage.success('Proyecto eliminado exitosamente')
  } catch (error) {
    if (error !== 'cancel') {
      console.error('Error deleting project:', error)
      ElMessage.error('Error al eliminar el proyecto')
    }
  }
}
</script>

<style scoped>
.project-detail {
  height: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.card-header h3 {
  margin: 0 0 8px 0;
  font-size: 24px;
  color: #303133;
}

.project-description {
  margin: 0;
  color: #909399;
  font-size: 14px;
}

.header-actions {
  display: flex;
  gap: 8px;
}
</style>
