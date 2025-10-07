
<template>
  <div class="photo-gallery-page">
    <div class="page-header">
      <h1>Galerie Photos</h1>
      <div class="filters">
        <select v-model="selectedType" @change="filterPhotos" class="filter-select">
          <option value="all">Tous les types</option>
          <option value="vehicle">Véhicules</option>
          <option value="case-before">Affaires - Avant</option>
          <option value="case-after">Affaires - Après</option>
        </select>
        <select v-model="selectedEntity" @change="filterPhotos" class="filter-select">
          <option value="all">Toutes les entités</option>
          <option v-for="entity in uniqueEntities" :key="entity.id" :value="entity.id">
            {{ entity.name }}
          </option>
        </select>
        <input 
          v-model="searchTerm" 
          type="text" 
          placeholder="Rechercher..." 
          class="search-input"
          @input="filterPhotos"
        >
      </div>
    </div>

    <!-- Statistiques -->
    <div class="stats-cards">
      <div class="stat-card">
        <h3>Total Photos</h3>
        <p class="stat-number">{{ totalPhotos }}</p>
      </div>
      <div class="stat-card">
        <h3>Véhicules</h3>
        <p class="stat-number">{{ vehiclePhotos }}</p>
      </div>
      <div class="stat-card">
        <h3>Affaires</h3>
        <p class="stat-number">{{ casePhotos }}</p>
      </div>
    </div>

    <!-- Galerie -->
    <div class="gallery-container">
      <div v-if="filteredPhotos.length === 0" class="no-photos">
        <p>Aucune photo trouvée</p>
      </div>
      
      <div v-else class="photo-grid">
        <div v-for="(photo, index) in filteredPhotos" :key="photo.id" class="photo-card">
          <img 
            :src="photo.url" 
            :alt="photo.name"
            @click="openPhotoViewer(index)"
            class="photo-image"
          >
          <div class="photo-overlay">
            <div class="photo-details">
              <h4>{{ photo.source }}</h4>
              <p class="photo-type">{{ getTypeLabel(photo.type) }}</p>
              <p class="photo-date">{{ formatDate(photo.date) }}</p>
            </div>
            <div class="photo-actions">
              <button @click="downloadPhoto(photo)" class="action-btn">📥</button>
              <button @click="deletePhoto(photo)" class="action-btn delete">🗑️</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Visualiseur de photo -->
    <div v-if="selectedPhotoIndex !== null" class="photo-viewer" @click="closePhotoViewer">
      <div class="viewer-content" @click.stop>
        <button @click="closePhotoViewer" class="close-btn">&times;</button>
        <img :src="filteredPhotos[selectedPhotoIndex].url" :alt="filteredPhotos[selectedPhotoIndex].name">
        <div class="viewer-info">
          <h3>{{ filteredPhotos[selectedPhotoIndex].source }}</h3>
          <p>{{ getTypeLabel(filteredPhotos[selectedPhotoIndex].type) }}</p>
          <p>{{ formatDate(filteredPhotos[selectedPhotoIndex].date) }}</p>
        </div>
        <div class="viewer-controls">
          <button @click="previousPhoto" :disabled="selectedPhotoIndex === 0">&lt;</button>
          <span>{{ selectedPhotoIndex + 1 }} / {{ filteredPhotos.length }}</span>
          <button @click="nextPhoto" :disabled="selectedPhotoIndex === filteredPhotos.length - 1">&gt;</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'

