
<template>
  <div class="experts-page">
    <div class="page-header">
      <h1>Gestion des Experts</h1>
      <button @click="showAddForm = !showAddForm" class="btn btn-primary">
        {{ showAddForm ? 'Annuler' : 'Ajouter Expert' }}
      </button>
    </div>

    <!-- Formulaire d'ajout/modification -->
    <div v-if="showAddForm" class="form-section">
      <h2>{{ editingExpert ? 'Modifier' : 'Ajouter' }} Expert</h2>
      <form @submit.prevent="saveExpert" class="expert-form">
        <div class="form-group">
          <label>Nom:</label>
          <input v-model="form.nom" type="text" required>
        </div>
        <div class="form-group">
          <label>Adresse:</label>
          <textarea v-model="form.adresse" required></textarea>
        </div>
        <div class="form-group">
          <label>Téléphone:</label>
          <input v-model="form.telephone" type="tel" required>
        </div>
        <div class="form-group">
          <label>Email:</label>
          <input v-model="form.email" type="email" required>
        </div>
        <div class="form-actions">
          <button type="submit" class="btn btn-success">
            {{ editingExpert ? 'Modifier' : 'Ajouter' }}
          </button>
          <button type="button" @click="cancelForm" class="btn btn-secondary">Annuler</button>
        </div>
      </form>
    </div>

    <!-- Liste des experts -->
    <div class="experts-list">
      <h2>Liste des Experts</h2>
      <div class="table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Nom</th>
              <th>Adresse</th>
              <th>Téléphone</th>
              <th>Email</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="expert in experts" :key="expert.id">
              <td>{{ expert.id }}</td>
              <td>{{ expert.nom }}</td>
              <td>{{ expert.adresse }}</td>
              <td>{{ expert.telephone }}</td>
              <td>{{ expert.email }}</td>
              <td class="actions">
                <button @click="editExpert(expert)" class="btn btn-sm btn-warning">Modifier</button>
                <button @click="deleteExpert(expert.id)" class="btn btn-sm btn-danger">Supprimer</button>
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

export default {
  name: 'Experts',
  setup() {
    const showAddForm = ref(false)
    const editingExpert = ref(null)
    const experts = ref([
      { id: 1, nom: 'Expert Auto Pro', adresse: '123 Rue de la Paix', telephone: '0123456789', email: 'expert@autopro.com' },
      { id: 2, nom: 'Expertise Véhicule', adresse: '456 Avenue des Champs', telephone: '0987654321', email: 'contact@expertisevehicule.fr' }
    ])

    const form = reactive({
      nom: '',
      adresse: '',
      telephone: '',
      email: ''
    })

    const saveExpert = () => {
      if (editingExpert.value) {
        const index = experts.value.findIndex(e => e.id === editingExpert.value.id)
        experts.value[index] = { ...editingExpert.value, ...form }
      } else {
        const newId = Math.max(...experts.value.map(e => e.id), 0) + 1
        experts.value.push({ id: newId, ...form })
      }
      cancelForm()
    }

    const editExpert = (expert) => {
      editingExpert.value = expert
      Object.assign(form, expert)
      showAddForm.value = true
    }

    const deleteExpert = (id) => {
      if (confirm('Êtes-vous sûr de vouloir supprimer cet expert ?')) {
        experts.value = experts.value.filter(e => e.id !== id)
      }
    }

    const cancelForm = () => {
      showAddForm.value = false
      editingExpert.value = null
      Object.assign(form, { nom: '', adresse: '', telephone: '', email: '' })
    }

    return {
      showAddForm,
      editingExpert,
      experts,
      form,
      saveExpert,
      editExpert,
      deleteExpert,
      cancelForm
    }
  }
}
</script>

<style scoped>
.experts-page {
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

.expert-form {
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

.form-group input,
.form-group textarea {
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.form-group textarea {
  resize: vertical;
  min-height: 60px;
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

.experts-list {
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
