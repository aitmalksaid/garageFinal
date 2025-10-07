
<template>
  <div class="photo-manager">
    <h4>{{ title }}</h4>
    
    <!-- Zone de téléchargement -->
    <div class="upload-zone" @drop="handleDrop" @dragover.prevent @dragenter.prevent>
      <input
        ref="fileInput"
        type="file"
        multiple
        accept="image/*"
        @change="handleFileSelect"
        class="file-input"
      >
      <div class="upload-content" @click="$refs.fileInput.click()">
        <div class="upload-icon">📷</div>
        <p>Cliquez pour sélectionner ou glissez-déposez vos photos</p>
        <small>Formats acceptés: JPG, PNG, GIF</small>
      </div>
    </div>

    <!-- Aperçu des photos -->
    <div v-if="photos.length > 0" class="photos-preview">
      <div v-for="(photo, index) in photos" :key="index" class="photo-item">
        <img :src="photo.url" :alt="photo.name" class="photo-thumbnail">
        <div class="photo-info">
          <span class="photo-name">{{ photo.name }}</span>
          <span class="photo-size">{{ formatFileSize(photo.size) }}</span>
        </div>
        <button @click="removePhoto(index)" class="remove-btn" type="button">&times;</button>
      </div>
    </div>

    <!-- Galerie complète (modal) -->
    <div v-if="showGallery" class="gallery-modal" @click="closeGallery">
      <div class="gallery-content" @click.stop>
        <div class="gallery-header">
          <h3>Galerie Photos</h3>
          <button @click="closeGallery" class="close-btn">&times;</button>
        </div>
        <div class="gallery-grid">
          <div v-for="(photo, index) in photos" :key="index" class="gallery-item">
            <img :src="photo.url" :alt="photo.name" @click="openPhotoViewer(index)">
          </div>
        </div>
      </div>
    </div>

    <!-- Visualiseur de photo individuelle -->
    <div v-if="selectedPhotoIndex !== null" class="photo-viewer" @click="closePhotoViewer">
      <div class="viewer-content" @click.stop>
        <button @click="closePhotoViewer" class="close-btn">&times;</button>
        <img :src="photos[selectedPhotoIndex].url" :alt="photos[selectedPhotoIndex].name">
        <div class="viewer-controls">
          <button @click="previousPhoto" :disabled="selectedPhotoIndex === 0">&lt;</button>
          <span>{{ selectedPhotoIndex + 1 }} / {{ photos.length }}</span>
          <button @click="nextPhoto" :disabled="selectedPhotoIndex === photos.length - 1">&gt;</button>
        </div>
      </div>
    </div>

    <!-- Boutons d'action -->
    <div v-if="photos.length > 0" class="photo-actions">
      <button @click="showGallery = true" class="btn btn-secondary">
        Voir galerie ({{ photos.length }})
      </button>
      <button @click="clearAllPhotos" class="btn btn-danger">Supprimer tout</button>
    </div>
  </div>
</template>

<script>
import { ref, watch } from 'vue'

