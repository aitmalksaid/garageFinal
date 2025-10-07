
<template>
  <div class="page-container">
    <div class="page-header">
      <h1>Gestion des Affaires</h1>
      <button @click="showForm = true" class="btn btn-primary">Nouvelle Affaire</button>
    </div>
    
    <!-- Formulaire -->
    <div v-if="showForm" class="form-modal">
      <div class="form-container">
        <h2>{{ editingAffaire ? 'Modifier' : 'Nouvelle' }} Affaire</h2>
        <form @submit.prevent="saveAffaire">
          <div class="form-group">
            <label>Date d'ouverture *</label>
            <input v-model="form.date_ouverture" type="date" required>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Voiture *</label>
              <select v-model="form.voiture_id" required>
                <option :value="null">Sélectionner une voiture</option>
                <option v-for="voiture in voitures" :key="voiture.id" :value="voiture.id">
                  {{ voiture.marque }} {{ voiture.modele }} ({{ voiture.immatriculation }})
                </option>
              </select>
            </div>
            <div class="form-group">
              <label>Client *</label>
              <select v-model="form.client_id" required>
                <option :value="null">Sélectionner un client</option>
                <option v-for="client in clients" :key="client.id" :value="client.id">
                  {{ client.nom }} {{ client.prenom }}
                </option>
              </select>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Assurance *</label>
              <select v-model="form.assurance_id" required>
                <option :value="null">Sélectionner une assurance</option>
                <option v-for="assurance in assurances" :key="assurance.id" :value="assurance.id">
                  {{ assurance.nom }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label>Expert 1 *</label>
              <select v-model="form.expert_id" required>
                <option :value="null">Sélectionner un expert</option>
                <option v-for="expert in experts" :key="expert.id" :value="expert.id">
                  {{ expert.nom }} {{ expert.prenom }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label>Expert 2 (Optionnel)</label>
              <select v-model="form.expert_id_2">
                <option :value="null">Sélectionner un expert</option>
                <option v-for="expert in experts" :key="expert.id" :value="expert.id">
                  {{ expert.nom }} {{ expert.prenom }}
                </option>
              </select>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Statut</label>
              <input v-model="form.statut" type="text">
            </div>
            <div class="form-group">
              <label>Ref. Sinistre</label>
              <input v-model="form.ref_Sin" type="text">
            </div>
          </div>
          
          <div class="form-actions">
            <button type="submit" class="btn btn-primary">
              {{ editingAffaire ? 'Modifier' : 'Créer' }}
            </button>
            <button type="button" @click="cancelForm" class="btn btn-secondary">
              Annuler
            </button>
          </div>
        </form>
      </div>
    </div>
    
    <!-- Liste des affaires -->
    <div class="table-container">
      <table class="data-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Numéro</th>
            <th>Ref. Sinistre</th>
            <th>Date ouverture</th>
            <th>Voiture</th>
            <th>Client</th>
            <th>Assurance</th>
            <th>Experts</th>
            <th>Statut</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="affaire in affaires" :key="affaire.id">
            <td>{{ affaire.id }}</td>
            <td>{{ affaire.numero_affaire }}</td>
            <td>{{ affaire.ref_Sin }}</td>
            <td>{{ formatDate(affaire.date_ouverture) }}</td>
            <td>{{ getVoitureInfo(affaire.voiture_id) }}</td>
            <td>{{ getClientName(affaire.client_id) }}</td>
            <td>{{ getAssuranceName(affaire.assurance_id) }}</td>
            <td>
              {{ getExpertName(affaire.expert_id) }}
              <span v-if="affaire.expert_id_2"><br/>{{ getExpertName(affaire.expert_id_2) }}</span>
            </td>
            <td>{{ affaire.statut }}</td>
            <td class="actions">
              <button @click="editAffaire(affaire)" class="btn-action btn-edit">✏️</button>
              <button @click="deleteAffaire(affaire.id)" class="btn-action btn-delete">🗑️</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useDataService } from '../composables/useDataService'

const { affaires, clients, voitures, assurances, experts, dataService, loadAllData } = useDataService()

const showForm = ref(false)
const editingAffaire = ref(null)

const form = ref({
  date_ouverture: new Date().toISOString().split('T')[0],
  voiture_id: null,
  client_id: null,
  assurance_id: null,
  expert_id: null,
  expert_id_2: null,
  statut: 'en-cours',
  ref_Sin: ''
})

const resetForm = () => {
  form.value = {
    date_ouverture: new Date().toISOString().split('T')[0],
    voiture_id: null,
    client_id: null,
    assurance_id: null,
    expert_id: null,
    expert_id_2: null,
    statut: 'en-cours',
    ref_Sin: ''
  }
  editingAffaire.value = null
}

const saveAffaire = async () => {
  try {
    if (editingAffaire.value) {
      await dataService.updateAffaire(editingAffaire.value.id, { ...form.value });
    } else {
      const affaireData = { ...form.value };
      const newAffaire = await dataService.createAffaire(affaireData);
      
      const selectedVoiture = voitures.value.find(v => v.id === newAffaire.voiture_id);
      if (!selectedVoiture) {
        throw new Error("Voiture sélectionnée non trouvée.");
      }
      
      const date = new Date(newAffaire.date_ouverture);
      const day = String(date.getDate()).padStart(2, '0');
      const month = String(date.getMonth() + 1).padStart(2, '0');
      
      const numero_affaire = `${newAffaire.id}/${day}-${month}-${selectedVoiture.marque.toUpperCase()}-${selectedVoiture.modele.toUpperCase()}`;
      
      await dataService.updateAffaire(newAffaire.id, { numero_affaire });
    }
    await loadAllData();
    cancelForm();
  } catch (error) {
    console.error("Erreur lors de la sauvegarde de l'affaire:", error);
    alert(`Erreur lors de la sauvegarde de l'affaire: ${error.message}`);
  }
};

const editAffaire = (affaire) => {
  editingAffaire.value = affaire
  form.value = {
    date_ouverture: affaire.date_ouverture.split('T')[0],
    voiture_id: affaire.voiture_id,
    client_id: affaire.client_id,
    assurance_id: affaire.assurance_id,
    expert_id: affaire.expert_id,
    expert_id_2: affaire.expert_id_2 || null,
    statut: affaire.statut,
    ref_Sin: affaire.ref_Sin || ''
  }
  showForm.value = true
}

const deleteAffaire = async (id) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer cette affaire ?')) {
    try {
      await dataService.deleteAffaire(id)
      await loadAllData()
    } catch (error) {
      console.error('Erreur lors de la suppression de l\'affaire:', error)
    }
  }
}

