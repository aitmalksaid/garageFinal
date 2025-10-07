
<template>
  <div class="cases-page">
    <div class="page-header">
      <h1>Gestion des Affaires</h1>
      <button @click="showAddForm = !showAddForm" class="btn btn-primary">
        {{ showAddForm ? 'Annuler' : 'Ajouter Affaire' }}
      </button>
    </div>

    <!-- Formulaire d'ajout/modification -->
    <div v-if="showAddForm" class="form-section">
      <h2>{{ editingCase ? 'Modifier' : 'Ajouter' }} Affaire</h2>
      <form @submit.prevent="saveCase" class="case-form">
        <div class="form-group">
          <label>Date d'entrée:</label>
          <input v-model="form.dateEntree" type="date" required>
        </div>
        <div class="form-group">
          <label>Client:</label>
          <select v-model="form.clientId" required>
            <option value="">Sélectionner un client</option>
            <option value="1">Client 1</option>
            <option value="2">Client 2</option>
          </select>
        </div>
        <div class="form-group">
          <label>Expert:</label>
          <select v-model="form.expertId" required>
            <option value="">Sélectionner un expert</option>
            <option value="1">Expert 1</option>
            <option value="2">Expert 2</option>
          </select>
        </div>
        <div class="form-group">
          <label>Assurance:</label>
          <select v-model="form.assuranceId" required>
            <option value="">Sélectionner une assurance</option>
            <option value="1">AXA</option>
            <option value="2">Allianz</option>
          </select>
        </div>
        <div class="form-group">
          <label>Statut Devis:</label>
          <select v-model="form.statutDevis" required>
            <option value="en_cours">En cours</option>
            <option value="prepare">Préparé</option>
            <option value="envoye">Envoyé</option>
            <option value="accepte">Accepté</option>
            <option value="rejete">Rejeté</option>
          </select>
        </div>
        <!-- Photos avant -->
        <PhotoManager 
          v-model="form.photosAvant" 
          title="Photos voiture avant"
          :max-files="10"
          entity-type="case-before"
          :entity-id="editingCase?.id || 'new'"
          :entity-name="`Affaire ${editingCase?.id || 'Nouvelle'} - ${form.client || 'Client'}`"
        />
        
        <!-- Photos après -->
        <PhotoManager 
          v-model="form.photosApres" 
          title="Photos voiture après"
          :max-files="10"
          entity-type="case-after"
          :entity-id="editingCase?.id || 'new'"
          :entity-name="`Affaire ${editingCase?.id || 'Nouvelle'} - ${form.client || 'Client'}`"
        />
        <div class="form-actions">
          <button type="submit" class="btn btn-success">
            {{ editingCase ? 'Modifier' : 'Ajouter' }}
          </button>
          <button type="button" @click="cancelForm" class="btn btn-secondary">Annuler</button>
        </div>
      </form>
    </div>

    <!-- Liste des affaires -->
    <div class="cases-list">
      <h2>Liste des Affaires</h2>
      <div class="table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Date d'entrée</th>
              <th>Client</th>
              <th>Expert</th>
              <th>Assurance</th>
              <th>Statut Devis</th>
              <th>Photos</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="caseItem in cases" :key="caseItem.id">
              <td>{{ caseItem.id }}</td>
              <td>{{ formatDate(caseItem.dateEntree) }}</td>
              <td>{{ caseItem.client }}</td>
              <td>{{ caseItem.expert }}</td>
              <td>{{ caseItem.assurance }}</td>
              <td>
                <span :class="getStatusClass(caseItem.statutDevis)">
                  {{ getStatusText(caseItem.statutDevis) }}
                </span>
              </td>
              <td>{{ (caseItem.photosAvant?.length || 0) + (caseItem.photosApres?.length || 0) }} photos</td>
              <td class="actions">
                <button @click="editCase(caseItem)" class="btn btn-sm btn-warning">Modifier</button>
                <button @click="deleteCase(caseItem.id)" class="btn btn-sm btn-danger">Supprimer</button>
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
  name: 'Cases',
  components: {
    PhotoManager
  },
  setup() {
    const showAddForm = ref(false)
    const editingCase = ref(null)
    const cases = ref([
      {
        id: 1,
        dateEntree: '2024-01-15',
        client: 'Dupont Jean',
        expert: 'Expert Auto Pro',
        assurance: 'AXA',
        statutDevis: 'en_cours',
        photosAvant: [],
        photosApres: []
      },
      {
        id: 2,
        dateEntree: '2024-01-20',
        client: 'Martin Paul',
        expert: 'Expertise Véhicule',
        assurance: 'Allianz',
        statutDevis: 'accepte',
        photosAvant: [],
        photosApres: []
      }
    ])

    const form = reactive({
      dateEntree: '',
      clientId: '',
      expertId: '',
      assuranceId: '',
      statutDevis: 'en_cours',
      photosAvant: [],
      photosApres: []
    })

    const saveCase = () => {
      if (editingCase.value) {
        const index = cases.value.findIndex(c => c.id === editingCase.value.id)
        cases.value[index] = { ...editingCase.value, ...form }
      } else {
        const newId = Math.max(...cases.value.map(c => c.id), 0) + 1
        cases.value.push({ id: newId, ...form })
      }
      // Sauvegarder dans localStorage
      localStorage.setItem('cases', JSON.stringify(cases.value))
      cancelForm()
    }

    const editCase = (caseItem) => {
      editingCase.value = caseItem
      Object.assign(form, caseItem)
      showAddForm.value = true
    }

    const deleteCase = (id) => {
      if (confirm('Êtes-vous sûr de vouloir supprimer cette affaire ?')) {
        cases.value = cases.value.filter(c => c.id !== id)
      }
    }

    const cancelForm = () => {
      showAddForm.value = false
      editingCase.value = null
      Object.assign(form, {
        dateEntree: '',
        clientId: '',
        expertId: '',
        assuranceId: '',
        statutDevis: 'en_cours',
        photosAvant: [],
        photosApres: []
      })
    }

    

    const formatDate = (dateStr) => {
      return new Date(dateStr).toLocaleDateString('fr-FR')
    }

    const getStatusText = (status) => {
      const statusMap = {
        'en_cours': 'En cours',
        'prepare': 'Préparé',
        'envoye': 'Envoyé',
        'accepte': 'Accepté',
        'rejete': 'Rejeté'
      }
      return statusMap[status] || status
    }

    const getStatusClass = (status) => {
      const classMap = {
        'en_cours': 'status-warning',
        'prepare': 'status-info',
        'envoye': 'status-primary',
        'accepte': 'status-success',
        'rejete': 'status-danger'
      }
      return `status-badge ${classMap[status] || ''}`
    }

    return {
      showAddForm,
      editingCase,
      cases,
      form,
      saveCase,
      editCase,
      deleteCase,
      cancelForm,
      formatDate,
      getStatusText,
      getStatusClass
    }
  }
}
</script>

<style scoped>
.cases-page {
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

.case-form {
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
.form-group select {
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

.cases-list {
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

.status-badge {
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: bold;
}

.status-success { background-color: #d4edda; color: #155724; }
.status-warning { background-color: #fff3cd; color: #856404; }
.status-danger { background-color: #f8d7da; color: #721c24; }
.status-info { background-color: #d1ecf1; color: #0c5460; }
.status-primary { background-color: #cce7ff; color: #004085; }
</style>
