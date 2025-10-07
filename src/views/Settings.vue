
<template>
  <div class="settings-page">
    <h1>Paramètres et Gestion des Données</h1>
    
    <div class="settings-sections">
      <!-- Section Export/Import -->
      <div class="settings-section">
        <h2>Sauvegarde et Restauration</h2>
        <div class="action-group">
          <button @click="exportData" class="btn btn-primary">
            📥 Exporter toutes les données
          </button>
          <p class="description">Télécharge un fichier JSON avec toutes vos données</p>
        </div>
        
        <div class="action-group">
          <input ref="fileInput" type="file" @change="handleFileImport" accept=".json" style="display: none">
          <button @click="$refs.fileInput.click()" class="btn btn-secondary">
            📤 Importer des données
          </button>
          <p class="description">Restaure les données depuis un fichier JSON</p>
        </div>
      </div>

      <!-- Section Statistiques -->
      <div class="settings-section">
        <h2>Statistiques</h2>
        <div class="stats-grid">
          <div class="stat-item">
            <span class="stat-label">Clients:</span>
            <span class="stat-value">{{ stats.clients }}</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">Véhicules:</span>
            <span class="stat-value">{{ stats.vehicles }}</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">Devis:</span>
            <span class="stat-value">{{ stats.quotes }}</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">Bons de commande:</span>
            <span class="stat-value">{{ stats.orders }}</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">Fournisseurs:</span>
            <span class="stat-value">{{ stats.suppliers }}</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">Experts:</span>
            <span class="stat-value">{{ stats.experts }}</span>
          </div>
        </div>
      </div>

      <!-- Section Nettoyage -->
      <div class="settings-section">
        <h2>Nettoyage des Données</h2>
        <div class="action-group">
          <button @click="createSampleData" class="btn btn-success">
            🎯 Créer des données d'exemple
          </button>
          <p class="description">Ajoute des données de démonstration</p>
        </div>
        
        <div class="action-group">
          <button @click="clearAllData" class="btn btn-danger">
            🗑️ Effacer toutes les données
          </button>
          <p class="description warning">⚠️ Cette action est irréversible!</p>
        </div>
      </div>

      <!-- Section État de la Persistance -->
      <div class="settings-section">
        <h2>État de la Persistance</h2>
        <div class="storage-info">
          <p><strong>Type de stockage:</strong> localStorage (navigateur)</p>
          <p><strong>Capacité utilisée:</strong> {{ storageUsed }} / {{ storageQuota }}</p>
          <p><strong>Dernière sauvegarde:</strong> {{ lastSave }}</p>
          <div class="storage-status" :class="storageStatus.class">
            {{ storageStatus.message }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useDataService } from '@/composables/useDataService.js'

const { 
  clients, vehicles, quotes, orders, suppliers, experts, insurances, cases, expenses,
  dataService, loadAllData, createSampleData: createSampleDataService 
} = useDataService()

const lastSave = ref('Jamais')

// Statistiques calculées
const stats = computed(() => ({
  clients: clients.value.length,
  vehicles: vehicles.value.length,
  quotes: quotes.value.length,
  orders: orders.value.length,
  suppliers: suppliers.value.length,
  experts: experts.value.length,
  insurances: insurances.value.length,
  cases: cases.value.length,
  expenses: expenses.value.length
}))

// Informations sur le stockage
const storageUsed = ref('0 KB')
const storageQuota = ref('5-10 MB')

const storageStatus = computed(() => {
  const used = parseFloat(storageUsed.value)
  if (used < 1000) {
    return { class: 'status-good', message: '✅ Stockage optimal' }
  } else if (used < 5000) {
    return { class: 'status-warning', message: '⚠️ Stockage modéré' }
  } else {
    return { class: 'status-danger', message: '🚨 Stockage élevé' }
  }
})

// Calculer l'utilisation du stockage
const calculateStorageUsage = () => {
  let totalSize = 0
  for (let key in localStorage) {
    if (localStorage.hasOwnProperty(key)) {
      totalSize += localStorage[key].length
    }
  }
  storageUsed.value = `${(totalSize / 1024).toFixed(2)} KB`
}