export default {
  name: 'PhotoGallery',
  setup() {
    const selectedType = ref('all')
    const selectedEntity = ref('all')
    const searchTerm = ref('')
    const selectedPhotoIndex = ref(null)
    const allPhotos = ref([])

    // Charger toutes les photos de l'application
    const loadPhotos = () => {
      const allCollectedPhotos = []
      
      // Récupérer les photos des véhicules depuis le localStorage
      const vehicles = JSON.parse(localStorage.getItem('vehicles') || '[]')
      vehicles.forEach(vehicle => {
        if (vehicle.photos && vehicle.photos.length > 0) {
          vehicle.photos.forEach(photo => {
            allCollectedPhotos.push({
              ...photo,
              entityType: 'vehicle',
              entityId: vehicle.id,
              source: `${vehicle.marque} ${vehicle.modele} - ${vehicle.matricule}`,
              type: 'vehicle'
            })
          })
        }
      })
      
      // Récupérer les photos des affaires depuis le localStorage
      const cases = JSON.parse(localStorage.getItem('cases') || '[]')
      cases.forEach(caseItem => {
        // Photos avant
        if (caseItem.photosAvant && caseItem.photosAvant.length > 0) {
          caseItem.photosAvant.forEach(photo => {
            allCollectedPhotos.push({
              ...photo,
              entityType: 'case-before',
              entityId: caseItem.id,
              source: `Affaire ${caseItem.id} - ${caseItem.client}`,
              type: 'case-before'
            })
          })
        }
        
        // Photos après
        if (caseItem.photosApres && caseItem.photosApres.length > 0) {
          caseItem.photosApres.forEach(photo => {
            allCollectedPhotos.push({
              ...photo,
              entityType: 'case-after',
              entityId: caseItem.id,
              source: `Affaire ${caseItem.id} - ${caseItem.client}`,
              type: 'case-after'
            })
          })
        }
      })
      
      allPhotos.value = allCollectedPhotos
    }

    const uniqueEntities = computed(() => {
      const entities = new Map()
      allPhotos.value.forEach(photo => {
        if (photo.entityId && !entities.has(photo.entityId)) {
          entities.set(photo.entityId, {
            id: photo.entityId,
            name: photo.source,
            type: photo.entityType
          })
        }
      })
      return Array.from(entities.values())
    })

    const filteredPhotos = computed(() => {
      let photos = allPhotos.value

      if (selectedType.value !== 'all') {
        photos = photos.filter(photo => photo.type === selectedType.value)
      }

      if (selectedEntity.value !== 'all') {
        photos = photos.filter(photo => photo.entityId === selectedEntity.value)
      }

      if (searchTerm.value) {
        const term = searchTerm.value.toLowerCase()
        photos = photos.filter(photo => 
          photo.name.toLowerCase().includes(term) ||
          photo.source.toLowerCase().includes(term)
        )
      }

      return photos
    })

    const totalPhotos = computed(() => allPhotos.value.length)
    const vehiclePhotos = computed(() => allPhotos.value.filter(p => p.type === 'vehicle').length)
    const casePhotos = computed(() => allPhotos.value.filter(p => p.type.startsWith('case')).length)

    const filterPhotos = () => {
      // La réactivité gère automatiquement le filtrage
    }

    const openPhotoViewer = (index) => {
      selectedPhotoIndex.value = index
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
      if (selectedPhotoIndex.value < filteredPhotos.value.length - 1) {
        selectedPhotoIndex.value++
      }
    }

    const downloadPhoto = (photo) => {
      const link = document.createElement('a')
      link.href = photo.url
      link.download = photo.name
      link.click()
    }

    const deletePhoto = (photo) => {
      if (confirm('Supprimer cette photo ?')) {
        const index = allPhotos.value.findIndex(p => p.id === photo.id)
        if (index !== -1) {
          allPhotos.value.splice(index, 1)
        }
      }
    }

    const formatDate = (dateStr) => {
      return new Date(dateStr).toLocaleDateString('fr-FR')
    }

    const getTypeLabel = (type) => {
      const labels = {
        'vehicle': 'Véhicule',
        'case-before': 'Avant réparation',
        'case-after': 'Après réparation'
      }
      return labels[type] || type
    }

    onMounted(() => {
      loadPhotos()
    })

    return {
      selectedType,
      selectedEntity,
      searchTerm,
      selectedPhotoIndex,
      filteredPhotos,
      uniqueEntities,
      totalPhotos,
      vehiclePhotos,
      casePhotos,
      filterPhotos,
      openPhotoViewer,
      closePhotoViewer,
      previousPhoto,
      nextPhoto,
      downloadPhoto,
      deletePhoto,
      formatDate,
      getTypeLabel
    }
  }
}
</script>

<style scoped>
.photo-gallery-page {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.filters {
  display: flex;
  gap: 15px;
}

.filter-select,
.search-input {
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.search-input {
  width: 200px;
}

.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  text-align: center;
}

.stat-card h3 {
  margin: 0 0 10px 0;
  color: #666;
  font-size: 14px;
  text-transform: uppercase;
}

.stat-number {
  font-size: 32px;
  font-weight: bold;
  margin: 0;
  color: #007bff;
}

.gallery-container {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.no-photos {
  text-align: center;
  padding: 60px;
  color: #666;
}

.photo-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 20px;
}

.photo-card {
  position: relative;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  transition: transform 0.2s;
}

.photo-card:hover {
  transform: translateY(-2px);
}

.photo-image {
  width: 100%;
  height: 200px;
  object-fit: cover;
  cursor: pointer;
}

.photo-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(to top, rgba(0,0,0,0.8), transparent);
  color: white;
  padding: 15px;
  opacity: 0;
  transition: opacity 0.3s;
}

.photo-card:hover .photo-overlay {
  opacity: 1;
}

.photo-details h4 {
  margin: 0 0 5px 0;
  font-size: 14px;
}

.photo-type,
.photo-date {
  margin: 0;
  font-size: 12px;
  opacity: 0.8;
}

.photo-actions {
  position: absolute;
  top: 10px;
  right: 10px;
  display: flex;
  gap: 5px;
}

.action-btn {
  background: rgba(255, 255, 255, 0.8);
  border: none;
  border-radius: 50%;
  width: 32px;
  height: 32px;
  cursor: pointer;
  font-size: 16px;
  transition: background 0.2s;
}

.action-btn:hover {
  background: rgba(255, 255, 255, 1);
}

.action-btn.delete:hover {
  background: rgba(220, 53, 69, 0.9);
  color: white;
}

/* Visualiseur de photo */
.photo-viewer {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.9);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.viewer-content {
  position: relative;
  max-width: 90vw;
  max-height: 90vh;
  text-align: center;
}

.viewer-content img {
  max-width: 100%;
  max-height: 70vh;
  object-fit: contain;
}

.close-btn {
  position: absolute;
  top: -40px;
  right: 0;
  background: none;
  border: none;
  font-size: 32px;
  color: white;
  cursor: pointer;
}

.viewer-info {
  color: white;
  margin: 15px 0;
}

.viewer-info h3 {
  margin: 0 0 5px 0;
}

.viewer-info p {
  margin: 2px 0;
  opacity: 0.8;
}

.viewer-controls {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
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
