<template>
  <div class="page-container">
    <div class="page-header">
      <h1>Gestion des Bons de Commande</h1>
      <p class="page-subtitle">Suivi et gestion des bons de commande créés automatiquement à partir des devis acceptés</p>
    </div>

    <!-- Filtres -->
    <div class="filters-section">
      <div class="filters-row">
        <div class="filter-group">
          <label>Statut:</label>
          <select v-model="filters.statut" @change="applyFilters">
            <option value="">Tous</option>
            <option value="brouillon">Brouillon</option>
            <option value="envoye">Envoyé</option>
            <option value="en_cours">En cours</option>
            <option value="termine">Terminé</option>
          </select>
        </div>
        <div class="filter-group">
          <label>Fournisseur:</label>
          <select v-model="filters.fournisseur" @change="applyFilters">
            <option value="">Tous</option>
            <option v-for="f in fournisseurs" :key="f.id" :value="f.id">{{ f.nom }}</option>
          </select>
        </div>
        <div class="filter-group">
          <label>Recherche:</label>
          <input v-model="filters.search" @input="applyFilters" type="text" placeholder="Numéro bon, devis, affaire...">
        </div>
      </div>
    </div>

    <!-- Liste des bons de commande -->
    <div v-if="filteredBonsCommande.length > 0" class="bons-commande-list">
      <div v-for="bon in filteredBonsCommande" :key="bon.id" class="bon-card">
        <div class="bon-header">
          <div class="bon-info">
            <h3>{{ bon.numero_bon }}</h3>
            <p><strong>Devis:</strong> {{ bon.devis?.numero_devis || 'N/A' }}</p>
            <p><strong>Affaire:</strong> {{ bon.affaires?.numero_affaire || 'N/A' }}</p>
            <p><strong>Date:</strong> {{ formatDate(bon.date_commande) }}</p>
          </div>
          <div class="bon-client">
            <p><strong>Client:</strong> {{ getClientName(bon.affaires?.clients) }}</p>
            <p><strong>Véhicule:</strong> {{ getVehiculeInfo(bon.affaires?.voitures) }}</p>
            <p><strong>Fournisseur:</strong> {{ bon.fournisseurs?.nom || 'Non spécifié' }}</p>
          </div>
          <div class="bon-status">
            <label>Statut:</label>
            <select 
              :value="bon.statut" 
              @change="updateBonStatus(bon.id, $event.target.value)"
              class="status-select"
              :class="'status-' + bon.statut"
            >
              <option value="brouillon">Brouillon</option>
              <option value="envoye">Envoyé</option>
              <option value="en_cours">En cours</option>
              <option value="termine">Terminé</option>
            </select>
          </div>
        </div>

        <div class="articles-section">
          <h4>Articles commandés ({{ bonArticles[bon.id]?.length || 0 }})</h4>
          <div v-if="bonArticles[bon.id]?.length > 0" class="articles-grid">
            <div v-for="article in bonArticles[bon.id]" :key="article.id" class="article-card">
              <div class="article-info">
                <h5>{{ article.description }}</h5>
                <div class="article-details">
                  <p><strong>Intervention:</strong> {{ article.intervention || 'N/A' }}</p>
                  <p><strong>Quantité:</strong> {{ article.quantite }}</p>
                  <p><strong>Prix unitaire:</strong> {{ article.prix_unitaire.toFixed(2) }} Dhs</p>
                  <p><strong>Total:</strong> {{ article.total_ht.toFixed(2) }} Dhs</p>
                </div>
              </div>
              <div class="article-actions">
                <div class="article-status">
                  <label>Statut:</label>
                  <select 
                    :value="article.statut" 
                    @change="updateArticleStatus(article.id, $event.target.value)"
                    class="article-status-select"
                  >
                    <option value="en_attente">En attente</option>
                    <option value="commande">Commandé</option>
                    <option value="recu">Reçu</option>
                    <option value="monte">Monté</option>
                  </select>
                  <span :class="['status-indicator', article.statut]"></span>
                </div>
                <div v-if="article.statut === 'recu'" class="date-reception">
                  <label>Date réception:</label>
                  <input 
                    type="date" 
                    :value="article.date_reception" 
                    @change="updateArticleReception(article.id, $event.target.value)"
                    class="date-input"
                  >
                </div>
                <div class="article-notes">
                  <label>Notes:</label>
                  <textarea 
                    :value="article.notes" 
                    @change="updateArticleNotes(article.id, $event.target.value)"
                    placeholder="Notes sur cet article..."
                    class="notes-textarea"
                  ></textarea>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="bon-totals">
          <div class="total-row">
            <span>Total HT:</span>
            <span>{{ bon.montant_total.toFixed(2) }} Dhs</span>
          </div>
          <div class="total-row">
            <span>TVA (20%):</span>
            <span>{{ (bon.montant_total * 0.20).toFixed(2) }} Dhs</span>
          </div>
          <div class="total-row total-ttc">
            <strong>
              <span>Total TTC:</span>
              <span>{{ (bon.montant_total * 1.20).toFixed(2) }} Dhs</span>
            </strong>
          </div>
        </div>

        <div class="bon-progress">
          <div class="progress-info">
            <span>Avancement: {{ bonProgress[bon.id] || 0 }}%</span>
          </div>
          <div class="progress-bar">
            <div class="progress" :style="{ width: (bonProgress[bon.id] || 0) + '%' }"></div>
          </div>
        </div>

        <div class="bon-actions">
          <button @click="printBonCommande(bon)" class="btn btn-info">
            Imprimer
          </button>
          <button @click="editBonCommande(bon)" class="btn btn-secondary">
            Modifier
          </button>
          <button @click="deleteBonCommande(bon.id)" class="btn btn-danger">
            Supprimer
          </button>
        </div>
      </div>
    </div>

    <div v-else class="empty-state">
      <p>Aucun bon de commande trouvé{{ Object.keys(filters).some(key => filters[key]) ? ' avec ces critères' : '' }}.</p>
      <p v-if="!bonsCommande.length" class="help-text">
        Les bons de commande sont créés automatiquement lorsqu'un devis est accepté.
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useDataService } from '../composables/useDataService'

