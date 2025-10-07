
<template>
  <div class="comparison-page">
    <div class="page-header">
      <h1>Comparaison Devis / Dépenses par Affaire</h1>
      <div class="filters">
        <select v-model="selectedCase" @change="loadComparisonData">
          <option value="">Sélectionner une affaire</option>
          <option v-for="caseItem in cases" :key="caseItem.id" :value="caseItem.id">
            Affaire #{{ caseItem.id }} - {{ caseItem.client }}
          </option>
        </select>
      </div>
    </div>

    <div v-if="selectedCase && comparisonData" class="comparison-content">
      <!-- Informations de l'affaire -->
      <div class="case-info">
        <h2>Affaire #{{ selectedCase }}</h2>
        <div class="info-grid">
          <div class="info-item">
            <label>Client:</label>
            <span>{{ comparisonData.caseInfo.client }}</span>
          </div>
          <div class="info-item">
            <label>Véhicule:</label>
            <span>{{ comparisonData.caseInfo.vehicule }}</span>
          </div>
          <div class="info-item">
            <label>Date d'entrée:</label>
            <span>{{ formatDate(comparisonData.caseInfo.dateEntree) }}</span>
          </div>
          <div class="info-item">
            <label>Statut:</label>
            <span :class="getStatusClass(comparisonData.caseInfo.statut)">
              {{ getStatusText(comparisonData.caseInfo.statut) }}
            </span>
          </div>
        </div>
      </div>

      <!-- Comparaison détaillée -->
      <div class="comparison-section">
        <h3>Comparaison Détaillée</h3>
        <div class="table-container">
          <table class="comparison-table">
            <thead>
              <tr>
                <th>Article/Pièce</th>
                <th>Devis Prévu (Dhs)</th>
                <th>Dépense Réelle (Dhs)</th>
                <th>Écart (Dhs)</th>
                <th>Écart (%)</th>
                <th>Statut</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in comparisonData.items" :key="item.id">
                <td>{{ item.piece }}</td>
                <td class="amount">{{ item.devisAmount.toFixed(2) }}</td>
                <td class="amount">{{ item.realAmount.toFixed(2) }}</td>
                <td :class="getVarianceClass(item.variance)">
                  {{ item.variance > 0 ? '+' : '' }}{{ item.variance.toFixed(2) }}
                </td>
                <td :class="getVarianceClass(item.variancePercent)">
                  {{ item.variancePercent > 0 ? '+' : '' }}{{ item.variancePercent.toFixed(1) }}%
                </td>
                <td>
                  <span :class="getRepairStatusClass(item.repairStatus)">
                    {{ getRepairStatusText(item.repairStatus) }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Résumé financier -->
      <div class="financial-summary">
        <h3>Résumé Financier</h3>
        <div class="summary-grid">
          <div class="summary-card">
            <h4>Total Devis</h4>
            <div class="amount-large">{{ comparisonData.summary.totalDevis.toFixed(2) }} Dhs</div>
          </div>
          <div class="summary-card">
            <h4>Total Dépenses</h4>
            <div class="amount-large">{{ comparisonData.summary.totalDepenses.toFixed(2) }} Dhs</div>
          </div>
          <div class="summary-card">
            <h4>Écart Total</h4>
            <div :class="getVarianceClass(comparisonData.summary.ecartTotal)" class="amount-large">
              {{ comparisonData.summary.ecartTotal > 0 ? '+' : '' }}{{ comparisonData.summary.ecartTotal.toFixed(2) }} Dhs
            </div>
          </div>
          <div class="summary-card">
            <h4>Marge Réalisée</h4>
            <div :class="getVarianceClass(comparisonData.summary.margeRealisee)" class="amount-large">
              {{ comparisonData.summary.margeRealisee.toFixed(2) }} Dhs
            </div>
          </div>
        </div>
      </div>

      <!-- Table des dépenses détaillées -->
      <div class="expenses-section">
        <div class="section-header">
          <h3>Dépenses de Réparation Effectuées</h3>
          <button @click="showAddExpense = !showAddExpense" class="btn btn-primary">
            {{ showAddExpense ? 'Annuler' : 'Ajouter Dépense' }}
          </button>
        </div>

        <!-- Formulaire d'ajout de dépense -->
        <div v-if="showAddExpense" class="expense-form">
          <h4>Nouvelle Dépense</h4>
          <form @submit.prevent="addExpense" class="form-grid">
            <div class="form-group">
              <label>Type de dépense:</label>
              <select v-model="newExpense.type" required>
                <option value="piece">Pièce de rechange</option>
                <option value="main_oeuvre">Main d'œuvre</option>
                <option value="autre">Autre</option>
              </select>
            </div>
            <div class="form-group">
              <label>Description:</label>
              <input v-model="newExpense.description" type="text" required>
            </div>
            <div class="form-group">
              <label>Montant (Dhs):</label>
              <input v-model.number="newExpense.montant" type="number" step="0.01" required>
            </div>
            <div class="form-group">
              <label>Date:</label>
              <input v-model="newExpense.date" type="date" required>
            </div>
            <div class="form-group">
              <label>Fournisseur:</label>
              <input v-model="newExpense.fournisseur" type="text">
            </div>
            <div class="form-actions">
              <button type="submit" class="btn btn-success">Ajouter</button>
              <button type="button" @click="cancelExpense" class="btn btn-secondary">Annuler</button>
            </div>
          </form>
        </div>

        <!-- Liste des dépenses -->
        <div class="expenses-list">
          <table class="data-table">
            <thead>
              <tr>
                <th>Date</th>
                <th>Type</th>
                <th>Description</th>
                <th>Fournisseur</th>
                <th>Montant (Dhs)</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="expense in expenses" :key="expense.id">
                <td>{{ formatDate(expense.date) }}</td>
                <td>
                  <span :class="getExpenseTypeClass(expense.type)">
                    {{ getExpenseTypeText(expense.type) }}
                  </span>
                </td>
                <td>{{ expense.description }}</td>
                <td>{{ expense.fournisseur || '-' }}</td>
                <td class="amount">{{ expense.montant.toFixed(2) }}</td>
                <td class="actions">
                  <button @click="editExpense(expense)" class="btn btn-sm btn-warning">Modifier</button>
                  <button @click="deleteExpense(expense.id)" class="btn btn-sm btn-danger">Supprimer</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div v-else class="no-selection">
      <p>Sélectionnez une affaire pour voir la comparaison entre devis et dépenses.</p>
    </div>
  </div>
</template>

<script>
import { ref, reactive, watch } from 'vue'

export default {
  name: 'Comparison',
  setup() {
    const selectedCase = ref('')
    const comparisonData = ref(null)
    const showAddExpense = ref(false)
    const expenses = ref([])

    const cases = ref([
      { id: 1, client: 'Dupont Jean', vehicule: 'Peugeot 208', dateEntree: '2024-01-15', statut: 'en_cours' },
      { id: 2, client: 'Martin Paul', vehicule: 'Renault Clio', dateEntree: '2024-01-20', statut: 'accepte' }
    ])

    const newExpense = reactive({
      type: 'piece',
      description: '',
      montant: 0,
      date: new Date().toISOString().split('T')[0],
      fournisseur: ''
    })

    // Données d'exemple pour la comparaison
    const sampleData = {
      1: {
        caseInfo: {
          client: 'Dupont Jean',
          vehicule: 'Peugeot 208 - AB-123-CD',
          dateEntree: '2024-01-15',
          statut: 'en_cours'
        },
        items: [
          {
            id: 1,
            piece: 'Pare-choc avant',
            devisAmount: 240,
            realAmount: 220,
            variance: -20,
            variancePercent: -8.3,
            repairStatus: 'finalise'
          },
          {
            id: 2,
            piece: 'Phare avant droit',
            devisAmount: 180,
            realAmount: 200,
            variance: 20,
            variancePercent: 11.1,
            repairStatus: 'en_cours'
          }
        ],
        summary: {
          totalDevis: 420,
          totalDepenses: 420,
          ecartTotal: 0,
          margeRealisee: 150
        }
      }
    }

    const loadComparisonData = () => {
      if (selectedCase.value) {
        comparisonData.value = sampleData[selectedCase.value] || null
        loadExpenses()
      } else {
        comparisonData.value = null
      }
    }

    const loadExpenses = () => {
      // Charger les dépenses pour l'affaire sélectionnée
      expenses.value = [
        {
          id: 1,
          caseId: selectedCase.value,
          type: 'piece',
          description: 'Pare-choc avant Peugeot',
          montant: 180,
          date: '2024-01-20',
          fournisseur: 'Auto Pièces Pro'
        },
        {
          id: 2,
          caseId: selectedCase.value,
          type: 'main_oeuvre',
          description: 'Montage pare-choc',
          montant: 40,
          date: '2024-01-20',
          fournisseur: ''
        }
      ]
    }

    const addExpense = () => {
      const newId = Math.max(...expenses.value.map(e => e.id), 0) + 1
      expenses.value.push({
        id: newId,
        caseId: selectedCase.value,
        ...newExpense
      })
      cancelExpense()
    }

    const editExpense = (expense) => {
      Object.assign(newExpense, expense)
      showAddExpense.value = true
    }

    const deleteExpense = (id) => {
      if (confirm('Supprimer cette dépense ?')) {
        expenses.value = expenses.value.filter(e => e.id !== id)
      }
    }

    const cancelExpense = () => {
      showAddExpense.value = false
      Object.assign(newExpense, {
        type: 'piece',
        description: '',
        montant: 0,
        date: new Date().toISOString().split('T')[0],
        fournisseur: ''
      })
    }

    const formatDate = (dateStr) => {
      return new Date(dateStr).toLocaleDateString('fr-FR')
    }

    const getVarianceClass = (variance) => {
      if (variance > 0) return 'variance-positive'
      if (variance < 0) return 'variance-negative'
      return 'variance-neutral'
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

    const getRepairStatusClass = (status) => {
      const classMap = {
        'demande_envoyee': 'status-info',
        'en_cours_montage': 'status-warning',
        'finalise': 'status-success'
      }
      return `status-badge ${classMap[status] || ''}`
    }

    const getRepairStatusText = (status) => {
      const statusMap = {
        'demande_envoyee': 'Demande envoyée',
        'en_cours_montage': 'En cours montage',
        'finalise': 'Finalisé'
      }
      return statusMap[status] || status
    }

    const getExpenseTypeClass = (type) => {
      const classMap = {
        'piece': 'expense-piece',
        'main_oeuvre': 'expense-labor',
        'autre': 'expense-other'
      }
      return `expense-type ${classMap[type] || ''}`
    }

    const getExpenseTypeText = (type) => {
      const typeMap = {
        'piece': 'Pièce',
        'main_oeuvre': 'Main d\'œuvre',
        'autre': 'Autre'
      }
      return typeMap[type] || type
    }

    return {
      selectedCase,
      comparisonData,
      showAddExpense,
      expenses,
      cases,
      newExpense,
      loadComparisonData,
      addExpense,
      editExpense,
      deleteExpense,
      cancelExpense,
      formatDate,
      getVarianceClass,
      getStatusClass,
      getStatusText,
      getRepairStatusClass,
      getRepairStatusText,
      getExpenseTypeClass,
      getExpenseTypeText
    }
  }
}
</script>

<style scoped>
.comparison-page {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.filters select {
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.comparison-content {
  display: grid;
  gap: 30px;
}

.case-info {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
  margin-top: 15px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.info-item label {
  font-weight: bold;
  color: #666;
}

.comparison-section {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.table-container {
  overflow-x: auto;
}

.comparison-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 15px;
}

.comparison-table th,
.comparison-table td {
  padding: 12px;
  text-align: left;
  border-bottom: 1px solid #ddd;
}

.comparison-table th {
  background-color: #f8f9fa;
  font-weight: bold;
}

.amount {
  text-align: right;
  font-family: monospace;
}

.variance-positive {
  color: #dc3545;
  font-weight: bold;
}

.variance-negative {
  color: #28a745;
  font-weight: bold;
}

.variance-neutral {
  color: #6c757d;
}

.financial-summary {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-top: 15px;
}

.summary-card {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 6px;
  text-align: center;
}

.summary-card h4 {
  margin-bottom: 10px;
  color: #666;
}

.amount-large {
  font-size: 1.5rem;
  font-weight: bold;
  font-family: monospace;
}

.expenses-section {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.expense-form {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 6px;
  margin-bottom: 20px;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
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
  grid-column: span 2;
  display: flex;
  gap: 10px;
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

.expense-type {
  padding: 2px 6px;
  border-radius: 8px;
  font-size: 11px;
  font-weight: bold;
}

.expense-piece { background-color: #e3f2fd; color: #1565c0; }
.expense-labor { background-color: #f3e5f5; color: #7b1fa2; }
.expense-other { background-color: #e8f5e8; color: #2e7d32; }

.no-selection {
  text-align: center;
  padding: 60px 20px;
  color: #666;
  background: white;
  border-radius: 8px;
}
</style>
