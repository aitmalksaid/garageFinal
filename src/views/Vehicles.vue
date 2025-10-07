
<template>
  <div class="vehicles-page">
    <div class="page-header">
      <h1>Gestion des Véhicules</h1>
      <button @click="showAddForm = !showAddForm" class="btn btn-primary">
        {{ showAddForm ? 'Annuler' : 'Ajouter Véhicule' }}
      </button>
    </div>

    <!-- Formulaire d'ajout/modification -->
    <div v-if="showAddForm" class="form-section">
      <h2>{{ editingVehicle ? 'Modifier' : 'Ajouter' }} Véhicule</h2>
      <form @submit.prevent="saveVehicle" class="vehicle-form">
        <div class="form-group">
          <label>Matricule:</label>
          <input v-model="form.matricule" type="text" required>
        </div>
        <div class="form-group">
          <label>Marque:</label>
          <input v-model="form.marque" type="text" required>
        </div>
        <div class="form-group">
          <label>Modèle:</label>
          <input v-model="form.modele" type="text" required>
        </div>
        
        <!-- Gestionnaire de photos -->
        <PhotoManager 
          v-model="form.photos" 
          title="Photos Carte Grise"
          :max-files="5"
          entity-type="vehicle"
          :entity-id="editingVehicle?.id || 'new'"
          :entity-name="`${form.marque} ${form.modele} - ${form.matricule}`"
        />
        
        <div class="form-actions">
          <button type="submit" class="btn btn-success">
            {{ editingVehicle ? 'Modifier' : 'Ajouter' }}
          </button>
          <button type="button" @click="cancelForm" class="btn btn-secondary">Annuler</button>
        </div>
      </form>
    </div>

    <!-- Liste des véhicules -->
    <div class="vehicles-list">
      <h2>Liste des Véhicules</h2>
      <div class="table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Matricule</th>
              <th>Marque</th>
              <th>Modèle</th>
              <th>Photos</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="vehicle in vehicles" :key="vehicle.id">
              <td>{{ vehicle.id }}</td>
              <td>{{ vehicle.matricule }}</td>
              <td>{{ vehicle.marque }}</td>
              <td>{{ vehicle.modele }}</td>
              <td>{{ vehicle.photos ? vehicle.photos.length : 0 }} photo(s)</td>
              <td class="actions">
                <button @click="editVehicle(vehicle)" class="btn btn-sm btn-warning">Modifier</button>
                <button @click="deleteVehicle(vehicle.id)" class="btn btn-sm btn-danger">Supprimer</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive } from 'vue'
import PhotoManager from '../components/PhotoManager.vue'

export default {
  name: 'Vehicles',
  components: {
    PhotoManager
  },
  setup() {
    const showAddForm = ref(false)
    const editingVehicle = ref(null)
    const vehicles = ref([
      { id: 1, matricule: 'ABC-123', marque: 'Peugeot', modele: '308', photos: [] },
      { id: 2, matricule: 'DEF-456', marque: 'Renault', modele: 'Clio', photos: [] }
    ])

    const form = reactive({
      matricule: '',
      marque: '',
      modele: '',
      photos: []
    })

    const saveVehicle = () => {
      if (editingVehicle.value) {
        const index = vehicles.value.findIndex(v => v.id === editingVehicle.value.id)
        vehicles.value[index] = { ...editingVehicle.value, ...form }
      } else {
        const newId = Math.max(...vehicles.value.map(v => v.id), 0) + 1
        vehicles.value.push({ id: newId, ...form })
      }
      // Sauvegarder dans localStorage
      localStorage.setItem('vehicles', JSON.stringify(vehicles.value))
      cancelForm()
    }

    const editVehicle = (vehicle) => {
      editingVehicle.value = vehicle
      Object.assign(form, vehicle)
      showAddForm.value = true
    }

    const deleteVehicle = (id) => {
      if (confirm('Êtes-vous sûr de vouloir supprimer ce véhicule ?')) {
        vehicles.value = vehicles.value.filter(v => v.id !== id)
      }
    }

    const cancelForm = () => {
      showAddForm.value = false
      editingVehicle.value = null
      Object.assign(form, { matricule: '', marque: '', modele: '', photos: [] })
    }

    return {
      showAddForm,
      editingVehicle,
      vehicles,
      form,
      saveVehicle,
      editVehicle,
      deleteVehicle,
      cancelForm
    }
  }
}
</script>

<style scoped>
.vehicles-page {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.form-section {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  margin-bottom: 30px;
}

.vehicle-form {
  display: grid;
  gap: 15px;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  font-weight: bold;
  margin-bottom: 5px;
}

.form-group input {
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.form-actions {
  display: flex;
  gap: 10px;
}

.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.btn-primary { background-color: #007bff; color: white; }
.btn-success { background-color: #28a745; color: white; }
.btn-warning { background-color: #ffc107; color: black; }
.btn-danger { background-color: #dc3545; color: white; }
.btn-secondary { background-color: #6c757d; color: white; }
.btn-sm { padding: 4px 8px; font-size: 12px; }

.vehicles-list {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.table-container {
  overflow-x: auto;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
}

.data-table th,
.data-table td {
  padding: 10px;
  text-align: left;
  border-bottom: 1px solid #ddd;
}

.data-table th {
  background-color: #f8f9fa;
  font-weight: bold;
}

.actions {
  display: flex;
  gap: 5px;
}
</style>
