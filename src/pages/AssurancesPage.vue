
<template>
  <div class="page-container">
    <div class="page-header">
      <h1>Gestion des Assurances</h1>
      <button @click="showForm = true" class="btn btn-primary">Nouvelle Assurance</button>
    </div>

    <!-- Formulaire -->
    <div v-if="showForm" class="form-modal">
      <div class="form-container">
        <h2>{{ editingAssurance ? 'Modifier' : 'Nouvelle' }} Assurance</h2>
        <form @submit.prevent="saveAssurance">
          <div class="form-group">
            <label>Nom *</label>
            <input v-model="form.nom" type="text" required>
          </div>
          <div class="form-group">
            <label>Adresse</label>
            <textarea v-model="form.adresse" rows="3"></textarea>
          </div>
          <div class="form-group">
            <label>Téléphone</label>
            <input v-model="form.telephone" type="tel">
          </div>
          <div class="form-actions">
            <button type="submit" class="btn btn-primary">
              {{ editingAssurance ? 'Modifier' : 'Créer' }}
            </button>
            <button type="button" @click="cancelForm" class="btn btn-secondary">
              Annuler
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Liste des assurances -->
    <div class="table-container">
      <table class="data-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Nom</th>
            <th>Adresse</th>
            <th>Téléphone</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="assurance in assurances" :key="assurance.id">
            <td>{{ assurance.id }}</td>
            <td>{{ assurance.nom }}</td>
            <td>{{ assurance.adresse }}</td>
            <td>{{ assurance.telephone }}</td>
            <td class="actions">
              <button @click="editAssurance(assurance)" class="btn-action btn-edit">✏️</button>
              <button @click="deleteAssurance(assurance.id)" class="btn-action btn-delete">🗑️</button>
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

const { assurances, dataService, loadAllData } = useDataService()

const showForm = ref(false)
const editingAssurance = ref(null)

const form = ref({
 nom: '',
 adresse: '',
 telephone: ''
})

const resetForm = () => {
 form.value = {
   nom: '',
   adresse: '',
   telephone: ''
 }
 editingAssurance.value = null
}

const saveAssurance = async () => {
 try {
   const assuranceData = { ...form.value };
   if (editingAssurance.value) {
     await dataService.updateAssurance(editingAssurance.value.id, assuranceData)
   } else {
     await dataService.createAssurance(assuranceData)
   }
   await loadAllData()
   cancelForm()
 } catch (error) {
   console.error('Erreur lors de la sauvegarde de l\'assurance:', error)
 }
}

const editAssurance = (assurance) => {
 editingAssurance.value = assurance
 form.value = { ...assurance }
 showForm.value = true
}

const deleteAssurance = async (id) => {
 if (confirm('Êtes-vous sûr de vouloir supprimer cette assurance ?')) {
   try {
     await dataService.deleteAssurance(id)
     await loadAllData()
   } catch (error) {
     console.error('Erreur lors de la suppression de l\'assurance:', error)
   }
 }
}

const cancelForm = () => {
 showForm.value = false
 resetForm()
}
</script>

<style scoped>
/* Styles identiques aux autres pages CRUD */
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
  width: 500px;
  max-width: 90vw;
  max-height: 90vh;
  overflow-y: auto;
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

.form-group input,
.form-group textarea {
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
</style>
