
<template>
  <div class="page-container">
    <!-- Ajout de l'indicateur de chargement -->
    <div v-if="loading" class="loading-state">
      <p>Chargement des données...</p>
      <p v-if="error" class="error-message">{{ error }}</p>
    </div>

    <div v-else>
      <div class="page-header">
        <h1>Gestion des Véhicules</h1>
        <button @click="showForm = true" class="btn btn-primary">Nouveau Véhicule</button>
      </div>

    <!-- Formulaire -->
    <div v-if="showForm" class="form-modal">
      <div class="form-container">
        <h2>{{ editingVoiture ? 'Modifier' : 'Nouveau' }} Véhicule</h2>
        <form @submit.prevent="saveVoiture">
          <div class="form-group">
            <label>Immatriculation *</label>
            <input v-model="form.immatriculation" type="text" required>
          </div>

          <div class="form-group">
            <label class="label-with-action">
              <span>Marque *</span>
              <button type="button" @click="toggleAddMarque" class="btn-add-inline">
                {{ isAddingMarque ? 'Annuler' : '+' }}
              </button>
            </label>
            <div v-if="!isAddingMarque">
              <select v-model="form.marque" required>
                <option disabled value="">Sélectionnez une marque</option>
                <option v-for="marqueName in Object.keys(carData).sort()" :key="marqueName" :value="marqueName">
                  {{ marqueName }}
                </option>
              </select>
            </div>
            <div v-else class="input-with-actions">
              <input 
                ref="newMarqueInput"
                v-model="newMarque" 
                @keyup.enter.prevent="addMarque"
                type="text" 
                placeholder="Nom de la nouvelle marque"
              >
              <button type="button" @click="addMarque" class="btn-action btn-confirm">✔️</button>
            </div>
          </div>

          <div class="form-group">
            <label class="label-with-action">
              <span>Modèle *</span>
              <button 
                type="button" 
                @click="toggleAddModele" 
                class="btn-add-inline"
                :disabled="!form.marque"
              >
                {{ isAddingModele ? 'Annuler' : '+' }}
              </button>
            </label>
            <div v-if="!isAddingModele">
              <select v-model="form.modele" required :disabled="!form.marque">
                <option disabled value="">
                  {{ form.marque ? (modelesDisponibles.length > 0 ? 'Sélectionnez un modèle' : 'Aucun modèle, ajoutez-en un') : 'Choisissez une marque' }}
                </option>
                <option v-for="modeleName in modelesDisponibles" :key="modeleName" :value="modeleName">
                  {{ modeleName }}
                </option>
              </select>
            </div>
            <div v-else class="input-with-actions">
              <input 
                ref="newModeleInput"
                v-model="newModele" 
                @keyup.enter.prevent="addModele"
                type="text" 
                placeholder="Nom du nouveau modèle"
              >
              <button type="button" @click="addModele" class="btn-action btn-confirm">✔️</button>
            </div>
          </div>
          <div class="form-group">
            <label>Numéro de chassis</label>
            <input v-model="form.num_chassis" type="text">
          </div>
          <div class="form-group">
            <label>Date de mise en circulation</label>
            <input v-model="form.date_mec" type="date">
          </div>
          <div class="form-group">
            <label>Client</label>
            <select v-model="form.client_id">
              <option v-for="client in clients" :key="client.id" :value="client.id">
                {{ client.nom }} {{ client.prenom }}
              </option>
            </select>
          </div>
          
          <div class="form-actions">
            <button type="submit" class="btn btn-primary">
              {{ editingVoiture ? 'Modifier' : 'Créer' }}
            </button>
            <button type="button" @click="cancelForm" class="btn btn-secondary">
              Annuler
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Liste des voitures -->
    <div class="table-container">
      <table class="data-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Immatriculation</th>
            <th>Marque</th>
            <th>Modèle</th>
            <th>Numéro de chassis</th>
            <th>Date MEC</th>
            <th>Client</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="voiture in voitures" :key="voiture.id">
            <td>{{ voiture.id }}</td>
            <td>{{ voiture.immatriculation }}</td>
            <td>{{ voiture.marque }}</td>
            <td>{{ voiture.modele }}</td>
            <td>{{ voiture.num_chassis }}</td>
            <td>{{ voiture.date_mec }}</td>
            <td>{{ getClientName(voiture.client_id) }}</td>
            <td class="actions">
              <button @click="editVoiture(voiture)" class="btn-action btn-edit">
                ✏️
              </button>
              <button @click="deleteVoiture(voiture.id)" class="btn-action btn-delete">
                🗑️
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, nextTick, onMounted } from 'vue'
import { useDataService } from '../composables/useDataService'

