
<template>
  <div class="clients">
    <div class="page-header">
      <h1>Gestion des Clients</h1>
      <button @click="showModal = true" class="btn btn-primary">Ajouter un client</button>
    </div>

    <div class="clients-table">
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Nom</th>
            <th>Téléphone</th>
            <th>Email</th>
            <th>Adresse</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="client in clients" :key="client.id">
            <td>{{ client.id }}</td>
            <td>{{ client.nom }}</td>
            <td>{{ client.telephone }}</td>
            <td>{{ client.email }}</td>
            <td>{{ client.adresse }}</td>
            <td class="actions">
              <button @click="editClient(client)" class="btn btn-sm btn-secondary">Modifier</button>
              <button @click="deleteClient(client.id)" class="btn btn-sm btn-danger">Supprimer</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Modal pour ajouter/modifier un client -->
    <div v-if="showModal" class="modal-overlay" @click="closeModal">
      <div class="modal" @click.stop>
        <div class="modal-header">
          <h3>{{ editingClient ? 'Modifier' : 'Ajouter' }} un client</h3>
          <button @click="closeModal" class="close-btn">&times;</button>
        </div>
        
        <form @submit.prevent="saveClient" class="modal-form">
          <div class="form-group">
            <label>Nom *</label>
            <input v-model="currentClient.nom" type="text" class="form-input" required>
          </div>
          
          <div class="form-group">
            <label>Téléphone *</label>
            <input v-model="currentClient.telephone" type="tel" class="form-input" required>
          </div>
          
          <div class="form-group">
            <label>Email *</label>
            <input v-model="currentClient.email" type="email" class="form-input" required>
          </div>
          
          <div class="form-group">
            <label>Adresse *</label>
            <textarea v-model="currentClient.adresse" class="form-input" rows="3" required></textarea>
          </div>
          
          <div class="modal-actions">
            <button type="submit" class="btn btn-primary">{{ editingClient ? 'Modifier' : 'Ajouter' }}</button>
            <button type="button" @click="closeModal" class="btn btn-secondary">Annuler</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const clients = ref([])
const showModal = ref(false)
const editingClient = ref(false)
const currentClient = ref({
  nom: '',
  telephone: '',
  email: '',
  adresse: ''
})

onMounted(() => {
  // Données d'exemple
  clients.value = [
    {
      id: 1,
      nom: 'Dupont Jean',
      telephone: '0123456789',
      email: 'jean.dupont@email.com',
      adresse: '123 Rue de la Paix, 75001 Paris'
    },
    {
      id: 2,
      nom: 'Durand Marie',
      telephone: '0987654321',
      email: 'marie.durand@email.com',
      adresse: '456 Avenue des Champs, 69000 Lyon'
    }
  ]
})

const editClient = (client) => {
  editingClient.value = true
  currentClient.value = { ...client }
  showModal.value = true
}

const deleteClient = (id) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer ce client ?')) {
    clients.value = clients.value.filter(c => c.id !== id)
  }
}

const saveClient = () => {
  if (editingClient.value) {
    const index = clients.value.findIndex(c => c.id === currentClient.value.id)
    if (index !== -1) {
      clients.value[index] = { ...currentClient.value }
    }
  } else {
    const newId = Math.max(...clients.value.map(c => c.id), 0) + 1
    clients.value.push({
      ...currentClient.value,
      id: newId
    })
  }
  closeModal()
}

const closeModal = () => {
  showModal.value = false
  editingClient.value = false
  currentClient.value = {
    nom: '',
    telephone: '',
    email: '',
    adresse: ''
  }
}
</script>

<style scoped>
.clients {
  max-width: 1200px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.clients-table {
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 15px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

th {
  background-color: #f8f9fa;
  font-weight: bold;
  color: #2c3e50;
}

.actions {
  display: flex;
  gap: 8px;
}

.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  font-weight: bold;
}

.btn-primary {
  background-color: #3498db;
  color: white;
}

.btn-secondary {
  background-color: #95a5a6;
  color: white;
}

.btn-danger {
  background-color: #e74c3c;
  color: white;
}

.btn-sm {
  padding: 6px 12px;
  font-size: 12px;
}

.btn:hover {
  opacity: 0.8;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal {
  background: white;
  border-radius: 8px;
  width: 500px;
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
  color: #999;
}

.modal-form {
  padding: 20px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
  color: #555;
}

.form-input {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.form-input:focus {
  outline: none;
  border-color: #3498db;
}

.modal-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>
