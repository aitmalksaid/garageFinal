<template>
  <div class="page-container">
    <div class="page-header">
      <h1>Suivi des Réparations</h1>
      <p class="page-subtitle">Gestion et suivi de l'avancement des réparations par article</p>
    </div>

    <!-- Filtres -->
    <div class="filters-section">
      <div class="filters-row">
        <div class="filter-group">
          <label>Statut:</label>
          <select v-model="filtres.statut">
            <option value="">Tous les statuts</option>
            <option value="EN_ATTENTE">En attente</option>
            <option value="COMMANDE">Commandé</option>
            <option value="RECU">Reçu</option>
            <option value="EN_COURS">En cours</option>
            <option value="TERMINE">Terminé</option>
            <option value="POSE">Posé</option>
          </select>
        </div>
        
        <div class="filter-group">
          <label>Technicien:</label>
          <select v-model="filtres.technicien">
            <option value="">Tous les techniciens</option>
            <option v-for="tech in techniciens" :key="tech" :value="tech">{{ tech }}</option>
          </select>
        </div>
        
        <div class="filter-group">
          <label>Priorité:</label>
          <select v-model="filtres.priorite">
            <option value="">Toutes les priorités</option>
            <option value="URGENTE">Urgente</option>
            <option value="HAUTE">Haute</option>
            <option value="NORMALE">Normale</option>
            <option value="BASSE">Basse</option>
          </select>
        </div>
        
        <div class="filter-group">
          <label>Devis N°:</label>
          <input v-model="filtres.numeroDevis" type="text" placeholder="Rechercher par N° devis">
        </div>
      </div>
    </div>

    <!-- Tableau de suivi -->
    <div class="reparations-table">
      <table>
        <thead>
          <tr>
            <th>Devis N°</th>
            <th>Client</th>
            <th>Véhicule</th>
            <th>Article</th>
            <th>Intervention</th>
            <th>Statut</th>
            <th>Priorité</th>
            <th>Technicien</th>
            <th>Progression</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="article in articlesFiltered" :key="article.id" :class="getRowClass(article)">
            <td>{{ getDevisNumero(article.devis_id) }}</td>
            <td>{{ getClientName(article.devis_id) }}</td>
            <td>{{ getVehiculeInfo(article.devis_id) }}</td>
            <td>{{ article.description }}</td>
            <td>
              <span :class="'intervention-badge intervention-' + article.intervention.toLowerCase()">
                {{ article.intervention }}
              </span>
            </td>
            <td>
              <span :class="'statut-badge statut-' + article.statut_reparation.toLowerCase().replace('_', '-')">
                {{ getStatutLabel(article.statut_reparation) }}
              </span>
            </td>
            <td>
              <span :class="'priorite-badge priorite-' + article.priorite.toLowerCase()">
                {{ article.priorite }}
              </span>
            </td>
            <td>{{ article.technicien_assigne || 'Non assigné' }}</td>
            <td>
              <div class="progress-container">
                <div class="progress-bar">
                  <div class="progress-fill" :style="{ width: getProgressPercentage(article) + '%' }"></div>
                </div>
                <span class="progress-text">{{ getProgressPercentage(article) }}%</span>
              </div>
            </td>
            <td>
              <button @click="openDetailModal(article)" class="btn btn-sm btn-primary">
                Détails
              </button>
              <button @click="updateStatut(article)" class="btn btn-sm btn-secondary">
                Modifier
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Modal de détails/modification -->
    <div v-if="showModal" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>Suivi de réparation - {{ selectedArticle?.description }}</h3>
          <button @click="closeModal" class="close-btn">&times;</button>
        </div>
        
        <div class="modal-body">
          <div class="form-grid">
            <div class="form-group">
              <label>Statut:</label>
              <select v-model="editForm.statut_reparation">
                <option value="EN_ATTENTE">En attente</option>
                <option value="COMMANDE">Commandé</option>
                <option value="RECU">Reçu</option>
                <option value="EN_COURS">En cours</option>
                <option value="TERMINE">Terminé</option>
                <option value="POSE">Posé</option>
              </select>
            </div>
            
            <div class="form-group">
              <label>Priorité:</label>
              <select v-model="editForm.priorite">
                <option value="BASSE">Basse</option>
                <option value="NORMALE">Normale</option>
                <option value="HAUTE">Haute</option>
                <option value="URGENTE">Urgente</option>
              </select>
            </div>
            
            <div class="form-group">
              <label>Technicien assigné:</label>
              <input v-model="editForm.technicien_assigne" type="text" placeholder="Nom du technicien">
            </div>
            
            <div class="form-group">
              <label>Date de commande:</label>
              <input v-model="editForm.date_commande" type="date">
            </div>
            
            <div class="form-group">
              <label>Date de réception:</label>
              <input v-model="editForm.date_reception" type="date">
            </div>
            
            <div class="form-group">
              <label>Date début réparation:</label>
              <input v-model="editForm.date_debut_reparation" type="date">
            </div>
            
            <div class="form-group">
              <label>Date fin réparation:</label>
              <input v-model="editForm.date_fin_reparation" type="date">
            </div>
            
            <div class="form-group">
              <label>Date de pose:</label>
              <input v-model="editForm.date_pose" type="date">
            </div>
            
            <div class="form-group">
              <label>Temps estimé (heures):</label>
              <input v-model.number="editForm.temps_estime_heures" type="number" step="0.5">
            </div>
            
            <div class="form-group">
              <label>Temps réel (heures):</label>
              <input v-model.number="editForm.temps_reel_heures" type="number" step="0.5">
            </div>
            
            <div class="form-group full-width">
              <label>Notes de réparation:</label>
              <textarea v-model="editForm.notes_reparation" rows="4" placeholder="Notes sur l'avancement..."></textarea>
            </div>
          </div>
        </div>
        
        <div class="modal-footer">
          <button @click="saveChanges" class="btn btn-primary">Sauvegarder</button>
          <button @click="closeModal" class="btn btn-secondary">Annuler</button>
        </div>
      </div>
    </div>

    <!-- Statistiques -->
    <div class="stats-section">
      <div class="stats-grid">
        <div class="stat-card">
          <h4>En attente</h4>
          <span class="stat-number">{{ getStatCount('EN_ATTENTE') }}</span>
        </div>
        <div class="stat-card">
          <h4>En cours</h4>
          <span class="stat-number">{{ getStatCount('EN_COURS') }}</span>
        </div>
        <div class="stat-card">
          <h4>Terminés</h4>
          <span class="stat-number">{{ getStatCount('TERMINE') }}</span>
        </div>
        <div class="stat-card">
          <h4>Posés</h4>
          <span class="stat-number">{{ getStatCount('POSE') }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useDataService } from '../composables/useDataService'

