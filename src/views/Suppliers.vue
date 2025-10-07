
<template>
  <div class="suppliers-page">
    <div class="page-header">
      <h1>Gestion des Fournisseurs</h1>
      <button @click="showAddForm = !showAddForm" class="btn btn-primary">
        {{ showAddForm ? 'Annuler' : 'Ajouter Fournisseur' }}
      </button>
    </div>

    <!-- Formulaire d'ajout/modification -->
    <div v-if="showAddForm" class="form-section">
      <h2>{{ editingSupplier ? 'Modifier' : 'Ajouter' }} Fournisseur</h2>
      <form @submit.prevent="saveSupplier" class="supplier-form">
        <div class="form-group">
          <label>Nom:</label>
          <input v-model="form.nom" type="text" required>
        </div>
        <div class="form-group">
          <label>Email:</label>
          <input v-model="form.email" type="email" required>
        </div>
        <div class="form-group">
          <label>Téléphone:</label>
          <input v-model="form.telephone" type="tel" required>
        </div>
        <div class="form-group">
          <label>Adresse:</label>
          <textarea v-model="form.adresse" required></textarea>
        </div>
        <div class="form-group">
          <label>Ville:</label>
          <input v-model="form.ville" type="text" required>
        </div>
        <div class="form-actions">
          <button type="submit" class="btn btn-success">
            {{ editingSupplier ? 'Modifier' : 'Ajouter' }}
          </button>
          <button type="button" @click="cancelForm" class="btn btn-secondary">Annuler</button>
        </div>
      </form>
    </div>

    <!-- Liste des fournisseurs -->
    <div class="suppliers-list">
      <h2>Liste des Fournisseurs</h2>
      <div class="table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Nom</th>
              <th>Email</th>
              <th>Téléphone</th>
              <th>Adresse</th>
              <th>Ville</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="supplier in suppliers" :key="supplier.id">
              <td>{{ supplier.id }}</td>
              <td>{{ supplier.nom }}</td>
              <td>{{ supplier.email }}</td>
              <td>{{ supplier.telephone }}</td>
              <td>{{ supplier.adresse }}</td>
              <td>{{ supplier.ville }}</td>
              <td class="actions">
                <button @click="editSupplier(supplier)" class="btn btn-sm btn-warning">Modifier</button>
                <button @click="deleteSupplier(supplier.id)" class="btn btn-sm btn-danger">Supprimer</button>
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
  name: 'Suppliers',
  setup() {
    const showAddForm = ref(false)
    const editingSupplier = ref(null)
    const suppliers = ref([
      {
        id: 1,
        nom: 'Pièces Auto France',
        email: 'contact@piecesautofrance.fr',
        telephone: '0123456789',
        adresse: '123 Rue de l\'Industrie',
        ville: 'Paris'
      },
      {
        id: 2,
        nom: 'Euro Car Parts',
        email: 'info@eurocarparts.fr',
        telephone: '0987654321',
        adresse: '456 Avenue des Pièces',
        ville: 'Lyon'
      }
    ])

    const form = reactive({
      nom: '',
      email: '',
      telephone: '',
      adresse: '',
      ville: ''
    })

    const saveSupplier = () => {
      if (editingSupplier.value) {
        const index = suppliers.value.findIndex(s => s.id === editingSupplier.value.id)
        suppliers.value[index] = { ...editingSupplier.value, ...form }
      } else {
        const newId = Math.max(...suppliers.value.map(s => s.id), 0) + 1
        suppliers.value.push({ id: newId, ...form })
      }
      cancelForm()
    }

    const editSupplier = (supplier) => {
      editingSupplier.value = supplier
      Object.assign(form, supplier)
      showAddForm.value = true
    }

    const deleteSupplier = (id) => {
      if (confirm('Êtes-vous sûr de vouloir supprimer ce fournisseur ?')) {
        suppliers.value = suppliers.value.filter(s => s.id !== id)
      }
    }

    const cancelForm = () => {
      showAddForm.value = false
      editingSupplier.value = null
      Object.assign(form, {
        nom: '',
        email: '',
        telephone: '',
        adresse: '',
        ville: ''
      })
    }

    return {
      showAddForm,
      editingSupplier,
      suppliers,
      form,
      saveSupplier,
      editSupplier,
      deleteSupplier,
      cancelForm
    }
  }
}
</script>

<style scoped>
.suppliers-page {
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

.supplier-form {
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

.suppliers-list {
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
