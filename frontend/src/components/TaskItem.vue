<template>
  <el-card class="task-item" :class="taskClass" shadow="hover">
    <div class="task-content">
      <!-- Checkbox para completar -->
      <el-checkbox
        :model-value="task.is_completed"
        @change="handleToggleComplete"
        size="large"
      />

      <!-- Información de la tarea -->
      <div class="task-info" @click="showDetails = !showDetails">
        <div class="task-header">
          <h4 :class="{ 'task-completed': task.is_completed }">
            {{ task.title }}
          </h4>
          <el-tag
            :type="priorityType"
            size="small"
            effect="plain"
          >
            {{ priorityLabel }}
          </el-tag>
        </div>

        <p v-if="task.description" class="task-description">
          {{ task.description }}
        </p>

        <div class="task-meta">
          <el-icon><Calendar /></el-icon>
          <span v-if="task.due_date">
            {{ formatDate(task.due_date) }}
          </span>
          <span v-else class="text-muted">Sin fecha límite</span>

          <el-icon style="margin-left: 16px"><Files /></el-icon>
          <span>{{ documentCount }} documentos</span>
        </div>
      </div>

      <!-- Acciones -->
      <div class="task-actions">
        <el-dropdown @command="handleActionCommand">
          <el-button :icon="More" circle />
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="edit">
                <el-icon><Edit /></el-icon>
                Editar
              </el-dropdown-item>
              <el-dropdown-item command="documents">
                <el-icon><Document /></el-icon>
                Documentos
              </el-dropdown-item>
              <el-dropdown-item command="delete" divided>
                <el-icon><Delete /></el-icon>
                Eliminar
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>

    <!-- Detalles expandibles -->
    <el-collapse-transition>
      <div v-show="showDetails" class="task-details">
        <el-divider />
        <div class="detail-row">
          <strong>Estado:</strong>
          <span>{{ task.is_completed ? 'Completada' : 'Pendiente' }}</span>
        </div>
        <div class="detail-row">
          <strong>Creada:</strong>
          <span>{{ formatDate(task.created_at) }}</span>
        </div>
        <div v-if="task.updated_at" class="detail-row">
          <strong>Actualizada:</strong>
          <span>{{ formatDate(task.updated_at) }}</span>
        </div>
      </div>
    </el-collapse-transition>

    <!-- Edit Dialog -->
    <el-dialog
      v-model="editDialogVisible"
      title="Editar Tarea"
      width="600px"
      append-to-body="false"
    >
      <el-form
        ref="editFormRef"
        :model="editForm"
        :rules="editRules"
        label-position="top"
      >
        <el-form-item label="Título" prop="title">
          <el-input v-model="editForm.title" />
        </el-form-item>

        <el-form-item label="Descripción" prop="description">
          <el-input
            v-model="editForm.description"
            type="textarea"
            :rows="4"
          />
        </el-form-item>

        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="Prioridad" prop="priority">
              <el-select
                v-model="editForm.priority"
                style="width: 100%"
              >
                <el-option label="Baja" value="Low" />
                <el-option label="Media" value="Medium" />
                <el-option label="Alta" value="High" />
              </el-select>
            </el-form-item>
          </el-col>

          <el-col :span="12">
            <el-form-item label="Fecha Límite" prop="due_date">
              <el-date-picker
                v-model="editForm.due_date"
                type="datetime"
                placeholder="Selecciona fecha"
                format="DD/MM/YYYY HH:mm"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>

      <template #footer>
        <el-button @click="editDialogVisible = false">Cancelar</el-button>
        <el-button
          type="primary"
          :loading="loading"
          @click="handleUpdateTask"
        >
          Guardar Cambios
        </el-button>
      </template>
    </el-dialog>

    <!-- Documents Dialog -->
    <el-dialog
      v-model="documentsDialogVisible"
      title="Documentos de la Tarea"
      width="700px"
      append-to-body="false"
    >
      <DocumentManager
        :project-id="projectId"
        :task-id="task.id"
        @documents-updated="handleDocumentsUpdated"
      />
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, reactive, computed, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Calendar,
  Files,
  More,
  Edit,
  Delete,
  Document,
} from '@element-plus/icons-vue'
import { useTaskStore } from '@/stores/taskStore'
import DocumentManager from './DocumentManager.vue'

const props = defineProps({
  task: {
    type: Object,
    required: true,
  },
  projectId: {
    type: Number,
    required: true,
  },
})

const emit = defineEmits(['task-updated', 'task-deleted'])

const taskStore = useTaskStore()

const showDetails = ref(false)
const editDialogVisible = ref(false)
const documentsDialogVisible = ref(false)
const editFormRef = ref(null)
const loading = ref(false)
const documentCount = ref(0)

