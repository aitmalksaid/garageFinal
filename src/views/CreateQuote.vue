
<template>
  <div class="create-quote">
    <h1>Création de Devis</h1>
    
    <form @submit.prevent="saveQuote" class="quote-form">
      <div class="form-section">
        <h3>Informations générales</h3>
        <div class="form-row">
          <div class="form-group">
            <label>Numéro de devis</label>
            <input v-model="quote.numero" type="text" readonly class="form-input">
          </div>
          <div class="form-group">
            <label>Date</label>
            <input v-model="quote.date" type="date" class="form-input" required>
          </div>
        </div>
        
        <div class="form-row">
          <div class="form-group">
            <label>Client</label>
            <select v-model="quote.clientId" class="form-input" required>
              <option value="">Sélectionner un client</option>
              <option v-for="client in clients" :key="client.id" :value="client.id">
                {{ client.nom }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label>Matricule véhicule</label>
            <select v-model="quote.vehicleId" class="form-input" required>
              <option value="">Sélectionner un véhicule</option>
              <option v-for="vehicle in vehicles" :key="vehicle.id" :value="vehicle.id">
                {{ vehicle.matricule }} - {{ vehicle.marque }} {{ vehicle.modele }}
              </option>
            </select>
          </div>
        </div>
      </div>

      <div class="form-section">
        <h3>Articles</h3>
        
        <!-- Articles par catégorie -->
        <div v-for="category in categories" :key="category.key" class="category-section">
          <div v-if="getItemsByCategory(category.key).length > 0" class="category-header">
            <h4>{{ category.name }}</h4>
            <div class="category-line"></div>
          </div>
          
          <div v-for="(item, index) in getItemsByCategory(category.key)" :key="item.id || index" class="item-row">
            <div class="form-group">
              <label>Pièce à changer</label>
              <input v-model="item.piece" type="text" class="form-input" required>
            </div>
            <div class="form-group">
              <label>Fournisseur</label>
              <select v-model="item.fournisseurId" class="form-input" required>
                <option value="">Sélectionner</option>
                <option v-for="supplier in suppliers" :key="supplier.id" :value="supplier.id">
                  {{ supplier.nom }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label>Prix achat (Dhs)</label>
              <input v-model.number="item.prixAchat" type="number" step="0.01" class="form-input" required @input="validatePrice(item)">
            </div>
            <div class="form-group">
              <label>Prix vente (Dhs)</label>
              <input v-model.number="item.prixVente" type="number" step="0.01" class="form-input" required @input="validatePrice(item)">
              <div v-if="item.priceWarning" class="price-warning">
                ⚠️ Prix de vente inférieur au prix d'achat
              </div>
            </div>
            <div class="form-group">
              <label>Catégorie</label>
              <select v-model="item.categorie" class="form-input" required @change="updateTVA(item)">
                <option value="original">Original (TVA 20%)</option>
                <option value="adaptable">Adaptable (TVA 20%)</option>
                <option value="occasion">Occasion (TVA 0%)</option>
              </select>
            </div>
            <div class="form-group">
              <label>TVA (%)</label>
              <input v-model.number="item.tva" type="number" class="form-input" readonly>
            </div>
            <button type="button" @click="removeItemById(item.id || findItemIndex(item))" class="btn btn-danger">Supprimer</button>
          </div>
        </div>
        
        <!-- Articles sans catégorie définie -->
        <div v-if="getUncategorizedItems().length > 0" class="category-section">
          <div class="category-header">
            <h4>Articles en cours de définition</h4>
            <div class="category-line"></div>
          </div>
          
          <div v-for="(item, index) in getUncategorizedItems()" :key="item.id || index" class="item-row">
            <div class="form-group">
              <label>Pièce à changer</label>
              <input v-model="item.piece" type="text" class="form-input" required>
            </div>
            <div class="form-group">
              <label>Fournisseur</label>
              <select v-model="item.fournisseurId" class="form-input" required>
                <option value="">Sélectionner</option>
                <option v-for="supplier in suppliers" :key="supplier.id" :value="supplier.id">
                  {{ supplier.nom }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label>Prix achat (Dhs)</label>
              <input v-model.number="item.prixAchat" type="number" step="0.01" class="form-input" required @input="validatePrice(item)">
            </div>
            <div class="form-group">
              <label>Prix vente (Dhs)</label>
              <input v-model.number="item.prixVente" type="number" step="0.01" class="form-input" required @input="validatePrice(item)">
              <div v-if="item.priceWarning" class="price-warning">
                ⚠️ Prix de vente inférieur au prix d'achat
              </div>
            </div>
            <div class="form-group">
              <label>Catégorie</label>
              <select v-model="item.categorie" class="form-input" required @change="updateTVA(item)">
                <option value="">Sélectionner une catégorie</option>
                <option value="original">Original (TVA 20%)</option>
                <option value="adaptable">Adaptable (TVA 20%)</option>
                <option value="occasion">Occasion (TVA 0%)</option>
              </select>
            </div>
            <div class="form-group">
              <label>TVA (%)</label>
              <input v-model.number="item.tva" type="number" class="form-input" readonly>
            </div>
            <button type="button" @click="removeItemById(item.id || findItemIndex(item))" class="btn btn-danger">Supprimer</button>
          </div>
        </div>
        
        <button type="button" @click="addItem" class="btn btn-secondary">Ajouter un article</button>
      </div>

      <div class="form-section">
        <h3>Totaux</h3>
        <div class="totals">
          <div class="total-row">
            <span>Total HT:</span>
            <span>{{ totalHT.toFixed(2) }} Dhs</span>
          </div>
          <div class="total-row">
            <span>Total TVA:</span>
            <span>{{ totalTVA.toFixed(2) }} Dhs</span>
          </div>
          <div class="total-row total-ttc">
            <span>Total TTC:</span>
            <span>{{ totalTTC.toFixed(2) }} Dhs</span>
          </div>
        </div>
      </div>

      <div class="form-actions">
        <button type="submit" class="btn btn-primary">Enregistrer le devis</button>
        <button type="button" @click="resetForm" class="btn btn-secondary">Annuler</button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useDataService } from '@/composables/useDataService.js'

const quote = ref({
  numero: '',
  date: new Date().toISOString().split('T')[0],
  clientId: '',
  vehicleId: '',
  items: [
    {
      piece: '',
      fournisseurId: '',
      prixAchat: 0,
      prixVente: 0,
      categorie: 'original',
      tva: 20,
      priceWarning: false
    }
  ]
})

// Utiliser le composable pour la gestion des données
const { clients, vehicles, suppliers, dataService, createSampleData } = useDataService()

onMounted(() => {
  // Générer un numéro de devis automatique
  quote.value.numero = 'DEV-' + Date.now()
  
  // Créer des données d'exemple si nécessaire
  createSampleData()
})

const totalHT = computed(() => {
  return quote.value.items.reduce((sum, item) => sum + (item.prixVente || 0), 0)
})

const totalTVA = computed(() => {
  return quote.value.items.reduce((sum, item) => {
    const tvaAmount = (item.prixVente || 0) * (item.tva || 0) / 100
    return sum + tvaAmount
  }, 0)
})

const totalTTC = computed(() => {
  return totalHT.value + totalTVA.value
})

const categories = ref([
  { key: 'original', name: 'Pièces Originales (TVA 20%)' },
  { key: 'adaptable', name: 'Pièces Adaptables (TVA 20%)' },
  { key: 'occasion', name: 'Pièces d\'Occasion (TVA 0%)' }
])

const addItem = () => {
  const newItem = {
    id: Date.now() + Math.random(),
    piece: '',
    fournisseurId: '',
    prixAchat: 0,
    prixVente: 0,
    categorie: '',
    tva: 0,
    priceWarning: false
  }
  quote.value.items.push(newItem)
}

const removeItem = (index) => {
  if (quote.value.items.length > 1) {
    quote.value.items.splice(index, 1)
  }
}

const removeItemById = (id) => {
  if (typeof id === 'number' && id < quote.value.items.length) {
    // Si c'est un index
    removeItem(id)
  } else {
    // Si c'est un ID
    const index = quote.value.items.findIndex(item => item.id === id)
    if (index !== -1) {
      removeItem(index)
    }
  }
}

const findItemIndex = (targetItem) => {
  return quote.value.items.findIndex(item => item === targetItem)
}

const getItemsByCategory = (category) => {
  return quote.value.items.filter(item => item.categorie === category)
}

const getUncategorizedItems = () => {
  return quote.value.items.filter(item => !item.categorie || item.categorie === '')
}

const updateTVA = (item) => {
  if (item.categorie === 'occasion') {
    item.tva = 0
  } else {
    item.tva = 20
  }
}

const validatePrice = (item) => {
  item.priceWarning = item.prixVente < item.prixAchat && item.prixVente > 0 && item.prixAchat > 0
}

const saveQuote = () => {
  try {
    // Validation des données
    if (!quote.value.clientId) {
      alert('Veuillez sélectionner un client')
      return
    }
    
    if (!quote.value.vehicleId) {
      alert('Veuillez sélectionner un véhicule')
      return
    }
    
    if (quote.value.items.length === 0 || !quote.value.items.some(item => item.piece)) {
      alert('Veuillez ajouter au moins un article')
      return
    }

    const quoteData = {
      numero: quote.value.numero,
      date: quote.value.date,
      clientId: quote.value.clientId,
      vehicleId: quote.value.vehicleId,
      items: quote.value.items.filter(item => item.piece), // Filtrer les articles vides
      totalHT: totalHT.value,
      totalTVA: totalTVA.value,
      totalTTC: totalTTC.value,
      status: 'en_cours'
    }
    
    const savedQuote = dataService.createQuote(quoteData)
    console.log('Devis sauvegardé:', savedQuote)
    alert(`Devis ${savedQuote.numero} créé avec succès! Total: ${savedQuote.totalTTC.toFixed(2)}Dhs`)
    resetForm()
  } catch (error) {
    console.error('Erreur lors de la sauvegarde:', error)
    alert('Erreur lors de la sauvegarde du devis')
  }
}

const resetForm = () => {
  quote.value = {
    numero: 'DEV-' + Date.now(),
    date: new Date().toISOString().split('T')[0],
    clientId: '',
    vehicleId: '',
    items: [
      {
        piece: '',
        fournisseurId: '',
        prixAchat: 0,
        prixVente: 0,
        categorie: 'original',
        tva: 20,
        priceWarning: false
      }
    ]
  }
}
</script>

<style scoped>
.create-quote {
  max-width: 1000px;
}

.quote-form {
  background: white;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.form-section {
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 1px solid #eee;
}

.form-section:last-child {
  border-bottom: none;
}

.form-section h3 {
  margin-bottom: 20px;
  color: #2c3e50;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 15px;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  margin-bottom: 5px;
  font-weight: bold;
  color: #555;
}

.form-input {
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.form-input:focus {
  outline: none;
  border-color: #3498db;
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

.item-row {
  display: grid;
  grid-template-columns: 2fr 1.5fr 1fr 1fr 1.5fr 0.8fr auto;
  gap: 15px;
  align-items: end;
  margin-bottom: 15px;
  padding: 15px;
  background-color: #f8f9fa;
  border-radius: 4px;
  border-left: 4px solid #3498db;
}

.price-warning {
  color: #e74c3c;
  font-size: 12px;
  margin-top: 5px;
}

.totals {
  background-color: #f8f9fa;
  padding: 20px;
  border-radius: 4px;
}

.total-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
  font-size: 16px;
}

.total-ttc {
  font-weight: bold;
  font-size: 18px;
  border-top: 2px solid #ddd;
  padding-top: 10px;
}

.form-actions {
  display: flex;
  gap: 15px;
  justify-content: flex-end;
  margin-top: 30px;
}

.btn {
  padding: 12px 24px;
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
  padding: 8px 12px;
  font-size: 12px;
}

.btn:hover {
  opacity: 0.8;
}
</style>
