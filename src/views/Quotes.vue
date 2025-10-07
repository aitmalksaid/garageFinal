<template>
  <div class="quotes-page">
    <div class="page-header">
      <h1>Gestion des Devis</h1>
      <button @click="showAddForm = !showAddForm" class="btn btn-primary">
        {{ showAddForm ? 'Annuler' : 'Créer Devis' }}
      </button>
    </div>

    <!-- Formulaire de création/modification -->
    <div v-if="showAddForm" class="form-section">
      <h2>{{ editingQuote ? 'Modifier' : 'Créer' }} Devis</h2>
      <form @submit.prevent="saveQuote" class="quote-form">
        <div class="form-row">
          <div class="form-group">
            <label>Numéro:</label>
            <input v-model="form.numero" type="text" required>
          </div>
          <div class="form-group">
            <label>Date:</label>
            <input v-model="form.date" type="date" required>
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label>Client:</label>
            <select v-model="form.clientId" required>
              <option value="">Sélectionner un client</option>
              <option v-for="client in clients" :key="client.id" :value="client.id">
                {{ client.nom }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label>Matricule véhicule:</label>
            <input v-model="form.matriculeVehicule" type="text" required>
          </div>
        </div>

        <div class="form-group">
          <label>Statut:</label>
          <select v-model="form.statut" required>
            <option value="en_cours">En cours</option>
            <option value="prepare">Préparé</option>
            <option value="envoye">Envoyé</option>
            <option value="accepte">Accepté</option>
            <option value="rejete">Rejeté</option>
          </select>
        </div>

        <!-- Articles du devis -->
        <div class="articles-section">
          <h3>Articles</h3>

          <!-- Articles par catégorie -->
          <div v-for="category in categories" :key="category.key" class="category-section">
            <div v-if="getArticlesByCategory(category.key).length > 0" class="category-header">
              <h4>{{ category.name }}</h4>
              <div class="category-line"></div>
            </div>

            <div v-for="(article, index) in getArticlesByCategory(category.key)" :key="article.id || index" class="article-item">
              <div class="form-row">
                <div class="form-group">
                  <label>Pièce à changer:</label>
                  <input v-model="article.piece" type="text" required>
                </div>
                <div class="form-group">
                  <label>Fournisseur:</label>
                  <select v-model="article.fournisseurId">
                    <option value="">Sélectionner</option>
                    <option v-for="supplier in suppliers" :key="supplier.id" :value="supplier.id">
                      {{ supplier.nom }}
                    </option>
                  </select>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group">
                  <label>Prix achat (Dhs):</label>
                  <input v-model.number="article.prixAchat" type="number" step="0.01" @input="calculateArticleTotal(article)" required>
                </div>
                <div class="form-group">
                  <label>Prix vente (Dhs):</label>
                  <input v-model.number="article.prixVente" type="number" step="0.01" @input="calculateArticleTotal(article)" required>
                  <div v-if="article.prixVente < article.prixAchat" class="price-warning">
                    ⚠️ Prix de vente inférieur au prix d'achat !
                  </div>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group">
                  <label>Catégorie:</label>
                  <select v-model="article.categorie" @change="calculateArticleTotal(article)" required>
                    <option value="original">Original (TVA 20%)</option>
                    <option value="adaptable">Adaptable (TVA 20%)</option>
                    <option value="occasion">Occasion (TVA 0%)</option>
                  </select>
                </div>
                <div class="form-group">
                  <label>TVA (Dhs):</label>
                  <input v-model.number="article.tva" type="number" step="0.01" readonly>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group">
                  <label>Total HT (Dhs):</label>
                  <input v-model.number="article.totalHT" type="number" step="0.01" readonly>
                </div>
                <div class="form-group">
                  <label>Total TTC (Dhs):</label>
                  <input v-model.number="article.totalTTC" type="number" step="0.01" readonly>
                </div>
              </div>

              <button type="button" @click="removeArticleById(article.id || findArticleIndex(article))" class="btn btn-sm btn-danger">Supprimer article</button>
            </div>
          </div>

          <!-- Articles sans catégorie définie -->
          <div v-if="getUncategorizedArticles().length > 0" class="category-section">
            <div class="category-header">
              <h4>Articles en cours de définition</h4>
              <div class="category-line"></div>
            </div>

            <div v-for="(article, index) in getUncategorizedArticles()" :key="article.id || index" class="article-item">
              <div class="form-row">
                <div class="form-group">
                  <label>Pièce à changer:</label>
                  <input v-model="article.piece" type="text" required>
                </div>
                <div class="form-group">
                  <label>Fournisseur:</label>
                  <select v-model="article.fournisseurId">
                    <option value="">Sélectionner</option>
                    <option v-for="supplier in suppliers" :key="supplier.id" :value="supplier.id">
                      {{ supplier.nom }}
                    </option>
                  </select>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group">
                  <label>Prix achat (Dhs):</label>
                  <input v-model.number="article.prixAchat" type="number" step="0.01" @input="calculateArticleTotal(article)" required>
                </div>
                <div class="form-group">
                  <label>Prix vente (Dhs):</label>
                  <input v-model.number="article.prixVente" type="number" step="0.01" @input="calculateArticleTotal(article)" required>
                  <div v-if="article.prixVente < article.prixAchat" class="price-warning">
                    ⚠️ Prix de vente inférieur au prix d'achat !
                  </div>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group">
                  <label>Catégorie:</label>
                  <select v-model="article.categorie" @change="calculateArticleTotal(article)" required>
                    <option value="">Sélectionner une catégorie</option>
                    <option value="original">Original (TVA 20%)</option>
                    <option value="adaptable">Adaptable (TVA 20%)</option>
                    <option value="occasion">Occasion (TVA 0%)</option>
                  </select>
                </div>
                <div class="form-group">
                  <label>TVA (Dhs):</label>
                  <input v-model.number="article.tva" type="number" step="0.01" readonly>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group">
                  <label>Total HT (Dhs):</label>
                  <input v-model.number="article.totalHT" type="number" step="0.01" readonly>
                </div>
                <div class="form-group">
                  <label>Total TTC (Dhs):</label>
                  <input v-model.number="article.totalTTC" type="number" step="0.01" readonly>
                </div>
              </div>

              <button type="button" @click="removeArticleById(article.id || findArticleIndex(article))" class="btn btn-sm btn-danger">Supprimer article</button>
            </div>
          </div>

          <button type="button" @click="addArticle" class="btn btn-secondary">Ajouter article</button>
        </div>

        <!-- Totaux -->
        <div class="totals-section">
          <div class="total-item">
            <strong>Total HT: {{ totalHT.toFixed(2) }} Dhs</strong>
          </div>
          <div class="total-item">
            <strong>Total TVA: {{ totalTVA.toFixed(2) }} Dhs</strong>
          </div>
          <div class="total-item">
            <strong>Total TTC: {{ totalTTC.toFixed(2) }} Dhs</strong>
          </div>
        </div>

        <div class="form-actions">
          <button type="submit" class="btn btn-success">
            {{ editingQuote ? 'Modifier' : 'Créer' }}
          </button>
          <button type="button" @click="cancelForm" class="btn btn-secondary">Annuler</button>
        </div>
      </form>
    </div>

    <!-- Liste des devis -->
    <div class="quotes-list">
      <h2>Liste des Devis</h2>
      <div class="table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>Numéro</th>
              <th>Date</th>
              <th>Client</th>
              <th>Véhicule</th>
              <th>Statut</th>
              <th>Total TTC</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="quote in quotes" :key="quote.id">
              <td>{{ quote.numero }}</td>
              <td>{{ formatDate(quote.date) }}</td>
              <td>{{ getClientName(quote.clientId) }}</td>
              <td>{{ quote.matriculeVehicule }}</td>
              <td>
                <span :class="getStatusClass(quote.statut)">
                  {{ getStatusText(quote.statut) }}
                </span>
              </td>
              <td>{{ quote.totalTTC?.toFixed(2) || '0.00' }} Dhs</td>
              <td class="actions">
                <button @click="editQuote(quote)" class="btn btn-sm btn-warning">Modifier</button>
                <button v-if="quote.statut === 'accepte' && !quote.bonCommandeId" 
                        @click="validateQuote(quote)" 
                        class="btn btn-sm btn-success">Valider en BC</button>
                <button @click="deleteQuote(quote.id)" class="btn btn-sm btn-danger">Supprimer</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted } from 'vue'
