    <script setup>
import { ref, computed, watch, nextTick, onMounted } from 'vue'
import { useDataService } from '../composables/useDataService'

// État de chargement et d'erreur
const loading = ref(true)
const error = ref(null)

const { voitures, clients, dataService, loadAllData: originalLoadAllData } = useDataService()

const carData = ref({});

const buildCarData = () => {
  const data = {};
  if (voitures.value) {
    for (const voiture of voitures.value) {
      if (voiture.marque) {
        if (!data[voiture.marque]) {
          data[voiture.marque] = new Set();
        }
        if (voiture.modele) {
          data[voiture.marque].add(voiture.modele);
        }
      }
    }
  }
  for (const marque in data) {
    data[marque] = Array.from(data[marque]).sort();
  }
  carData.value = data;
};

const loadAllData = async () => {
  loading.value = true
  error.value = null
  try {
    await originalLoadAllData()
    buildCarData() // Build car data after fetching
    if (!voitures.value || voitures.value.length === 0) {
      console.warn('Aucune donnée véhicule trouvée')
    }
  } catch (err) {
    console.error('Erreur lors du chargement des données:', err)
    error.value = `Échec du chargement: ${err.message}`
  } finally {
    loading.value = false
  }
}

// Initialiser les données au montage du composant
onMounted(loadAllData)

const showForm = ref(false)
const editingVoiture = ref(null)

// Déclaration du form en premier
const form = ref({
  immatriculation: '',
  marque: '',
  modele: '',
  num_chassis: '',
  date_mec: '',
  client_id: null
})

// --- START: Logic for dynamic selects ---
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
  if (modeleToAdd && currentMarque) {
    if (!carData.value[currentMarque]) {
      carData.value[currentMarque] = [];
    }
    if (!carData.value[currentMarque].includes(modeleToAdd)) {
      carData.value[currentMarque].push(modeleToAdd);
    }
    form.value.modele = modeleToAdd;
  }
  newModele.value = '';
  isAddingModele.value = false;
};
// --- END: New data and logic for dynamic selects ---

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
  } catch (err) {
    console.error('Erreur lors de la sauvegarde de la voiture:', err)
    error.value = `Erreur lors de la sauvegarde: ${err.message}`
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
    } catch (err) {
      console.error('Erreur lors de la suppression:', err)
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

<template>
  <div class="page-container">
    <!-- Affichage de l'état de chargement -->
    <div v-if="loading" class="loading-state">
      <p>Chargement des données...</p>
    </div>

    <!-- Affichage des erreurs -->
    <div v-else-if="error" class="error-state">
      <p>{{ error }}</p>
      <button @click="loadAllData" class="btn btn-primary">Réessayer</button>
    </div>

    <!-- Contenu principal -->
    <div v-else>
      <!-- Le reste de votre template existant -->
      <div class="page-header">
        <h1>Gestion des Véhicules</h1>
        <button @click="showForm = true" class="btn btn-primary">Nouveau Véhicule</button>
      </div>

      <!-- ... le reste de votre template ... -->

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

.loading-state, .error-state {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: 200px;
}

.error-state {
  color: #e74c3c;
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
  width: 500px;
  max-width: 90vw;
  max-height: 90vh;
  overflow-y: auto;
}

.form-container h2 {
  margin-bottom: 20px;
  color: #2c3e50;
}

.form-group {
  margin-bottom: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
  color: #34495e;
}

.label-with-action {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.btn-add-inline {
  background: #27ae60;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 4px 8px;
  cursor: pointer;
  font-size: 12px;
}

.btn-add-inline:disabled {
  background: #95a5a6;
  cursor: not-allowed;
}

.input-with-actions {
  display: flex;
  gap: 5px;
}

.input-with-actions input {
  flex: 1;
}

.btn-action {
  padding: 6px 10px;
  margin: 0 2px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.btn-confirm {
  background: #27ae60;
  color: white;
}

.btn-edit {
  background: #f39c12;
  color: white;
}

.btn-delete {
  background: #e74c3c;
  color: white;
}

.form-group input,
.form-group textarea,
.form-group select {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

select:disabled {
  background-color: #f2f2f2;
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
