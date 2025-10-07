
<template>
  <div class="photo-relations-page">
    <div class="page-header">
      <h1>Relations Photos - Entités</h1>
      <button @click="refreshData" class="btn btn-primary">Actualiser</button>
    </div>

    <!-- Statistiques -->
    <div class="stats-section">
      <div class="stat-card">
        <h3>Véhicules avec photos</h3>
        <p class="stat-number">{{ vehiclesWithPhotos }}</p>
      </div>
      <div class="stat-card">
        <h3>Affaires avec photos</h3>
        <p class="stat-number">{{ casesWithPhotos }}</p>
      </div>
      <div class="stat-card">
        <h3>Total photos</h3>
        <p class="stat-number">{{ totalPhotos }}</p>
      </div>
    </div>

    <!-- Liste des relations -->
    <div class="relations-section">
      <h2>Véhicules et leurs photos</h2>
      <div class="entity-list">
        <div v-for="vehicle in vehiclesData" :key="vehicle.id" class="entity-card">
          <div class="entity-header">
            <h3>{{ vehicle.marque }} {{ vehicle.modele }}</h3>
            <span class="entity-id">ID: {{ vehicle.id }}</span>
            <span class="matricule">{{ vehicle.matricule }}</span>
          </div>
          <div class="photos-grid">
            <div v-for="photo in vehicle.photos" :key="photo.id" class="photo-thumb">
              <img :src="photo.url" :alt="photo.name" @click="openPhoto(photo)">
              <div class="photo-info">
                <small>{{ photo.name }}</small>
                <small>{{ formatDate(photo.uploadDate) }}</small>
              </div>
            </div>
            <div v-if="vehicle.photos.length === 0" class="no-photos">
              Aucune photo
            </div>
          </div>
        </div>
      </div>

      <h2>Affaires et leurs photos</h2>
      <div class="entity-list">
        <div v-for="caseItem in casesData" :key="caseItem.id" class="entity-card">
          <div class="entity-header">
            <h3>Affaire {{ caseItem.id }}</h3>
            <span class="client">Client: {{ caseItem.client }}</span>
            <span class="status">{{ getStatusText(caseItem.statutDevis) }}</span>
          </div>
          
          <div class="case-photos">
            <div class="photo-section">
              <h4>Photos avant ({{ caseItem.photosAvant?.length || 0 }})</h4>
              <div class="photos-grid">
                <div v-for="photo in caseItem.photosAvant" :key="photo.id" class="photo-thumb">
                  <img :src="photo.url" :alt="photo.name" @click="openPhoto(photo)">
                  <div class="photo-info">
                    <small>{{ photo.name }}</small>
                    <small>{{ formatDate(photo.uploadDate) }}</small>
                  </div>
                </div>
                <div v-if="!caseItem.photosAvant?.length" class="no-photos">
                  Aucune photo avant
                </div>
              </div>
            </div>
            
            <div class="photo-section">
              <h4>Photos après ({{ caseItem.photosApres?.length || 0 }})</h4>
              <div class="photos-grid">
                <div v-for="photo in caseItem.photosApres" :key="photo.id" class="photo-thumb">
                  <img :src="photo.url" :alt="photo.name" @click="openPhoto(photo)">
                  <div class="photo-info">
                    <small>{{ photo.name }}</small>
                    <small>{{ formatDate(photo.uploadDate) }}</small>
                  </div>
                </div>
                <div v-if="!caseItem.photosApres?.length" class="no-photos">
                  Aucune photo après
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Visualiseur de photo -->
    <div v-if="selectedPhoto" class="photo-viewer" @click="closePhoto">
      <div class="viewer-content" @click.stop>
        <button @click="closePhoto" class="close-btn">&times;</button>
        <img :src="selectedPhoto.url" :alt="selectedPhoto.name">
        <div class="photo-details">
          <h3>{{ selectedPhoto.name }}</h3>
          <p><strong>Type:</strong> {{ getPhotoTypeText(selectedPhoto.entityType) }}</p>
          <p><strong>Entité:</strong> {{ selectedPhoto.entityName }}</p>
          <p><strong>Date:</strong> {{ formatDate(selectedPhoto.uploadDate) }}</p>
          <p><strong>Taille:</strong> {{ formatFileSize(selectedPhoto.size) }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'

export default {
  name: 'PhotoRelations',
  setup() {
    const vehiclesData = ref([])
    const casesData = ref([])
    const selectedPhoto = ref(null)

    const vehiclesWithPhotos = computed(() => 
      vehiclesData.value.filter(v => v.photos && v.photos.length > 0).length
    )

    const casesWithPhotos = computed(() => 
      casesData.value.filter(c => 
        (c.photosAvant && c.photosAvant.length > 0) || 
        (c.photosApres && c.photosApres.length > 0)
      ).length
    )

    const totalPhotos = computed(() => {
      let count = 0
      vehiclesData.value.forEach(v => {
        count += v.photos ? v.photos.length : 0
      })
      casesData.value.forEach(c => {
        count += c.photosAvant ? c.photosAvant.length : 0
        count += c.photosApres ? c.photosApres.length : 0
      })
      return count
    })

    const refreshData = () => {
      vehiclesData.value = JSON.parse(localStorage.getItem('vehicles') || '[]')
      casesData.value = JSON.parse(localStorage.getItem('cases') || '[]')
    }

    const openPhoto = (photo) => {
      selectedPhoto.value = photo
    }

    const closePhoto = () => {
      selectedPhoto.value = null
    }

    const formatDate = (dateStr) => {
      if (!dateStr) return 'Date inconnue'
      return new Date(dateStr).toLocaleDateString('fr-FR')
    }

    const formatFileSize = (bytes) => {
      if (!bytes) return '0 B'
      const k = 1024
      const sizes = ['B', 'KB', 'MB', 'GB']
      const i = Math.floor(Math.log(bytes) / Math.log(k))
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
    }

    const getStatusText = (status) => {
      const statusMap = {
        'en_cours': 'En cours',
        'prepare': 'Préparé',
        'envoye': 'Envoyé',
        'accepte': 'Accepté',
        'rejete': 'Rejeté'
      }
      return statusMap[status] || status
    }

    const getPhotoTypeText = (type) => {
      const typeMap = {
        'vehicle': 'Véhicule',
        'case-before': 'Affaire - Avant',
        'case-after': 'Affaire - Après'
      }
      return typeMap[type] || type
    }

    onMounted(() => {
      refreshData()
    })

    return {
      vehiclesData,
      casesData,
      selectedPhoto,
      vehiclesWithPhotos,
      casesWithPhotos,
      totalPhotos,
      refreshData,
      openPhoto,
      closePhoto,
      formatDate,
      formatFileSize,
      getStatusText,
      getPhotoTypeText
    }
  }
}
</script>

<style scoped>
.photo-relations-page {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.stats-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 40px;
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
}

.stat-number {
  font-size: 32px;
  font-weight: bold;
  margin: 0;
  color: #007bff;
}

.relations-section {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.relations-section h2 {
  margin: 30px 0 20px 0;
  padding-bottom: 10px;
  border-bottom: 2px solid #007bff;
  color: #007bff;
}

.relations-section h2:first-of-type {
  margin-top: 0;
}

.entity-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.entity-card {
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 20px;
  background: #f9f9f9;
}

.entity-header {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 15px;
  flex-wrap: wrap;
}

.entity-header h3 {
  margin: 0;
  color: #333;
}

.entity-id,
.matricule,
.client,
.status {
  background: #007bff;
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
}

.matricule {
  background: #28a745;
}

.client {
  background: #6f42c1;
}

.status {
  background: #fd7e14;
}

.case-photos {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.photo-section h4 {
  margin: 0 0 10px 0;
  color: #666;
}

.photos-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 10px;
}

.photo-thumb {
  background: white;
  border-radius: 4px;
  overflow: hidden;
  box-shadow: 0 1px 2px rgba(0,0,0,0.1);
  cursor: pointer;
  transition: transform 0.2s;
}

.photo-thumb:hover {
  transform: scale(1.05);
}

.photo-thumb img {
  width: 100%;
  height: 80px;
  object-fit: cover;
}

.photo-info {
  padding: 5px;
  font-size: 10px;
  color: #666;
}

.photo-info small {
  display: block;
  line-height: 1.2;
}

.no-photos {
  color: #999;
  font-style: italic;
  padding: 20px;
  text-align: center;
  border: 2px dashed #ddd;
  border-radius: 4px;
}

.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.btn-primary {
  background-color: #007bff;
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

.photo-details {
  color: white;
  margin-top: 15px;
  text-align: left;
  background: rgba(0, 0, 0, 0.8);
  padding: 15px;
  border-radius: 4px;
}

.photo-details h3 {
  margin: 0 0 10px 0;
}

.photo-details p {
  margin: 5px 0;
}

@media (max-width: 768px) {
  .case-photos {
    grid-template-columns: 1fr;
  }
  
  .entity-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .photos-grid {
    grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
  }
}
</style>