const { bonsCommande, fournisseurs, dataService, loadAllData } = useDataService()

const bonArticles = ref({})
const bonProgress = ref({})
const filteredBonsCommande = ref([])

const filters = ref({
  statut: '',
  fournisseur: '',
  search: ''
})

// Charger les bons de commande avec leurs relations
const loadBonsCommande = async () => {
  try {
    console.log('Chargement des bons de commande...')
    
    // Tester d'abord avec la méthode simple
    const bonsSimples = await dataService.getAllBonsCommande()
    console.log('Bons de commande simples:', bonsSimples)
    
    // Puis avec les relations
    const bonsWithRelations = await dataService.getAllBonsCommandeWithRelations()
    console.log('Bons de commande avec relations:', bonsWithRelations)
    
    bonsCommande.value = bonsWithRelations
    
    // Charger les articles pour chaque bon de commande
    for (const bon of bonsCommande.value) {
      try {
        const articles = await dataService.getBonCommandeArticles(bon.id)
        console.log(`Articles pour bon ${bon.id}:`, articles)
        bonArticles.value[bon.id] = articles
        
        // Calculer le progrès
        const progress = await dataService.getBonCommandeProgress(bon.id)
        bonProgress.value[bon.id] = progress
      } catch (articleError) {
        console.error(`Erreur lors du chargement des articles pour le bon ${bon.id}:`, articleError)
        bonArticles.value[bon.id] = []
        bonProgress.value[bon.id] = 0
      }
    }
    
    applyFilters()
  } catch (error) {
    console.error('Erreur lors du chargement des bons de commande:', error)
    alert(`Erreur lors du chargement des bons de commande: ${error.message}`)
  }
}

const applyFilters = () => {
  let filtered = [...bonsCommande.value]
  
  if (filters.value.statut) {
    filtered = filtered.filter(bon => bon.statut === filters.value.statut)
  }
  
  if (filters.value.fournisseur) {
    filtered = filtered.filter(bon => bon.fournisseurs?.id === parseInt(filters.value.fournisseur))
  }
  
  if (filters.value.search) {
    const search = filters.value.search.toLowerCase()
    filtered = filtered.filter(bon => 
      bon.numero_bon?.toLowerCase().includes(search) ||
      bon.devis?.numero_devis?.toLowerCase().includes(search) ||
      bon.affaires?.numero_affaire?.toLowerCase().includes(search) ||
      getClientName(bon.affaires?.clients).toLowerCase().includes(search)
    )
  }
  
  filteredBonsCommande.value = filtered
}

const updateBonStatus = async (bonId, newStatus) => {
  try {
    await dataService.updateBonCommande(bonId, { statut: newStatus })
    await loadBonsCommande()
  } catch (error) {
    console.error('Erreur lors de la mise à jour du statut:', error)
    alert('Erreur lors de la mise à jour du statut')
  }
}

const updateArticleStatus = async (articleId, newStatus) => {
  try {
    const updateData = { statut: newStatus }
    if (newStatus === 'recu') {
      updateData.date_reception = new Date().toISOString().split('T')[0]
    }
    await dataService.updateBonCommandeArticle(articleId, updateData)
    await loadBonsCommande()
  } catch (error) {
    console.error('Erreur lors de la mise à jour du statut de l\'article:', error)
    alert('Erreur lors de la mise à jour du statut de l\'article')
  }
}

const updateArticleReception = async (articleId, dateReception) => {
  try {
    await dataService.updateBonCommandeArticle(articleId, { date_reception: dateReception })
    await loadBonsCommande()
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la date de réception:', error)
  }
}

const updateArticleNotes = async (articleId, notes) => {
  try {
    await dataService.updateBonCommandeArticle(articleId, { notes })
  } catch (error) {
    console.error('Erreur lors de la mise à jour des notes:', error)
  }
}

