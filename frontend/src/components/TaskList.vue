<template>
  <div class="task-list">
    <!-- Header con botón de crear tarea -->
    <div class="task-list-header">
      <el-button
        type="primary"
        :icon="Plus"
        @click="dialogVisible = true"
      >
        Nueva Tarea
      </el-button>

      <el-radio-group v-model="filterStatus" size="small">
        <el-radio-button label="all">Todas</el-radio-button>
        <el-radio-button label="pending">Pendientes</el-radio-button>
        <el-radio-button label="completed">Completadas</el-radio-button>
      </el-radio-group>
    </div>

    <!-- Lista de tareas -->
    <div class="tasks-container">
      <el-empty
        v-if="filteredTasks.length === 0"
        :description="
          filterStatus === 'all'
            ? 'No hay tareas en este proyecto'
            : filterStatus === 'pending'
            ? 'No hay tareas pendientes'
            : 'No hay tareas completadas'
        "
        :image-size="120"
      />

      <TaskItem
        v-for="task in filteredTasks"
        :key="task.id"
        :task="task"
        :project-id="projectId"
        @task-updated="handleTaskUpdated"
        @task-deleted="handleTaskDeleted"
      />
    </div>

    <!-- Dialog para crear tarea -->
    <el-dialog
      v-model="dialogVisible"
      title="Crear Nueva Tarea"
      width="600px"
    >
      <el-form
        ref="taskFormRef"
        :model="taskForm"
        :rules="taskRules"
        label-position="top"
      >
        <el-form-item label="Título" prop="title">
          <el-input
            v-model="taskForm.title"
            placeholder="Título de la tarea"
          />
        </el-form-item>

        <el-form-item label="Descripción" prop="description">
          <el-input
            v-model="taskForm.description"
            type="textarea"
            :rows="4"
            placeholder="Describe la tarea..."
          />
        </el-form-item>

        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="Prioridad" prop="priority">
              <el-select
                v-model="taskForm.priority"
                placeholder="Selecciona prioridad"
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
                v-model="taskForm.due_date"
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
        <el-button @click="dialogVisible = false">Cancelar</el-button>
        <el-button
          type="primary"
          :loading="loading"
          @click="handleCreateTask"
        >
          Crear Tarea
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { useTaskStore } from '@/stores/taskStore'
import TaskItem from './TaskItem.vue'

const props = defineProps({
  projectId: {
    type: Number,
    required: true,
  },
})

const taskStore = useTaskStore()

const dialogVisible = ref(false)
const taskFormRef = ref(null)
const loading = ref(false)
const filterStatus = ref('all')

const taskForm = reactive({
  title: '',
  description: '',
  priority: 'Medium',
  due_date: null,
})

const taskRules = {
  title: [
    { required: true, message: 'Por favor ingresa el título de la tarea', trigger: 'blur' },
    { min: 3, message: 'El título debe tener al menos 3 caracteres', trigger: 'blur' },
  ],
  priority: [
    { required: true, message: 'Por favor selecciona una prioridad', trigger: 'change' },
  ],
}

const filteredTasks = computed(() => {
  if (filterStatus.value === 'pending') {
    return taskStore.pendingTasks
  } else if (filterStatus.value === 'completed') {
    return taskStore.completedTasks
  }
  return taskStore.allTasks
})

const handleCreateTask = async () => {
  if (!taskFormRef.value) return

  await taskFormRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        // Formatear fecha si existe
        const taskData = {
          ...taskForm,
          due_date: taskForm.due_date
            ? new Date(taskForm.due_date).toISOString()
            : null,
        }

        await taskStore.createTask(props.projectId, taskData)

        ElMessage.success('Tarea creada exitosamente')

        // Resetear formulario
        taskForm.title = ''
        taskForm.description = ''
        taskForm.priority = 'Medium'
        taskForm.due_date = null
        dialogVisible.value = false
      } catch (error) {
        console.error('Error creating task:', error)
        ElMessage.error('Error al crear la tarea')
      } finally {
        loading.value = false
      }
    }
  })
}

const handleTaskUpdated = (updatedTask) => {
}

const handleTaskDeleted = (taskId) => {
}

// Recargar tareas cuando cambia el proyecto
watch(
  () => props.projectId,
  async (newProjectId) => {
    if (newProjectId) {
      try {
        await taskStore.fetchTasks(newProjectId)
      } catch (error) {
        console.error('Error loading tasks:', error)
      }
    }
  },
  { immediate: true }
)
</script>

<style scoped>
.task-list {
  margin-top: 24px;
}

.task-list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.tasks-container {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
</style>
