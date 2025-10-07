
<template>
  <div class="page-container">
    <h1>Tableau de Bord - Affaires</h1>
    
    <div class="filters">
      <select v-model="selectedCategory" @change="filterAffaires">
        <option value="">Toutes les catégories</option>
        <option value="original">Original</option>
        <option value="adaptable">Adaptable</option>
        <option value="occasion">Occasion</option>
      </select>
      
      <select v-model="selectedStatus" @change="filterAffaires">
        <option value="">Tous les statuts</option>
        <option value="ouvert">Ouvert</option>
        <option value="en-cours">En cours</option>
        <option value="prepare">Préparé</option>
        <option value="envoye">Envoyé</option>
        <option value="accepte">Accepté</option>
        <option value="rejete">Rejeté</option>
      </select>
    </div>

    <!-- États de chargement et d'erreur -->
    <div v-if="loading" class="loading">
      <p>Chargement des affaires...</p>
    </div>
    
    <div v-else-if="error" class="error">
      <p>{{ error }}</p>
      <button @click="loadAffaires" class="retry-btn">Réessayer</button>
    </div>

    <!-- Grille des affaires -->
    <div v-else class="affaires-grid">
      <div v-if="filteredAffaires.length === 0" class="no-data">
        <p>Aucune affaire trouvée</p>
      </div>
      
      <div v-for="affaire in filteredAffaires" :key="affaire.id" class="affaire-card">
        <div class="card-header">
          <h3>{{ affaire.numero_affaire || `Affaire #${affaire.id}` }}</h3>
          <span :class="['status', affaire.statut]">{{ affaire.statut || 'Inconnu' }}</span>
        </div>
        
        <div class="card-content">
          <p><strong>Client:</strong> {{ getClientName(affaire) }}</p>
          <p><strong>Véhicule:</strong> {{ getVehiculeInfo(affaire) }}</p>
          <p><strong>Expert:</strong> {{ getExpertName(affaire) }}</p>
          <p><strong>Assurance:</strong> {{ getAssuranceName(affaire) }}</p>
          <p><strong>Date ouverture:</strong> {{ formatDate(affaire.date_ouverture) }}</p>
          <p><strong>Avancement:</strong> {{ calculateAvancement(affaire.statut) }}%</p>
        </div>
        
        <div class="progress-bar">
          <div class="progress" :style="{ width: calculateAvancement(affaire.statut) + '%' }"></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import dataService from '@/services/dataService'

const selectedCategory = ref('')
const selectedStatus = ref('')
const affaires = ref([])
const loading = ref(false)
const error = ref(null)

// Charger les affaires depuis la base de données
const loadAffaires = async () => {
  try {
    loading.value = true
    error.value = null
    const data = await dataService.getAllAffairesWithRelations()
    affaires.value = data
  } catch (err) {
    error.value = 'Erreur lors du chargement des affaires'
    console.error('Erreur:', err)
  } finally {
    loading.value = false
  }
}

// Calculer l'avancement basé sur le statut
const calculateAvancement = (statut) => {
  switch (statut) {
    case 'ouvert':
    case 'en-cours':
      return 25
    case 'prepare':
      return 50
    case 'envoye':
      return 75
    case 'accepte':
      return 100
    case 'rejete':
      return 0
    default:
      return 0
  }
}

const filteredAffaires = computed(() => {
  return affaires.value.filter(affaire => {
    const statusMatch = !selectedStatus.value || affaire.statut === selectedStatus.value
    return statusMatch
  })
})

const getClientName = (affaire) => {
  if (affaire.clients) {
    return `${affaire.clients.prenom || ''} ${affaire.clients.nom || ''}`.trim()
  }
  return 'Client inconnu'
}

const getVehiculeInfo = (affaire) => {
  if (affaire.voitures) {
    const v = affaire.voitures
    return `${v.marque || ''} ${v.modele || ''} (${v.immatriculation || ''})`.trim()
  }
  return 'Véhicule inconnu'
}

const getExpertName = (affaire) => {
  if (affaire.experts) {
    return `${affaire.experts.prenom || ''} ${affaire.experts.nom || ''}`.trim()
  }
  return 'Expert inconnu'
}

const getAssuranceName = (affaire) => {
  if (affaire.assurances) {
    return affaire.assurances.nom || 'Assurance inconnue'
  }
  return 'Assurance inconnue'
}

const formatDate = (dateString) => {
  if (!dateString) return 'Date inconnue'
  return new Date(dateString).toLocaleDateString('fr-FR')
}

const filterAffaires = () => {
  // La réactivité s'occupe du filtrage
}

// Charger les données au montage du composant
onMounted(() => {
  loadAffaires()
})
</script>

<style scoped>
.page-container {
  padding: 20px;
}

.filters {
  display: flex;
  gap: 15px;
  margin-bottom: 30px;
}

.filters select {
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  background: white;
}

.affaires-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 20px;
}

.affaire-card {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  transition: transform 0.2s;
}

.affaire-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.15);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.card-header h3 {
  margin: 0;
  color: #2c3e50;
}

.status {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: bold;
  text-transform: uppercase;
}

.status.ouvert { background: #95a5a6; color: white; }
.status.en-cours { background: #f39c12; color: white; }
.status.prepare { background: #3498db; color: white; }
.status.envoye { background: #9b59b6; color: white; }
.status.accepte { background: #27ae60; color: white; }
.status.rejete { background: #e74c3c; color: white; }

.card-content p {
  margin: 8px 0;
  font-size: 14px;
}

.progress-bar {
  margin-top: 15px;
  height: 6px;
  background: #ecf0f1;
  border-radius: 3px;
  overflow: hidden;
}

.progress {
  height: 100%;
  background: #3498db;
  transition: width 0.3s;
}

/* États de chargement et d'erreur */
.loading, .error, .no-data {
  text-align: center;
  padding: 40px 20px;
  color: #7f8c8d;
}

.loading p {
  font-size: 16px;
  margin: 0;
}

.error {
  color: #e74c3c;
}

.error p {
  margin-bottom: 15px;
  font-size: 16px;
}

.retry-btn {
  background: #3498db;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: background 0.2s;
}

.retry-btn:hover {
  background: #2980b9;
}

.no-data {
  grid-column: 1 / -1;
  font-style: italic;
}
</style>