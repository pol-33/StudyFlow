<template>
  <div class="project-list">
    <!-- Botón para crear nuevo proyecto -->
    <div v-show="!isCollapse" class="project-list-header">
      <el-button
        type="primary"
        :icon="Plus"
        size="small"
        style="width: 100%"
        @click="dialogVisible = true"
      >
        Nuevo Proyecto
      </el-button>
    </div>

    <el-tooltip v-show="isCollapse" content="Nuevo Proyecto" placement="right">
      <el-button
        type="primary"
        :icon="Plus"
        circle
        size="small"
        style="margin: 12px auto; display: block"
        @click="dialogVisible = true"
      />
    </el-tooltip>

    <!-- Lista de proyectos -->
    <div class="project-items">
      <el-menu-item
        v-for="project in projectStore.projects"
        :key="project.id"
        :index="`project-${project.id}`"
        @click="selectProject(project)"
        :class="{ 'is-active': projectStore.currentProject?.id === project.id }"
      >
        <el-icon><Folder /></el-icon>
        <span>{{ project.name }}</span>
        <!-- Progress bar for every project using tasks_count and completed_tasks_count -->
        <template v-if="project.tasks_count > 0">
          <el-progress
            :percentage="Math.round((project.completed_tasks_count / project.tasks_count) * 100)"
            :stroke-width="8"
            status="success"
            style="margin-top: 4px; width: 90%; margin-left: 5%;"
            :show-text="false"
          />
        </template>
      </el-menu-item>

      <el-empty
        v-if="projectStore.projects.length === 0 && !isCollapse"
        description="No hay proyectos"
        :image-size="60"
      />
    </div>

    <!-- Diálogo para crear proyecto -->
    <el-dialog
      v-model="dialogVisible"
      title="Crear Nuevo Proyecto"
      width="500px"
    >
      <el-form
        ref="projectFormRef"
        :model="projectForm"
        :rules="projectRules"
        label-position="top"
      >
        <el-form-item label="Nombre del Proyecto" prop="name">
          <el-input
            v-model="projectForm.name"
            placeholder="Ej: Proyecto de Matemáticas"
          />
        </el-form-item>

        <el-form-item label="Descripción" prop="description">
          <el-input
            v-model="projectForm.description"
            type="textarea"
            :rows="4"
            placeholder="Describe brevemente tu proyecto..."
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">Cancelar</el-button>
        <el-button
          type="primary"
          :loading="loading"
          @click="handleCreateProject"
        >
          Crear Proyecto
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus, Folder } from '@element-plus/icons-vue'
import { useProjectStore } from '@/stores/projectStore'
import { useTaskStore } from '@/stores/taskStore'

const props = defineProps({
  isCollapse: {
    type: Boolean,
    default: false,
  },
})

const emit = defineEmits(['project-selected'])

const projectStore = useProjectStore()
const taskStore = useTaskStore()

const dialogVisible = ref(false)
const projectFormRef = ref(null)
const loading = ref(false)

const projectForm = reactive({
  name: '',
  description: '',
})

const projectRules = {
  name: [
    { required: true, message: 'Por favor ingresa el nombre del proyecto', trigger: 'blur' },
    { min: 3, message: 'El nombre debe tener al menos 3 caracteres', trigger: 'blur' },
  ],
}

const selectProject = async (project) => {
  try {
    await projectStore.selectProject(project.id)
    // Cargar tareas del proyecto seleccionado
    await taskStore.fetchTasks(project.id)
    emit('project-selected', project)
  } catch (error) {
    console.error('Error selecting project:', error)
    ElMessage.error('Error al cargar el proyecto')
  }
}

const handleCreateProject = async () => {
  if (!projectFormRef.value) return

  await projectFormRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        const newProject = await projectStore.createProject(projectForm)
        
        ElMessage.success('Proyecto creado exitosamente')
        
        // Resetear formulario
        projectForm.name = ''
        projectForm.description = ''
        dialogVisible.value = false
        
        // Seleccionar el nuevo proyecto
        await selectProject(newProject)
      } catch (error) {
        console.error('Error creating project:', error)
        ElMessage.error('Error al crear el proyecto')
      } finally {
        loading.value = false
      }
    }
  })
}

onMounted(async () => {
  // Cargar proyectos si aún no se han cargado
  if (projectStore.projects.length === 0) {
    try {
      await projectStore.fetchProjects()
    } catch (error) {
      console.error('Error loading projects:', error)
    }
  }
})
</script>

<style scoped>
.project-list {
  padding: 0;
}

.project-list-header {
  padding: 12px 16px;
}

.project-items {
  max-height: calc(100vh - 350px);
  overflow-y: auto;
}

.is-active {
  background-color: #ecf5ff;
}
</style>