const { dataService } = useDataService()

// États réactifs
const articlesReparation = ref([])
const devis = ref([])
const affaires = ref([])
const clients = ref([])
const voitures = ref([])
const showModal = ref(false)
const selectedArticle = ref(null)

// Filtres
const filtres = ref({
  statut: '',
  technicien: '',
  priorite: '',
  numeroDevis: ''
})

// Formulaire d'édition
const editForm = ref({
  statut_reparation: '',
  priorite: '',
  technicien_assigne: '',
  date_commande: '',
  date_reception: '',
  date_debut_reparation: '',
  date_fin_reparation: '',
  date_pose: '',
  temps_estime_heures: 0,
  temps_reel_heures: 0,
  notes_reparation: ''
})

// Computed
const techniciens = computed(() => {
  const techs = articlesReparation.value
    .map(a => a.technicien_assigne)
    .filter(t => t)
    .filter((t, i, arr) => arr.indexOf(t) === i)
  return techs.sort()
})

const articlesFiltered = computed(() => {
  return articlesReparation.value.filter(article => {
    if (filtres.value.statut && article.statut_reparation !== filtres.value.statut) return false
    if (filtres.value.technicien && article.technicien_assigne !== filtres.value.technicien) return false
    if (filtres.value.priorite && article.priorite !== filtres.value.priorite) return false
    if (filtres.value.numeroDevis) {
      const devisNum = getDevisNumero(article.devis_id)
      if (!devisNum.toLowerCase().includes(filtres.value.numeroDevis.toLowerCase())) return false
    }
    return true
  })
})

// Méthodes
const loadData = async () => {
  try {
    const [articlesData, devisData, affairesData, clientsData, voituresData] = await Promise.all([
      dataService.getAllDevisArticles(),
      dataService.getAllDevis(),
      dataService.getAllAffaires(),
      dataService.getAllClients(),
      dataService.getAllVoitures()
    ])
    
    articlesReparation.value = articlesData
    devis.value = devisData
    affaires.value = affairesData
    clients.value = clientsData
    voitures.value = voituresData
  } catch (error) {
    console.error('Erreur lors du chargement des données:', error)
  }
}

const getDevisNumero = (devisId) => {
  const d = devis.value.find(d => d.id === devisId)
  return d?.numero_devis || 'N/A'
}

const getClientName = (devisId) => {
  const d = devis.value.find(d => d.id === devisId)
  if (!d) return 'N/A'
  const affaire = affaires.value.find(a => a.id === d.affaire_id)
  if (!affaire) return 'N/A'
  const client = clients.value.find(c => c.id === affaire.client_id)
  return client ? `${client.nom} ${client.prenom}` : 'N/A'
}

