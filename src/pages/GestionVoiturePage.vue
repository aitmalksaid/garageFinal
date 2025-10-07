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
                <label>Marque *</label>
                <select v-model="form.marque" required @change="resetModele">
                  <option disabled value="">Sélectionnez une marque</option>
                  <option v-for="marqueName in Object.keys(carData).sort()" :key="marqueName" :value="marqueName">
                    {{ marqueName }}
                  </option>
                </select>
              </div>
  
              <div class="form-group">
                <label>Modèle *</label>
                <select v-model="form.modele" required :disabled="!form.marque">
                  <option disabled value="">
                    {{ form.marque ? (modelesDisponibles.length > 0 ? 'Sélectionnez un modèle' : 'Aucun modèle disponible') : 'Choisissez une marque' }}
                  </option>
                  <option v-for="modeleName in modelesDisponibles" :key="modeleName" :value="modeleName">
                    {{ modeleName }}
                  </option>
                </select>
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
  const error = ref(null)
  
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
    } finally {
      loading.value = false
    }
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
  
  const form = ref({
    immatriculation: '',
    marque: '',
    modele: '',
    num_chassis: '',
    date_mec: '',
    client_id: null
  })
  
  const modelesDisponibles = computed(() => {
    if (form.value.marque && carData.value[form.value.marque]) {
      return carData.value[form.value.marque].sort();
    }
    return [];
  });
  
  watch(() => form.value.marque, () => {
    form.value.modele = '';
  })
  
  const resetModele = () => {
    form.value.modele = '';
  }
  
  const saveVoiture = async () => {
    try {
      if (editingVoiture.value) {
        await dataService.updateVoiture(editingVoiture.value.id, form.value)
      } else {
        await dataService.createVoiture(form.value)
      }
      await loadAllData()
      cancelForm()
    } catch (error) {
      console.error('Erreur lors de la sauvegarde du véhicule:', error)
      alert(`Erreur lors de ${editingVoiture.value ? 'la modification' : 'la création'} du véhicule: ${error.message}`)
    }
  }
  
  const editVoiture = (voiture) => {
    editingVoiture.value = voiture
    form.value = { ...voiture }
    showForm.value = true
  }
  
  const deleteVoiture = async (id) => {
    if (confirm('Êtes-vous sûr de vouloir supprimer ce véhicule ?')) {
      try {
        await dataService.deleteVehicle(id)
        await loadAllData()
      } catch (error) {
        console.error('Erreur lors de la suppression du véhicule:', error)
        alert(`Erreur lors de la suppression du véhicule: ${error.message}`)
      }
    }
  }
  
  const cancelForm = () => {
    showForm.value = false
    editingVoiture.value = null
    form.value = {
      immatriculation: '',
      marque: '',
      modele: '',
      num_chassis: '',
      date_mec: '',
      client_id: null
    }
  }
  
  const getClientName = (clientId) => {
    const client = clients.value.find(c => c.id === clientId)
    return client ? `${client.nom} ${client.prenom}` : 'Client inconnu'
  }
  </script>
  
  <style scoped>
  /* Styles existants... */
  
  select {
    width: 100%;
    padding: 5px;
    border: 1px solid #ddd;
    border-radius: 4px;
  }
  
  select:disabled {
    background-color: #f2f2f2;
  }
  </style>