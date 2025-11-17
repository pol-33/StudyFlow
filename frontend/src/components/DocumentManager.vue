<template>
  <div class="document-manager">
    <!-- Upload Section -->
    <el-upload
      ref="uploadRef"
      :auto-upload="false"
      :on-change="handleFileChange"
      :limit="1"
      :show-file-list="false"
      drag
    >
      <el-icon class="el-icon--upload"><UploadFilled /></el-icon>
      <div class="el-upload__text">
        Arrastra un archivo aquí o <em>haz clic para seleccionar</em>
      </div>
      <template #tip>
        <div class="el-upload__tip">
          Archivos PDF, documentos, imágenes, etc.
        </div>
      </template>
    </el-upload>

    <div v-if="selectedFile" class="file-preview">
      <el-form :model="uploadForm" label-position="top">
        <el-form-item label="Archivo seleccionado">
          <el-tag>{{ selectedFile.name }}</el-tag>
        </el-form-item>

        <el-form-item label="Nombre del documento (opcional)">
          <el-input
            v-model="uploadForm.file_name"
            placeholder="Nombre descriptivo del documento"
          />
        </el-form-item>

        <el-form-item>
          <el-button
            type="primary"
            :loading="uploading"
            @click="handleUpload"
          >
            Subir Documento
          </el-button>
          <el-button @click="cancelUpload">Cancelar</el-button>
        </el-form-item>
      </el-form>
    </div>

    <el-divider />

    <!-- Documents List -->
    <div class="documents-list">
      <h4>Documentos ({{ taskStore.documents.length }})</h4>

      <el-empty
        v-if="taskStore.documents.length === 0"
        description="No hay documentos adjuntos"
        :image-size="100"
      />

      <el-table
        v-else
        :data="taskStore.documents"
        style="width: 100%"
      >
        <el-table-column prop="file_name" label="Nombre" min-width="200">
          <template #default="scope">
            <div class="document-name">
              <el-icon><Document /></el-icon>
              <span>{{ scope.row.file_name || 'Sin nombre' }}</span>
            </div>
          </template>
        </el-table-column>

        <el-table-column prop="uploaded_at" label="Fecha" width="180">
          <template #default="scope">
            {{ formatDate(scope.row.uploaded_at) }}
          </template>
        </el-table-column>

        <el-table-column label="Acciones" width="150" align="center">
          <template #default="scope">
            <el-button
              :icon="Download"
              circle
              size="small"
              @click="handleDownload(scope.row)"
            />
            <el-button
              type="danger"
              :icon="Delete"
              circle
              size="small"
              @click="handleDeleteDocument(scope.row)"
            />
          </template>
        </el-table-column>
      </el-table>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  UploadFilled,
  Document,
  Download,
  Delete,
} from '@element-plus/icons-vue'
import { useTaskStore } from '@/stores/taskStore'

const props = defineProps({
  projectId: {
    type: Number,
    required: true,
  },
  taskId: {
    type: Number,
    required: true,
  },
})

const emit = defineEmits(['documents-updated'])

const taskStore = useTaskStore()

const uploadRef = ref(null)
const selectedFile = ref(null)
const uploading = ref(false)

const uploadForm = reactive({
  file_name: '',
})

const handleFileChange = (file) => {
  selectedFile.value = file.raw
  uploadForm.file_name = file.name
}

const handleUpload = async () => {
  if (!selectedFile.value) {
    ElMessage.warning('Por favor selecciona un archivo')
    return
  }

  uploading.value = true
  try {
    const formData = new FormData()
    formData.append('file', selectedFile.value)
    if (uploadForm.file_name) {
      formData.append('file_name', uploadForm.file_name)
    }

    await taskStore.uploadDocument(props.projectId, props.taskId, formData)

    ElMessage.success('Documento subido exitosamente')
    
    // Reset form
    selectedFile.value = null
    uploadForm.file_name = ''
    if (uploadRef.value) {
      uploadRef.value.clearFiles()
    }

    emit('documents-updated', taskStore.documents.length)
  } catch (error) {
    console.error('Error uploading document:', error)
    ElMessage.error('Error al subir el documento')
  } finally {
    uploading.value = false
  }
}

const cancelUpload = () => {
  selectedFile.value = null
  uploadForm.file_name = ''
  if (uploadRef.value) {
    uploadRef.value.clearFiles()
  }
}

const handleDownload = (document) => {
  // Abrir el archivo en una nueva pestaña
  if (document.file) {
    window.open(document.file, '_blank')
  } else {
    ElMessage.warning('URL del archivo no disponible')
  }
}

const handleDeleteDocument = async (document) => {
  try {
    await ElMessageBox.confirm(
      `¿Estás seguro de eliminar el documento "${document.file_name}"?`,
      'Confirmar eliminación',
      {
        confirmButtonText: 'Eliminar',
        cancelButtonText: 'Cancelar',
        type: 'warning',
      }
    )

    await taskStore.deleteDocument(props.projectId, props.taskId, document.id)
    
    ElMessage.success('Documento eliminado exitosamente')
    emit('documents-updated', taskStore.documents.length)
  } catch (error) {
    if (error !== 'cancel') {
      console.error('Error deleting document:', error)
      ElMessage.error('Error al eliminar el documento')
    }
  }
}

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

onMounted(async () => {
  // Los documentos ya deberían estar cargados desde TaskItem
  if (taskStore.documents.length > 0) {
    emit('documents-updated', taskStore.documents.length)
  }
})
</script>

<style scoped>
.document-manager {
  padding: 0;
}

.file-preview {
  margin-top: 20px;
  padding: 16px;
  background: #f5f7fa;
  border-radius: 4px;
}

.documents-list {
  margin-top: 24px;
}

.documents-list h4 {
  margin: 0 0 16px 0;
  color: #303133;
}

.document-name {
  display: flex;
  align-items: center;
  gap: 8px;
}

.el-icon--upload {
  font-size: 67px;
  color: #c0c4cc;
  margin-bottom: 16px;
}

.el-upload__text {
  color: #606266;
}

.el-upload__text em {
  color: #409eff;
  font-style: normal;
}

.el-upload__tip {
  color: #909399;
  font-size: 12px;
  margin-top: 8px;
}
</style>