const cancelForm = () => {
  showForm.value = false
  resetForm()
}

const getClientName = (clientId) => {
  const client = clients.value.find(c => c.id === clientId)
  return client ? `${client.nom} ${client.prenom}` : 'Inconnu'
}

const getVoitureInfo = (voitureId) => {
  const voiture = voitures.value.find(v => v.id === voitureId)
  return voiture ? `${voiture.marque} ${voiture.modele}` : 'Inconnue'
}

const getAssuranceName = (assuranceId) => {
  const assurance = assurances.value.find(a => a.id === assuranceId)
  return assurance ? assurance.nom : 'Inconnue'
}

const getExpertName = (expertId) => {
  const expert = experts.value.find(e => e.id === expertId)
  return expert ? `${expert.nom} ${expert.prenom}` : 'Inconnu'
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  return new Date(dateString).toLocaleDateString('fr-FR')
}
</script>

<style scoped>
.page-container {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.form-modal {
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

.form-container {
  background: white;
  padding: 30px;
  border-radius: 8px;
  width: 700px;
  max-width: 90vw;
  max-height: 90vh;
  overflow-y: auto;
}

.form-row {
  display: flex;
  gap: 20px;
}

.form-group {
  margin-bottom: 15px;
  flex: 1;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
  color: #34495e;
}

.form-group input,
.form-group select {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.photos-preview {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 10px;
}

.photo-item {
  position: relative;
}

.photo-thumb {
  width: 60px;
  height: 60px;
  object-fit: cover;
  border-radius: 4px;
  border: 1px solid #ddd;
}

.btn-remove-photo {
  position: absolute;
  top: -5px;
  right: -5px;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  border: none;
  background: #e74c3c;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
}

.photos-cell {
  font-size: 12px;
}

.photos-cell span {
  display: block;
  margin-bottom: 2px;
}

.status {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: bold;
  text-transform: uppercase;
}

.status.en-cours { background: #f39c12; color: white; }
.status.prepare { background: #3498db; color: white; }
.status.envoye { background: #9b59b6; color: white; }
.status.accepte { background: #27ae60; color: white; }
.status.rejete { background: #e74c3c; color: white; }

.form-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
  margin-top: 20px;
}

.table-container {
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.data-table {
  width: 100%;
  border-collapse: collapse;
}

.data-table th,
.data-table td {
  padding: 12px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.data-table th {
  background: #f8f9fa;
  font-weight: bold;
  color: #2c3e50;
}

.data-table tbody tr:hover {
  background: #f8f9fa;
}

.actions {
  white-space: nowrap;
}

.btn-action {
  padding: 6px 10px;
  margin: 0 2px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.btn-edit {
  background: #f39c12;
}

.btn-delete {
  background: #e74c3c;
}

.btn {
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.btn-primary {
  background: #3498db;
  color: white;
}

.btn-secondary {
  background: #95a5a6;
  color: white;
}

.btn:hover {
  opacity: 0.9;
}
</style>