import dataService from '@/services/dataService.js'

export default {
  name: 'Quotes',
  setup() {
    const showAddForm = ref(false)
    const editingQuote = ref(null)
    const quotes = ref([])
    const clients = ref([])
    const vehicles = ref([])
    const suppliers = ref([])

    // Charger les données au montage du composant
    onMounted(() => {
      loadData()
    })

    const form = reactive({
      numero: '',
      date: '',
      clientId: '',
      matriculeVehicule: '',
      statut: 'en_cours',
      articles: []
    })

    const totalHT = computed(() => {
      return form.articles.reduce((sum, article) => sum + (article.totalHT || 0), 0)
    })

    const totalTVA = computed(() => {
      return form.articles.reduce((sum, article) => sum + (article.tva || 0), 0)
    })

    const totalTTC = computed(() => {
      return form.articles.reduce((sum, article) => sum + (article.totalTTC || 0), 0)
    })

    const categories = ref([
      { key: 'original', name: 'Pièces Originales (TVA 20%)' },
      { key: 'adaptable', name: 'Pièces Adaptables (TVA 20%)' },
      { key: 'occasion', name: 'Pièces d\'Occasion (TVA 0%)' }
    ])

    const addArticle = () => {
      form.articles.push({
        id: Date.now() + Math.random(),
        piece: '',
        fournisseurId: '',
        prixAchat: 0,
        prixVente: 0,
        categorie: '',
        tva: 0,
        totalHT: 0,
        totalTTC: 0
      })
    }

    const removeArticle = (index) => {
      form.articles.splice(index, 1)
    }

    const removeArticleById = (id) => {
      if (typeof id === 'number' && id < form.articles.length) {
        // Si c'est un index
        removeArticle(id)
      } else {
        // Si c'est un ID
        const index = form.articles.findIndex(article => article.id === id)
        if (index !== -1) {
          removeArticle(index)
        }
      }
    }

    const findArticleIndex = (targetArticle) => {
      return form.articles.findIndex(article => article === targetArticle)
    }

    const getArticlesByCategory = (category) => {
      return form.articles.filter(article => article.categorie === category)
    }

    const getUncategorizedArticles = () => {
      return form.articles.filter(article => !article.categorie || article.categorie === '')
    }

    const calculateArticleTotal = (article) => {
      article.totalHT = article.prixVente || 0

      if (article.categorie === 'occasion') {
        article.tva = 0
      } else {
        article.tva = article.totalHT * 0.2
      }

      article.totalTTC = article.totalHT + article.tva
    }

    // Fonction pour charger toutes les données
    const loadData = () => {
      quotes.value = dataService.getAllQuotes()
      clients.value = dataService.getAllClients()
      vehicles.value = dataService.getAllVehicles()
      suppliers.value = dataService.getAllSuppliers()
      
      // Créer des données d'exemple si elles n'existent pas
      if (clients.value.length === 0) {
        dataService.createClient({ nom: 'Dupont Jean', email: 'dupont@email.com', telephone: '0123456789' })
        dataService.createClient({ nom: 'Martin Paul', email: 'martin@email.com', telephone: '0123456790' })
        clients.value = dataService.getAllClients()
      }
      
      if (vehicles.value.length === 0) {
        dataService.createVehicle({ matricule: 'ABC-123', marque: 'Renault', modele: 'Clio', annee: 2020 })
        dataService.createVehicle({ matricule: 'XYZ-789', marque: 'Peugeot', modele: '208', annee: 2019 })
        vehicles.value = dataService.getAllVehicles()
      }
      
      if (suppliers.value.length === 0) {
        dataService.createSupplier({ nom: 'Fournisseur Auto', adresse: '123 Rue Auto', telephone: '0123456791' })
        dataService.createSupplier({ nom: 'Pièces Express', adresse: '456 Rue Express', telephone: '0123456792' })
        suppliers.value = dataService.getAllSuppliers()
      }
    }

    const saveQuote = () => {
      const quoteData = {
        numero: form.numero,
        date: form.date,
        clientId: form.clientId,
        matriculeVehicule: form.matriculeVehicule,
        statut: form.statut,
        items: form.articles,
        totalHT: totalHT.value,
        totalTVA: totalTVA.value,
        totalTTC: totalTTC.value
      }

      if (editingQuote.value) {
        dataService.updateQuote(editingQuote.value.id, quoteData)
      } else {
        dataService.createQuote(quoteData)
      }
      
      // Recharger les données après sauvegarde
      quotes.value = dataService.getAllQuotes()
      cancelForm()
      alert('Devis sauvegardé avec succès!')
    }

    const editQuote = (quote) => {
      editingQuote.value = quote
      // Copier les données du devis dans le formulaire
      Object.assign(form, {
        numero: quote.numero,
        date: quote.date,
        clientId: quote.clientId,
        matriculeVehicule: quote.matriculeVehicule,
        statut: quote.statut,
        articles: [...(quote.items || quote.articles || [])]
      })
      showAddForm.value = true
    }

    const deleteQuote = (id) => {
      if (confirm('Êtes-vous sûr de vouloir supprimer ce devis ?')) {
        dataService.deleteQuote(id)
        quotes.value = dataService.getAllQuotes()
        alert('Devis supprimé avec succès!')
      }
    }

    const validateQuote = (quote) => {
      if (confirm('Transformer ce devis en bon de commande ?')) {
        const order = dataService.convertQuoteToOrder(quote.id)
        if (order) {
          // Mettre à jour le statut du devis
          dataService.updateQuote(quote.id, { bonCommandeId: order.id })
          quotes.value = dataService.getAllQuotes()
          alert('Devis transformé en bon de commande avec succès !')
        } else {
          alert('Erreur: Le devis doit être accepté pour être transformé en bon de commande.')
        }
      }
    }

    const cancelForm = () => {
      showAddForm.value = false
      editingQuote.value = null
      Object.assign(form, {
        numero: 'DEV-' + Date.now(),
        date: new Date().toISOString().split('T')[0],
        clientId: '',
        matriculeVehicule: '',
        statut: 'en_cours',
        articles: []
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

    const getClientName = (clientId) => {
      const client = clients.value.find(c => c.id === clientId)
      return client ? client.nom : 'Client inconnu'
    }

    const getVehicleInfo = (vehicleId) => {
      const vehicle = vehicles.value.find(v => v.id === vehicleId)
      return vehicle ? `${vehicle.matricule} - ${vehicle.marque} ${vehicle.modele}` : 'Véhicule inconnu'
    }

    return {
      showAddForm,
      editingQuote,
      quotes,
      clients,
      vehicles,
      suppliers,
      form,
      categories,
      totalHT,
      totalTVA,
      totalTTC,
      loadData,
      addArticle,
      removeArticle,
      removeArticleById,
      findArticleIndex,
      getArticlesByCategory,
      getUncategorizedArticles,
      calculateArticleTotal,
      saveQuote,
      editQuote,
      deleteQuote,
      validateQuote,
      cancelForm,
      formatDate,
      getStatusText,
      getStatusClass,
      getClientName,
      getVehicleInfo
    }
  }
}
</script>

<style scoped>
.quotes-page {
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

.quote-form {
  display: grid;
  gap: 20px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
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

.articles-section {
  border: 1px solid #e0e0e0;
  padding: 15px;
  border-radius: 4px;
}

.category-section {
  margin-bottom: 30px;
}

.category-header {
  margin-bottom: 20px;
}

.category-header h4 {
  color: #2c3e50;
  margin-bottom: 8px;
  font-size: 16px;
  font-weight: bold;
}

.category-line {
  height: 2px;
  background: linear-gradient(to right, #3498db, #e74c3c, #2ecc71);
  border-radius: 1px;
  margin-bottom: 15px;
}

.article-item {
  border: 1px solid #f0f0f0;
  padding: 15px;
  margin-bottom: 15px;
  border-radius: 4px;
  background: #fafafa;
  border-left: 4px solid #3498db;
}

.price-warning {
  color: #dc3545;
  font-size: 12px;
  margin-top: 5px;
}

.totals-section {
  border-top: 2px solid #007bff;
  padding-top: 15px;
  text-align: right;
}

.total-item {
  margin-bottom: 5px;
  font-size: 16px;
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

.quotes-list {
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