// Exporter toutes les données
const exportData = () => {
  try {
    const data = dataService.exportData()
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `garage-data-${new Date().toISOString().split('T')[0]}.json`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
    
    lastSave.value = new Date().toLocaleString('fr-FR')
    alert('Données exportées avec succès!')
  } catch (error) {
    console.error('Erreur lors de l\'export:', error)
    alert('Erreur lors de l\'export des données')
  }
}

// Importer des données
const handleFileImport = (event) => {
  const file = event.target.files[0]
  if (!file) return

  const reader = new FileReader()
  reader.onload = (e) => {
    try {
      const data = JSON.parse(e.target.result)
      
      if (confirm('Cette action remplacera toutes les données existantes. Continuer?')) {
        dataService.importData(data)
        loadAllData()
        calculateStorageUsage()
        alert('Données importées avec succès!')
      }
    } catch (error) {
      console.error('Erreur lors de l\'import:', error)
      alert('Erreur: fichier JSON invalide')
    }
  }
  reader.readAsText(file)
  
  // Reset input
  event.target.value = ''
}

// Créer des données d'exemple
const createSampleData = () => {
  if (confirm('Ajouter des données d\'exemple?')) {
    createSampleDataService()
    calculateStorageUsage()
    alert('Données d\'exemple créées!')
  }
}

// Effacer toutes les données
const clearAllData = () => {
  if (confirm('⚠️ ATTENTION: Cette action supprimera TOUTES les données de façon irréversible!\n\nÊtes-vous absolument certain de vouloir continuer?')) {
    if (confirm('Dernière confirmation: Toutes les données (clients, devis, véhicules, etc.) seront perdues. Continuer?')) {
      dataService.clearAllData()
      loadAllData()
      calculateStorageUsage()
      lastSave.value = 'Données effacées'
      alert('Toutes les données ont été supprimées')
    }
  }
}

onMounted(() => {
  calculateStorageUsage()
  
  // Mettre à jour l'heure de dernière modification
  const savedTime = localStorage.getItem('lastModified')
  if (savedTime) {
    lastSave.value = new Date(savedTime).toLocaleString('fr-FR')
  }
  
  // Sauvegarder l'heure actuelle
  localStorage.setItem('lastModified', new Date().toISOString())
})
</script>

<style scoped>
.settings-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

.settings-sections {
  display: grid;
  gap: 30px;
}

.settings-section {
  background: white;
  padding: 25px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.settings-section h2 {
  margin-bottom: 20px;
  color: #2c3e50;
  border-bottom: 2px solid #3498db;
  padding-bottom: 10px;
}

.action-group {
  margin-bottom: 20px;
}

.action-group:last-child {
  margin-bottom: 0;
}

.description {
  margin-top: 8px;
  font-size: 14px;
  color: #666;
}

.description.warning {
  color: #e74c3c;
  font-weight: bold;
}

.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  font-weight: bold;
  margin-right: 10px;
}

.btn-primary {
  background-color: #3498db;
  color: white;
}

.btn-secondary {
  background-color: #95a5a6;
  color: white;
}

.btn-success {
  background-color: #27ae60;
  color: white;
}

.btn-danger {
  background-color: #e74c3c;
  color: white;
}

.btn:hover {
  opacity: 0.8;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  padding: 15px;
  background-color: #f8f9fa;
  border-radius: 4px;
  border-left: 4px solid #3498db;
}

.stat-label {
  font-weight: bold;
  color: #2c3e50;
}

.stat-value {
  font-size: 18px;
  color: #3498db;
  font-weight: bold;
}

.storage-info {
  background-color: #f8f9fa;
  padding: 15px;
  border-radius: 4px;
}

.storage-info p {
  margin-bottom: 8px;
}

.storage-status {
  margin-top: 15px;
  padding: 10px;
  border-radius: 4px;
  font-weight: bold;
}

.status-good {
  background-color: #d4edda;
  color: #155724;
}

.status-warning {
  background-color: #fff3cd;
  color: #856404;
}

.status-danger {
  background-color: #f8d7da;
  color: #721c24;
}
</style>