// Ajout de l'état de chargement
const loading = ref(true)

// Modification de la fonction loadAllData pour gérer le chargement
const { voitures, clients, dataService, loadAllData: originalLoadAllData } = useDataService()

const loadAllData = async () => {
  loading.value = true
  error.value = null
  try {
    await originalLoadAllData()
    if (!voitures.value || voitures.value.length === 0) {
      throw new Error('Aucune donnée véhicule trouvée')
    }
  } catch (error) {
    console.error('Erreur critique:', error)
    error.value = `Échec du chargement: ${error.message}`
    loading.value = false
    throw error
  }
  loading.value = false
}

// Initialiser les données au montage du composant
onMounted(loadAllData)
const showForm = ref(false)
const editingVoiture = ref(null)

// --- START: New data and logic for dynamic selects ---
const carData = ref({
  'Peugeot': ['208', '308', '508', '2008', '3008', '5008', 'Partner'],
  'Citroën': ['C3', 'C4', 'C5 Aircross', 'Berlingo', 'Jumpy'],
  'Renault': ['Clio', 'Megane', 'Captur', 'Kadjar', 'Kangoo'],
  'Dacia': ['Sandero', 'Logan', 'Duster', 'Spring'],
  'Ford': ['Fiesta', 'Focus', 'Puma', 'Kuga', 'Ranger'],
  'Volkswagen': ['Polo', 'Golf', 'T-Roc', 'Tiguan', 'Passat'],
  'Mercedes-Benz': ['Classe A', 'Classe C', 'Classe E', 'GLA', 'GLC'],
  'BMW': ['Série 1', 'Série 3', 'Série 5', 'X1', 'X3', 'X5'],
  'Audi': ['A1', 'A3', 'A4', 'Q2', 'Q3', 'Q5'],
  'Toyota': ['Yaris', 'Corolla', 'C-HR', 'RAV4', 'Hilux'],
  'Hyundai': ['i10', 'i20', 'i30', 'Tucson', 'Kona'],
  'Kia': ['Picanto', 'Rio', 'Ceed', 'Sportage', 'Stonic'],
  'Fiat': ['500', 'Panda', 'Tipo', 'Fiorino'],
  'Opel': ['Corsa', 'Astra', 'Mokka', 'Crossland'],
  'Skoda': ['Fabia', 'Octavia', 'Kamiq', 'Karoq']
});

const isAddingMarque = ref(false);
const newMarque = ref('');
const newMarqueInput = ref(null);

const isAddingModele = ref(false);
const newModele = ref('');
const newModeleInput = ref(null);

const modelesDisponibles = computed(() => {
  if (form.value.marque && carData.value[form.value.marque]) {
    return carData.value[form.value.marque].sort();
  }
  return [];
});

watch(() => form.value.marque, () => {
  form.value.modele = '';
  isAddingModele.value = false;
});

const toggleAddMarque = () => {
  isAddingMarque.value = !isAddingMarque.value;
  if (isAddingMarque.value) {
    nextTick(() => { newMarqueInput.value?.focus(); });
  }
};

const addMarque = () => {
  const marqueToAdd = newMarque.value.trim();
  if (marqueToAdd && !carData.value[marqueToAdd]) {
    carData.value[marqueToAdd] = [];
    form.value.marque = marqueToAdd;
  }
  newMarque.value = '';
  isAddingMarque.value = false;
};

const toggleAddModele = () => {
  isAddingModele.value = !isAddingModele.value;
  if (isAddingModele.value) {
    nextTick(() => { newModeleInput.value?.focus(); });
  }
};

const addModele = () => {
  const modeleToAdd = newModele.value.trim();
  const currentMarque = form.value.marque;
  if (modeleToAdd && currentMarque && carData.value[currentMarque]) {
    if (!carData.value[currentMarque].includes(modeleToAdd)) {
      carData.value[currentMarque].push(modeleToAdd);
    }
    form.value.modele = modeleToAdd;
  }
  newModele.value = '';
  isAddingModele.value = false;
};
// --- END: New data and logic for dynamic selects ---

const form = ref({
  immatriculation: '',
  marque: '',
  modele: '',
  num_chassis: '',
  date_mec: '',
  client_id: null
})

