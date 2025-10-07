<template>
  <div class="page-container">
    <!-- Ajout de l'indicateur de chargement -->
    <div v-if="loading" class="loading-state">
      <p>Chargement des données...</p>
      <p v-if="error" class="error-message">{{ error }}</p>
    </div>

    <div v-else>
      <div class="page-header">
        <h1>Gestion des Articles</h1>
        <button @click="openNewArticleForm" class="btn btn-primary">Nouvel Article</button>
      </div>

      <!-- Formulaire -->
      <div v-if="showForm" class="form-modal">
        <div class="form-container">
          <h2>{{ editingArticle ? 'Modifier' : 'Nouvel' }} Article</h2>
          <form @submit.prevent="saveArticle">
            <div class="form-group">
              <label>Description *</label>
              <input v-model="form.Description" type="text" required>
            </div>
            <div class="form-group">
              <label>Prix HT *</label>
              <input v-model.number="form.PrixHT" type="number" step="0.01" required>
            </div>
            <div class="form-group">
              <label>Fournisseur</label>
              <select v-model="form.Fournisseur">
                <option :value="null">Sélectionner un fournisseur</option>
                <option v-for="fournisseur in fournisseurs" :key="fournisseur.id" :value="fournisseur.id">
                  {{ fournisseur.nom }}
                </option>
              </select>
            </div>
            
            <div class="form-actions">
              <button type="submit" class="btn btn-primary">
                {{ editingArticle ? 'Modifier' : 'Créer' }}
              </button>
              <button type="button" @click="cancelForm" class="btn btn-secondary">
                Annuler
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Liste des articles -->
      <div class="table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Description</th>
              <th>Prix HT</th>
              <th>Fournisseur</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="article in articles" :key="article.id">
              <td>{{ article.id }}</td>
              <td>{{ article.Description }}</td>
              <td>{{ article.PrixHT }}</td>
              <td>{{ getFournisseurName(article.Fournisseur) }}</td>
              <td class="actions">
                <button @click="editArticle(article)" class="btn-action btn-edit">
                  ✏️
                </button>
                <button @click="deleteArticle(article.id)" class="btn-action btn-delete">
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
import { ref, onMounted } from 'vue'
import { useDataService } from '../composables/useDataService'

const loading = ref(true)
const error = ref(null)

const { articles, fournisseurs, dataService, loadAllData: originalLoadAllData } = useDataService()

const loadAllData = async () => {
  loading.value = true
  error.value = null
  try {
    await originalLoadAllData()
  } catch (err) {
    console.error('Erreur critique:', err)
    error.value = `Échec du chargement des données: ${err.message}`
  } finally {
    loading.value = false
  }
}

onMounted(loadAllData)

const showForm = ref(false)
const editingArticle = ref(null)

const form = ref({
  Description: '',
  PrixHT: 0,
  Fournisseur: null
})

const resetForm = () => {
  form.value = {
    Description: '',
    PrixHT: 0,
    Fournisseur: null
  }
  editingArticle.value = null
}

const saveArticle = async () => {
  try {
    const articleData = { ...form.value };
    if (editingArticle.value) {
      await dataService.updateArticle(editingArticle.value.id, articleData)
    } else {
      await dataService.createArticle(articleData)
    }
    await loadAllData()
    cancelForm()
  } catch (error) {
    console.error('Erreur lors de la sauvegarde de l\'article:', error)
    alert(`Erreur lors de ${editingArticle.value ? 'la modification' : 'la création'} de l\'article: ${error.message}`)
  }
}

const editArticle = (article) => {
  editingArticle.value = article
  form.value = { ...article }
  showForm.value = true
}

const openNewArticleForm = () => {
  resetForm()
  showForm.value = true
}

const deleteArticle = async (id) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer cet article ?')) {
    try {
      await dataService.deleteArticle(id)
      await loadAllData()
    } catch (error) {
      console.error('Erreur lors de la suppression de l\'article:', error)
    }
  }
}

const cancelForm = () => {
  showForm.value = false
  resetForm()
}

const getFournisseurName = (fournisseurId) => {
    if (!fournisseurId) return 'N/A';
    const fournisseur = fournisseurs.value.find(f => f.id === fournisseurId);
    return fournisseur ? fournisseur.nom : 'Inconnu';
 };
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
.form-group textarea,
.form-group select {
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