
<template>
  <div class="page-container">
    <div class="page-header">
      <h1>Gestion des Fournisseurs</h1>
      <button @click="showForm = true" class="btn btn-primary">Nouveau Fournisseur</button>
    </div>

    <!-- Formulaire -->
    <div v-if="showForm" class="form-modal">
      <div class="form-container">
        <h2>{{ editingFournisseur ? 'Modifier' : 'Nouveau' }} Fournisseur</h2>
        <form @submit.prevent="saveFournisseur">
          <div class="form-group">
            <label>Nom *</label>
            <input v-model="form.nom" type="text" required>
          </div>
          <div class="form-group">
            <label>Email</label>
            <input v-model="form.email" type="email">
          </div>
          <div class="form-group">
            <label>Téléphone</label>
            <input v-model="form.telephone" type="tel">
          </div>
          <div class="form-group">
            <label>Adresse</label>
            <textarea v-model="form.adresse" rows="3"></textarea>
          </div>

          <div class="form-group">
            <label>Spécialité</label>
            <input v-model="form.specialite" type="text">
          </div>
          <div class="form-group">
            <label>Catégorie</label>
            <select v-model="form.categorie">
              <option value="original">Original</option>
              <option value="adaptable">Adaptable</option>
              <option value="occasion">Occasion</option>
              <option value="tous">Tous</option>
            </select>
          </div>
          
          <div class="form-actions">
            <button type="submit" class="btn btn-primary">
              {{ editingFournisseur ? 'Modifier' : 'Créer' }}
            </button>
            <button type="button" @click="cancelForm" class="btn btn-secondary">
              Annuler
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Liste des fournisseurs -->
    <div class="table-container">
      <table class="data-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Nom</th>
            <th>Email</th>
            <th>Téléphone</th>
            <th>Adresse</th>
            <th>Spécialité</th>
            <th>Catégorie</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="fournisseur in fournisseurs" :key="fournisseur.id">
            <td>{{ fournisseur.id }}</td>
            <td>{{ fournisseur.nom }}</td>
            <td>{{ fournisseur.email }}</td>
            <td>{{ fournisseur.telephone }}</td>
            <td>{{ fournisseur.adresse }}</td>
            <td>{{ fournisseur.specialite }}</td>
            <td>{{ fournisseur.categorie }}</td>
            <td class="actions">
              <button @click="editFournisseur(fournisseur)" class="btn-action btn-edit">✏️</button>
              <button @click="deleteFournisseur(fournisseur.id)" class="btn-action btn-delete">🗑️</button>
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

const { fournisseurs, dataService, loadAllData } = useDataService()

const showForm = ref(false)
const editingFournisseur = ref(null)

const form = ref({
  nom: '',
  email: '',
  telephone: '',
  adresse: '',
  specialite: '',
  categorie: ''
})

const resetForm = () => {
  form.value = {
    nom: '',
    email: '',
    telephone: '',
    adresse: '',
    specialite: '',
    categorie: ''
  }
  editingFournisseur.value = null
}

const saveFournisseur = async () => {
  try {
    const fournisseurData = { 
      nom: form.value.nom,
      email: form.value.email,
      telephone: form.value.telephone,
      adresse: form.value.adresse,
      specialite: form.value.specialite,
      categorie: form.value.categorie
    };
    
    if (editingFournisseur.value) {
      await dataService.updateFournisseur(editingFournisseur.value.id, fournisseurData)
    } else {
      await dataService.createFournisseur(fournisseurData)
    }
    await loadAllData()
    cancelForm()
  } catch (error) {
    console.error('Erreur lors de la sauvegarde du fournisseur:', error)
    alert("Échec de l'enregistrement : " + error.message)
  }
}

const editFournisseur = (fournisseur) => {
  editingFournisseur.value = fournisseur
  form.value = { ...fournisseur }
  showForm.value = true
}

const deleteFournisseur = async (id) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer ce fournisseur ?')) {
    try {
      await dataService.deleteFournisseur(id)
      await loadAllData()
    } catch (error) {
      console.error('Erreur lors de la suppression du fournisseur:', error)
    }
  }
}

const cancelForm = () => {
  showForm.value = false
  resetForm()
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