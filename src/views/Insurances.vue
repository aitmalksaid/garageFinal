
<template>
  <div class="insurances-page">
    <div class="page-header">
      <h1>Gestion des Assurances</h1>
      <button @click="showAddForm = !showAddForm" class="btn btn-primary">
        {{ showAddForm ? 'Annuler' : 'Ajouter Assurance' }}
      </button>
    </div>

    <!-- Formulaire d'ajout/modification -->
    <div v-if="showAddForm" class="form-section">
      <h2>{{ editingInsurance ? 'Modifier' : 'Ajouter' }} Assurance</h2>
      <form @submit.prevent="saveInsurance" class="insurance-form">
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
            {{ editingInsurance ? 'Modifier' : 'Ajouter' }}
          </button>
          <button type="button" @click="cancelForm" class="btn btn-secondary">Annuler</button>
        </div>
      </form>
    </div>

    <!-- Liste des assurances -->
    <div class="insurances-list">
      <h2>Liste des Assurances</h2>
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
            <tr v-for="insurance in insurances" :key="insurance.id">
              <td>{{ insurance.id }}</td>
              <td>{{ insurance.nom }}</td>
              <td>{{ insurance.adresse }}</td>
              <td>{{ insurance.telephone }}</td>
              <td>{{ insurance.email }}</td>
              <td class="actions">
                <button @click="editInsurance(insurance)" class="btn btn-sm btn-warning">Modifier</button>
                <button @click="deleteInsurance(insurance.id)" class="btn btn-sm btn-danger">Supprimer</button>
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
  name: 'Insurances',
  setup() {
    const showAddForm = ref(false)
    const editingInsurance = ref(null)
    const insurances = ref([
      { id: 1, nom: 'AXA Assurance', adresse: '100 Boulevard Haussmann, Paris', telephone: '0800123456', email: 'contact@axa.fr' },
      { id: 2, nom: 'Allianz France', adresse: '87 Rue de Richelieu, Paris', telephone: '0800654321', email: 'service@allianz.fr' }
    ])

    const form = reactive({
      nom: '',
      adresse: '',
      telephone: '',
      email: ''
    })

    const saveInsurance = () => {
      if (editingInsurance.value) {
        const index = insurances.value.findIndex(i => i.id === editingInsurance.value.id)
        insurances.value[index] = { ...editingInsurance.value, ...form }
      } else {
        const newId = Math.max(...insurances.value.map(i => i.id), 0) + 1
        insurances.value.push({ id: newId, ...form })
      }
      cancelForm()
    }

    const editInsurance = (insurance) => {
      editingInsurance.value = insurance
      Object.assign(form, insurance)
      showAddForm.value = true
    }

    const deleteInsurance = (id) => {
      if (confirm('Êtes-vous sûr de vouloir supprimer cette assurance ?')) {
        insurances.value = insurances.value.filter(i => i.id !== id)
      }
    }

    const cancelForm = () => {
      showAddForm.value = false
      editingInsurance.value = null
      Object.assign(form, { nom: '', adresse: '', telephone: '', email: '' })
    }

    return {
      showAddForm,
      editingInsurance,
      insurances,
      form,
      saveInsurance,
      editInsurance,
      deleteInsurance,
      cancelForm
    }
  }
}
</script>

<style scoped>
.insurances-page {
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

.insurance-form {
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

.insurances-list {
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
