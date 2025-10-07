
<template>
  <div class="page-container">
    <div class="page-header">
      <h1>Gestion des Clients</h1>
      <button @click="openNewClientForm" class="btn btn-primary">Nouveau Client</button>
    </div>

    <!-- Formulaire -->
    <div v-if="showForm" class="form-modal">
      <div class="form-container">
        <h2>{{ editingClient ? 'Modifier' : 'Nouveau' }} Client</h2>
        <form @submit.prevent="saveClient">
          <div class="form-group">
            <label>Nom *</label>
            <input v-model="form.nom" type="text" required>
          </div>
          <div class="form-group">
            <label>Prénom *</label>
            <input v-model="form.prenom" type="text" required>
          </div>
          <div class="form-group">
            <label>Téléphone</label>
            <input v-model="form.telephone" type="tel">
          </div>
          <div class="form-group">
            <label>Email</label>
            <input v-model="form.email" type="email">
          </div>
          <div class="form-group">
            <label>Adresse</label>
            <textarea v-model="form.adresse" rows="3"></textarea>
          </div>
          <div class="form-group">
            <label>ICE</label>
            <input v-model="form.ice" type="text">
          </div>
          
          <div class="form-actions">
            <button type="submit" class="btn btn-primary">
              {{ editingClient ? 'Modifier' : 'Créer' }}
            </button>
            <button type="button" @click="cancelForm" class="btn btn-secondary">
              Annuler
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Liste des clients -->
    <div class="table-container">
      <table class="data-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Nom</th>
            <th>Prénom</th>
            <th>Téléphone</th>
            <th>Email</th>
            <th>Adresse</th>
            <th>ICE</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="client in clients" :key="client.id">
            <td>{{ client.id }}</td>
            <td>{{ client.nom }}</td>
            <td>{{ client.prenom }}</td>
            <td>{{ client.telephone }}</td>
            <td>{{ client.email }}</td>
            <td>{{ client.adresse }}</td>
            <td>{{ client.ice }}</td>
            <td class="actions">
              <button @click="editClient(client)" class="btn-action btn-edit">
                ✏️
              </button>
              <button @click="deleteClient(client.id)" class="btn-action btn-delete">
                🗑️
              </button>
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

const { clients, dataService, loadAllData } = useDataService()

const showForm = ref(false)
const editingClient = ref(null)

const form = ref({
  nom: '',
  prenom: '',
  telephone: '',
  email: '',
  adresse: '',
  ice: ''
})

const resetForm = () => {
  form.value = {
    nom: '',
    prenom: '',
    telephone: '',
    email: '',
    adresse: '',
    ice: ''
  }
  editingClient.value = null
}

const saveClient = async () => {
  try {
    const clientData = { ...form.value };
    const excludeId = editingClient.value ? editingClient.value.id : null;

    const { exists, field } = await dataService.checkClientExists(clientData.ice, clientData.email, excludeId);

    if (exists) {
      alert(`Un client avec cet ${field} existe déjà.`);
      return;
    }

    if (editingClient.value) {
      // Modification
      await dataService.updateClient(editingClient.value.id, clientData);
    } else {
      // Création
      await dataService.createClient(clientData);
    }
    await loadAllData();
    cancelForm();
  } catch (error) {
    console.error('Erreur lors de la sauvegarde du client:', error);
    alert(`Erreur lors de ${editingClient.value ? 'la modification' : 'la création'} du client: ${error.message}`);
  }
}

const editClient = (client) => {
  editingClient.value = client
  form.value = { ...client }
  showForm.value = true
}

const openNewClientForm = () => {
  resetForm()
  showForm.value = true
}

const deleteClient = async (id) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer ce client ?')) {
    try {
      await dataService.deleteClient(id)
      await loadAllData()
    } catch (error) {
      console.error('Erreur lors de la suppression du client:', error)
      // Optionnel: afficher un message d'erreur à l'utilisateur
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