const editForm = reactive({
  title: '',
  description: '',
  priority: 'Medium',
  due_date: null,
})

const editRules = {
  title: [
    { required: true, message: 'El título es requerido', trigger: 'blur' },
    { min: 3, message: 'Mínimo 3 caracteres', trigger: 'blur' },
  ],
  priority: [
    { required: true, message: 'La prioridad es requerida', trigger: 'change' },
  ],
}

const taskClass = computed(() => ({
  'task-completed-card': props.task.is_completed,
  'task-high-priority': props.task.priority === 'High' && !props.task.is_completed,
}))

const priorityType = computed(() => {
  const types = {
    Low: 'info',
    Medium: 'warning',
    High: 'danger',
  }
  return types[props.task.priority] || 'info'
})

const priorityLabel = computed(() => {
  const labels = {
    Low: 'Baja',
    Medium: 'Media',
    High: 'Alta',
  }
  return labels[props.task.priority] || props.task.priority
})

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleString('es-ES', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

const handleToggleComplete = async (value) => {
  try {
    await taskStore.toggleTaskCompletion(props.projectId, props.task.id, value)
    emit('task-updated', props.task)
  } catch (error) {
    console.error('Error toggling task:', error)
    ElMessage.error('Error al actualizar el estado de la tarea')
  }
}

const handleActionCommand = (command) => {
  switch (command) {
    case 'edit':
      handleEdit()
      break
    case 'documents':
      handleDocuments()
      break
    case 'delete':
      handleDelete()
      break
  }
}

const handleEdit = () => {
  editForm.title = props.task.title
  editForm.description = props.task.description || ''
  editForm.priority = props.task.priority
  editForm.due_date = props.task.due_date ? new Date(props.task.due_date) : null
  editDialogVisible.value = true
}

const handleUpdateTask = async () => {
  if (!editFormRef.value) return

  await editFormRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        const taskData = {
          ...editForm,
          due_date: editForm.due_date
            ? new Date(editForm.due_date).toISOString()
            : null,
        }

        await taskStore.updateTask(props.projectId, props.task.id, taskData)
        
        ElMessage.success('Tarea actualizada exitosamente')
        editDialogVisible.value = false
        emit('task-updated', props.task)
      } catch (error) {
        console.error('Error updating task:', error)
        ElMessage.error('Error al actualizar la tarea')
      } finally {
        loading.value = false
      }
    }
  })
}

const handleDocuments = async () => {
  try {
    // Cargar documentos de la tarea
    const documents = await taskStore.fetchDocuments(props.projectId, props.task.id)
    documentCount.value = documents.length
    documentsDialogVisible.value = true
  } catch (error) {
    console.error('Error loading documents:', error)
    ElMessage.error('Error al cargar los documentos')
  }
}

const handleDocumentsUpdated = (count) => {
  documentCount.value = count
}

const handleDelete = async () => {
  try {
    await ElMessageBox.confirm(
      `¿Estás seguro de eliminar la tarea "${props.task.title}"?`,
      'Confirmar eliminación',
      {
        confirmButtonText: 'Eliminar',
        cancelButtonText: 'Cancelar',
        type: 'warning',
      }
    )

    await taskStore.deleteTask(props.projectId, props.task.id)
    emit('task-deleted', props.task.id)
  } catch (error) {
    if (error !== 'cancel') {
      console.error('Error deleting task:', error)
      ElMessage.error('Error al eliminar la tarea')
    }
  }
}

// Cargar documentos inicialmente
watch(
  () => props.task.id,
  async () => {
    try {
      const documents = await taskStore.fetchDocuments(props.projectId, props.task.id)
      documentCount.value = documents.length
    } catch (error) {
      documentCount.value = 0
    }
  },
  { immediate: true }
)
</script>

<style scoped>
.task-item {
  cursor: pointer;
  transition: all 0.3s;
}

.task-item:hover {
  transform: translateY(-2px);
}

.task-completed-card {
  background-color: #f5f7fa;
  opacity: 0.8;
}

.task-high-priority {
  border-left: 4px solid #f56c6c;
}

.task-content {
  display: flex;
  align-items: flex-start;
  gap: 16px;
}

.task-info {
  flex: 1;
}

.task-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.task-header h4 {
  margin: 0;
  font-size: 16px;
  color: #303133;
}

.task-completed {
  text-decoration: line-through;
  color: #909399;
}

.task-description {
  margin: 8px 0;
  color: #606266;
  font-size: 14px;
}

.task-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #909399;
}

.text-muted {
  color: #c0c4cc;
}

.task-actions {
  display: flex;
  gap: 8px;
}

.task-details {
  margin-top: 16px;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  font-size: 14px;
}

.detail-row strong {
  color: #606266;
}

.detail-row span {
  color: #909399;
}
</style>