const printBonCommande = (bon) => {
  // Logique d'impression à implémenter
  console.log('Impression du bon de commande:', bon.numero_bon)
}

const editBonCommande = (bon) => {
  // Logique d'édition à implémenter
  console.log('Édition du bon de commande:', bon.numero_bon)
}

const deleteBonCommande = async (bonId) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer ce bon de commande ?')) {
    try {
      await dataService.deleteBonCommande(bonId)
      await loadBonsCommande()
    } catch (error) {
      console.error('Erreur lors de la suppression du bon de commande:', error)
      alert('Erreur lors de la suppression du bon de commande')
    }
  }
}

const getClientName = (client) => {
  if (!client) return 'N/A'
  return `${client.nom} ${client.prenom}`
}

const getVehiculeInfo = (voiture) => {
  if (!voiture) return 'N/A'
  return `${voiture.marque} ${voiture.modele} (${voiture.immatriculation})`
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString('fr-FR')
}

onMounted(() => {
  loadAllData().then(() => {
    loadBonsCommande()
  })
})
</script>

<style scoped>
.page-container {
  padding: 20px;
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 30px;
}

.page-subtitle {
  color: #7f8c8d;
  font-style: italic;
  margin-top: 10px;
}

.filters-section {
  background: white;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.filters-row {
  display: flex;
  gap: 20px;
  align-items: end;
}

.filter-group {
  flex: 1;
}

.filter-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
  color: #2c3e50;
}

.filter-group select,
.filter-group input {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.bons-commande-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.bon-card {
  background: white;
  border-radius: 8px;
  padding: 25px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  border-left: 4px solid #3498db;
}

.bon-header {
  display: grid;
  grid-template-columns: 1fr 1fr auto;
  gap: 20px;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid #eee;
}

.bon-info h3 {
  color: #2c3e50;
  margin-bottom: 10px;
  font-size: 18px;
}

.bon-info p,
.bon-client p {
  margin: 5px 0;
  font-size: 14px;
}

.bon-status {
  display: flex;
  flex-direction: column;
  align-items: end;
}

.status-select {
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-weight: bold;
  color: white;
  margin-top: 5px;
}

.status-brouillon { background-color: #95a5a6; }
.status-envoye { background-color: #f39c12; }
.status-en_cours { background-color: #3498db; }
.status-termine { background-color: #27ae60; }

.articles-section h4 {
  color: #2c3e50;
  margin-bottom: 15px;
  display: flex;
  align-items: center;
  gap: 10px;
}

.articles-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 15px;
  margin-bottom: 20px;
}

.article-card {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 6px;
  border-left: 3px solid #3498db;
}

.article-info h5 {
  color: #2c3e50;
  margin-bottom: 10px;
  font-size: 16px;
}

.article-details {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 5px;
  margin-bottom: 15px;
}

.article-details p {
  margin: 2px 0;
  font-size: 13px;
}

.article-actions {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.article-status {
  display: flex;
  align-items: center;
  gap: 10px;
}

.article-status-select {
  padding: 4px 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 12px;
}

.status-indicator {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  flex-shrink: 0;
}

.status-indicator.en_attente { background: #95a5a6; }
.status-indicator.commande { background: #f39c12; }
.status-indicator.recu { background: #3498db; }
.status-indicator.monte { background: #27ae60; }

.date-reception {
  display: flex;
  align-items: center;
  gap: 10px;
}

.date-input {
  padding: 4px 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 12px;
}

.article-notes {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.notes-textarea {
  padding: 4px 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 12px;
  resize: vertical;
  min-height: 50px;
}

.bon-totals {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 6px;
  margin-bottom: 20px;
}

.total-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}

.total-ttc {
  border-top: 2px solid #2c3e50;
  padding-top: 8px;
  font-size: 16px;
}

.bon-progress {
  margin-bottom: 20px;
}

.progress-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 14px;
  font-weight: bold;
}

.progress-bar {
  height: 8px;
  background: #ecf0f1;
  border-radius: 4px;
  overflow: hidden;
}

.progress {
  height: 100%;
  background: linear-gradient(90deg, #f39c12, #3498db, #27ae60);
  transition: width 0.3s ease;
}

.bon-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.btn-info { background: #17a2b8; color: white; }
.btn-secondary { background: #6c757d; color: white; }
.btn-danger { background: #dc3545; color: white; }

.btn:hover {
  opacity: 0.8;
}

.empty-state {
  text-align: center;
  padding: 50px;
  color: #7f8c8d;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.help-text {
  margin-top: 10px;
  font-style: italic;
  color: #95a5a6;
}

@media (max-width: 768px) {
  .filters-row {
    flex-direction: column;
    gap: 15px;
  }
  
  .bon-header {
    grid-template-columns: 1fr;
    gap: 15px;
  }
  
  .articles-grid {
    grid-template-columns: 1fr;
  }
  
  .article-details {
    grid-template-columns: 1fr;
  }
}
</style>