const getVehiculeInfo = (devisId) => {
  const d = devis.value.find(d => d.id === devisId)
  if (!d) return 'N/A'
  const affaire = affaires.value.find(a => a.id === d.affaire_id)
  if (!affaire) return 'N/A'
  const voiture = voitures.value.find(v => v.id === affaire.voiture_id)
  return voiture ? `${voiture.marque} ${voiture.modele} (${voiture.immatriculation})` : 'N/A'
}

const getStatutLabel = (statut) => {
  const labels = {
    'EN_ATTENTE': 'En attente',
    'COMMANDE': 'Commandé',
    'RECU': 'Reçu',
    'EN_COURS': 'En cours',
    'TERMINE': 'Terminé',
    'POSE': 'Posé'
  }
  return labels[statut] || statut
}

const getProgressPercentage = (article) => {
  const statuts = ['EN_ATTENTE', 'COMMANDE', 'RECU', 'EN_COURS', 'TERMINE', 'POSE']
  const currentIndex = statuts.indexOf(article.statut_reparation)
  return Math.round((currentIndex / (statuts.length - 1)) * 100)
}

const getRowClass = (article) => {
  return {
    'row-urgent': article.priorite === 'URGENTE',
    'row-high': article.priorite === 'HAUTE',
    'row-completed': article.statut_reparation === 'POSE'
  }
}

const getStatCount = (statut) => {
  return articlesReparation.value.filter(a => a.statut_reparation === statut).length
}

const openDetailModal = (article) => {
  selectedArticle.value = article
  editForm.value = { ...article }
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  selectedArticle.value = null
}

const updateStatut = (article) => {
  openDetailModal(article)
}

const saveChanges = async () => {
  try {
    await dataService.updateDevisArticle(selectedArticle.value.id, editForm.value)
    await loadData()
    closeModal()
  } catch (error) {
    console.error('Erreur lors de la sauvegarde:', error)
    alert('Erreur lors de la sauvegarde')
  }
}

onMounted(loadData)
</script>

<style scoped>
.page-container {
  padding: 20px;
}

.page-header {
  margin-bottom: 30px;
}

.page-subtitle {
  color: #666;
  margin-top: 5px;
}

.filters-section {
  background: white;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.filters-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
}

.filter-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
  color: #333;
}

.filter-group select,
.filter-group input {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.reparations-table {
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  margin-bottom: 20px;
}

.reparations-table table {
  width: 100%;
  border-collapse: collapse;
}

.reparations-table th,
.reparations-table td {
  padding: 12px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.reparations-table th {
  background: #f8f9fa;
  font-weight: bold;
}

.row-urgent {
  background-color: #fff5f5;
  border-left: 4px solid #e53e3e;
}

.row-high {
  background-color: #fffaf0;
  border-left: 4px solid #dd6b20;
}

.row-completed {
  background-color: #f0fff4;
  border-left: 4px solid #38a169;
}

.statut-badge,
.intervention-badge,
.priorite-badge {
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: bold;
  text-transform: uppercase;
}

.statut-en-attente { background: #fed7d7; color: #c53030; }
.statut-commande { background: #bee3f8; color: #2b6cb0; }
.statut-recu { background: #c6f6d5; color: #2f855a; }
.statut-en-cours { background: #feebc8; color: #c05621; }
.statut-termine { background: #d6f5d6; color: #22543d; }
.statut-pose { background: #c6f6d5; color: #1a365d; }

.priorite-urgente { background: #fed7d7; color: #c53030; }
.priorite-haute { background: #feebc8; color: #c05621; }
.priorite-normale { background: #e2e8f0; color: #4a5568; }
.priorite-basse { background: #f7fafc; color: #718096; }

.progress-container {
  display: flex;
  align-items: center;
  gap: 10px;
}

.progress-bar {
  flex: 1;
  height: 8px;
  background: #e2e8f0;
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #4299e1, #38a169);
  transition: width 0.3s ease;
}

.progress-text {
  font-size: 12px;
  color: #666;
  min-width: 35px;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 8px;
  width: 800px;
  max-width: 90vw;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #eee;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
}

.modal-body {
  padding: 20px;
}

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
}

.form-group.full-width {
  grid-column: 1 / -1;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.modal-footer {
  padding: 20px;
  border-top: 1px solid #eee;
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.stats-section {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 15px;
}

.stat-card {
  text-align: center;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
}

.stat-card h4 {
  margin: 0 0 10px 0;
  color: #666;
  font-size: 14px;
}

.stat-number {
  font-size: 24px;
  font-weight: bold;
  color: #2d3748;
}

.btn {
  padding: 6px 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
  margin-right: 5px;
}

.btn-primary { background: #4299e1; color: white; }
.btn-secondary { background: #a0aec0; color: white; }
.btn-sm { padding: 4px 8px; font-size: 11px; }
</style>