const resetForm = () => {
  form.value = {
    immatriculation: '',
    marque: '',
    modele: '',
    num_chassis: '',
    date_mec: '',
    client_id: null
  }
  editingVoiture.value = null
}

// Ajout de l'état d'erreur
const error = ref(null)

const saveVoiture = async () => {
  error.value = null
  try {
    const voitureData = { 
      immatriculation: form.value.immatriculation,
      marque: form.value.marque,
      modele: form.value.modele,
      num_chassis: form.value.num_chassis,
      date_mec: form.value.date_mec,
      client_id: form.value.client_id
    }
    
    if (editingVoiture.value) {
      await dataService.updateVoiture(editingVoiture.value.id, voitureData)
    } else {
      await dataService.createVoiture(voitureData)
    }
    
    await loadAllData()
    cancelForm()
  } catch (error) {
    console.error('Erreur lors de la sauvegarde de la voiture:', error)
    error.value = `Erreur lors de la sauvegarde: ${error.message}`
  }
}

const getClientName = (clientId) => {
  if (!clientId) return 'Aucun client'
  const client = clients.value.find(c => c.id === clientId)
  return client ? `${client.nom} ${client.prenom}` : 'Client inconnu'
}

const editVoiture = (voiture) => {
  form.value = {
    immatriculation: voiture.immatriculation,
    marque: voiture.marque,
    modele: voiture.modele,
    num_chassis: voiture.num_chassis,
    date_mec: voiture.date_mec,
    client_id: voiture.client_id
  }
  editingVoiture.value = voiture
  showForm.value = true
}

const deleteVoiture = async (id) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer cette voiture ?')) {
    try {
      await dataService.deleteVoiture(id)
      await loadAllData()
    } catch (error) {
      console.error('Erreur lors de la suppression:', error)
    }
  }
}

const cancelForm = () => {
  showForm.value = false
  resetForm()
  isAddingMarque.value = false
  isAddingModele.value = false
  newMarque.value = ''
  newModele.value = ''
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
  width: 600px;
  max-width: 90vw;
  max-height: 90vh;
  overflow-y: auto;
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
  width: 80px;
  height: 80px;
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

.photo-count {
  color: #7f8c8d;
  font-size: 12px;
}

.photo-mini-gallery {
  display: flex;
  gap: 5px;
  margin-top: 5px;
}

.photo-mini {
  width: 30px;
  height: 30px;
  object-fit: cover;
  border-radius: 2px;
  border: 1px solid #ddd;
  cursor: pointer;
}

.more-photos {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 30px;
  height: 30px;
  background: #95a5a6;
  color: white;
  font-size: 10px;
  border-radius: 2px;
}

.photo-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
}

.photo-modal-content {
  position: relative;
  max-width: 90vw;
  max-height: 90vh;
}

.modal-photo {
  max-width: 100%;
  max-height: 80vh;
  object-fit: contain;
}

.close-modal {
  position: absolute;
  top: -40px;
  right: 0;
  background: none;
  border: none;
  color: white;
  font-size: 30px;
  cursor: pointer;
}

.photo-navigation {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 20px;
  margin-top: 20px;
  color: white;
}

.nav-btn {
  background: rgba(255,255,255,0.2);
  border: none;
  color: white;
  font-size: 24px;
  padding: 10px 15px;
  border-radius: 50%;
  cursor: pointer;
}

.nav-btn:hover {
  background: rgba(255,255,255,0.3);
}

/* Styles communs */
.form-group {
  margin-bottom: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
  color: #34495e;
}

.form-group input {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

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

/* Styles pour les nouveaux éléments */
.label-with-action {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.btn-add-inline {
  background: #27ae60;
  color: white;
  border: none;
  border-radius: 50%;
  width: 22px;
  height: 22px;
  font-size: 16px;
  line-height: 22px;
  cursor: pointer;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-add-inline:disabled {
  background: #bdc3c7;
  cursor: not-allowed;
}

.input-with-actions {
  display: flex;
  gap: 5px;
}

.input-with-actions input {
  flex-grow: 1;
}

.btn-confirm {
  background: #27ae60;
}

.form-group select {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  background-color: white;
  height: 39px; /* Pour correspondre à la hauteur de l'input */
}

.error-message {
  color: #e74c3c;
  margin: 10px 0;
  padding: 10px;
  background-color: #fde8e8;
  border-radius: 4px;
}

.loading-state {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 200px;
  color: #666;
}
</style>