export default {
  name: 'PhotoManager',
  props: {
    title: {
      type: String,
      default: 'Photos'
    },
    modelValue: {
      type: Array,
      default: () => []
    },
    maxFiles: {
      type: Number,
      default: 10
    },
    maxFileSize: {
      type: Number,
      default: 5 * 1024 * 1024 // 5MB
    },
    entityType: {
      type: String,
      default: 'unknown' // 'vehicle', 'case-before', 'case-after'
    },
    entityId: {
      type: [String, Number],
      default: null
    },
    entityName: {
      type: String,
      default: ''
    }
  },
  emits: ['update:modelValue'],
  setup(props, { emit }) {
    const photos = ref([...props.modelValue])
    const showGallery = ref(false)
    const selectedPhotoIndex = ref(null)

    // Surveiller les changements du modelValue parent
    watch(() => props.modelValue, (newValue) => {
      photos.value = [...newValue]
    })

    // Émettre les changements vers le parent
    watch(photos, (newPhotos) => {
      emit('update:modelValue', newPhotos)
    }, { deep: true })

    const handleFileSelect = (event) => {
      const files = Array.from(event.target.files)
      processFiles(files)
    }

    const handleDrop = (event) => {
      event.preventDefault()
      const files = Array.from(event.dataTransfer.files)
      processFiles(files)
    }

    const processFiles = (files) => {
      files.forEach(file => {
        if (!file.type.startsWith('image/')) {
          alert(`${file.name} n'est pas une image valide`)
          return
        }

        if (file.size > props.maxFileSize) {
          alert(`${file.name} est trop volumineux (max ${formatFileSize(props.maxFileSize)})`)
          return
        }

        if (photos.value.length >= props.maxFiles) {
          alert(`Nombre maximum de photos atteint (${props.maxFiles})`)
          return
        }

        const reader = new FileReader()
        reader.onload = (e) => {
          photos.value.push({
            name: file.name,
            size: file.size,
            url: e.target.result,
            file: file,
            id: Date.now() + Math.random(),
            uploadDate: new Date().toISOString(),
            entityType: props.entityType || 'unknown',
            entityId: props.entityId || null,
            entityName: props.entityName || ''
          })
        }
        reader.readAsDataURL(file)
      })
    }

    const removePhoto = (index) => {
      if (confirm('Supprimer cette photo ?')) {
        photos.value.splice(index, 1)
      }
    }

    const clearAllPhotos = () => {
      if (confirm('Supprimer toutes les photos ?')) {
        photos.value = []
      }
    }

    const closeGallery = () => {
      showGallery.value = false
    }

    const openPhotoViewer = (index) => {
      selectedPhotoIndex.value = index
      showGallery.value = false
    }

    const closePhotoViewer = () => {
      selectedPhotoIndex.value = null
    }

    const previousPhoto = () => {
      if (selectedPhotoIndex.value > 0) {
        selectedPhotoIndex.value--
      }
    }

    const nextPhoto = () => {
      if (selectedPhotoIndex.value < photos.value.length - 1) {
        selectedPhotoIndex.value++
      }
    }

    const formatFileSize = (bytes) => {
      if (bytes === 0) return '0 B'
      const k = 1024
      const sizes = ['B', 'KB', 'MB', 'GB']
      const i = Math.floor(Math.log(bytes) / Math.log(k))
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
    }

    return {
      photos,
      showGallery,
      selectedPhotoIndex,
      handleFileSelect,
      handleDrop,
      removePhoto,
      clearAllPhotos,
      closeGallery,
      openPhotoViewer,
      closePhotoViewer,
      previousPhoto,
      nextPhoto,
      formatFileSize
    }
  }
}
</script>

<style scoped>
.photo-manager {
  margin: 20px 0;
}

.upload-zone {
  border: 2px dashed #ccc;
  border-radius: 8px;
  padding: 40px 20px;
  text-align: center;
  background: #fafafa;
  transition: border-color 0.3s;
  cursor: pointer;
}

.upload-zone:hover {
  border-color: #007bff;
  background: #f0f8ff;
}

.file-input {
  display: none;
}

.upload-content {
  pointer-events: none;
}

.upload-icon {
  font-size: 48px;
  margin-bottom: 10px;
}

.photos-preview {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 15px;
  margin-top: 20px;
}

.photo-item {
  position: relative;
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.photo-thumbnail {
  width: 100%;
  height: 120px;
  object-fit: cover;
  display: block;
}

.photo-info {
  padding: 8px;
  font-size: 12px;
}

.photo-name {
  display: block;
  font-weight: bold;
  margin-bottom: 2px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.photo-size {
  color: #666;
}

.remove-btn {
  position: absolute;
  top: 5px;
  right: 5px;
  background: rgba(220, 53, 69, 0.8);
  color: white;
  border: none;
  border-radius: 50%;
  width: 24px;
  height: 24px;
  cursor: pointer;
  font-size: 16px;
  line-height: 1;
}

.remove-btn:hover {
  background: rgba(220, 53, 69, 1);
}

.photo-actions {
  display: flex;
  gap: 10px;
  margin-top: 15px;
}

.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.btn-secondary { background-color: #6c757d; color: white; }
.btn-danger { background-color: #dc3545; color: white; }

/* Modal styles */
.gallery-modal,
.photo-viewer {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.gallery-content {
  background: white;
  padding: 20px;
  border-radius: 8px;
  max-width: 90vw;
  max-height: 90vh;
  overflow-y: auto;
}

.gallery-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #999;
}

.gallery-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 15px;
}

.gallery-item img {
  width: 100%;
  height: 150px;
  object-fit: cover;
  border-radius: 4px;
  cursor: pointer;
  transition: transform 0.2s;
}

.gallery-item img:hover {
  transform: scale(1.05);
}

.viewer-content {
  position: relative;
  max-width: 90vw;
  max-height: 90vh;
}

.viewer-content img {
  max-width: 100%;
  max-height: 80vh;
  object-fit: contain;
}

.viewer-controls {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
  margin-top: 20px;
  color: white;
}

.viewer-controls button {
  background: rgba(255, 255, 255, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.3);
  color: white;
  padding: 10px 15px;
  border-radius: 4px;
  cursor: pointer;
}

.viewer-controls button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.viewer-controls button:not(:disabled):hover {
  background: rgba(255, 255, 255, 0.3);
}
</style>
