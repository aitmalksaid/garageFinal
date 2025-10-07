
<template>
  <div class="page-container">
    <h1>Analyse des Bénéfices par Affaire</h1>
    
    <div class="filters">
      <div class="filter-group">
        <label>Période:</label>
        <select v-model="selectedPeriod" @change="filterData">
          <option value="all">Toutes les affaires</option>
          <option value="month">Ce mois</option>
          <option value="quarter">Ce trimestre</option>
          <option value="year">Cette année</option>
        </select>
      </div>
    </div>

    <div class="summary-cards">
      <div class="summary-card total">
        <h3>Chiffre d'affaires total</h3>
        <div class="amount">{{ totalCA.toFixed(2) }} Dhs</div>
      </div>
      <div class="summary-card expenses">
        <h3>Dépenses totales</h3>
        <div class="amount">{{ totalDepenses.toFixed(2) }} Dhs</div>
      </div>
      <div class="summary-card profit">
        <h3>Bénéfice total</h3>
        <div class="amount">{{ totalBenefice.toFixed(2) }} Dhs</div>
      </div>
      <div class="summary-card margin">
        <h3>Marge moyenne</h3>
        <div class="amount">{{ margeAverage.toFixed(1) }}%</div>
      </div>
    </div>

    <div class="table-container">
      <table class="data-table">
        <thead>
          <tr>
            <th>ID Affaire</th>
            <th>Client</th>
            <th>Date</th>
            <th>Total Dépenses</th>
            <th>Total Devis</th>
            <th>Bénéfice</th>
            <th>Marge (%)</th>
            <th>Statut</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="benefice in filteredBenefices" :key="benefice.idAffaire" 
              :class="{ 'negative': benefice.benefice < 0 }">
            <td>{{ benefice.idAffaire }}</td>
            <td>{{ benefice.clientNom }}</td>
            <td>{{ formatDate(benefice.date) }}</td>
            <td class="amount">{{ benefice.totalDepenses.toFixed(2) }} Dhs</td>
            <td class="amount">{{ benefice.totalDevis.toFixed(2) }} Dhs</td>
            <td class="amount" :class="{ 'profit': benefice.benefice > 0, 'loss': benefice.benefice < 0 }">
              {{ benefice.benefice.toFixed(2) }} Dhs
            </td>
            <td class="amount" :class="{ 'good-margin': benefice.marge > 20, 'poor-margin': benefice.marge < 10 }">
              {{ benefice.marge.toFixed(1) }}%
            </td>
            <td>
              <span :class="['status', benefice.statut]">{{ benefice.statut }}</span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="chart-section">
      <h2>Évolution des bénéfices</h2>
      <div class="chart-placeholder">
        <div class="bars-container">
          <div v-for="(benefice, index) in filteredBenefices.slice(0, 10)" 
               :key="benefice.idAffaire" 
               class="bar-item">
            <div class="bar" 
                 :style="{ 
                   height: Math.max(5, Math.abs(benefice.benefice) / maxBenefice * 100) + 'px',
                   backgroundColor: benefice.benefice > 0 ? '#27ae60' : '#e74c3c'
                 }">
            </div>
            <span class="bar-label">{{ benefice.idAffaire }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useDataService } from '../composables/useDataService'

const { benefices, affaires, dataService, loadAllData } = useDataService()
const profitsByAffaire = ref([])

const selectedPeriod = ref('all')

const calculateProfits = async () => {
  profitsByAffaire.value = await dataService.calculateProfitsByAffaire()
}

onMounted(async () => {
  await loadAllData()
  await calculateProfits()
})

// Calculs enrichis
const enrichedBenefices = computed(() => {
  return profitsByAffaire.value.map(p => {
    const affaire = affaires.value.find(a => a.id === p.affaireId)
    return {
      ...p,
      clientNom: affaire ? getClientName(affaire.client_id) : 'Inconnu',
      date: affaire ? affaire.date_ouverture : '',
      statut: affaire ? affaire.statut : 'Inconnu',
      marge: p.totalDevis > 0 ? (p.profit / p.totalDevis) * 100 : 0
    }
  })
})

const filteredBenefices = computed(() => {
  // Ici vous pourriez filtrer par période
  return enrichedBenefices.value
})

const totalCA = computed(() => {
  return filteredBenefices.value.reduce((sum, b) => sum + b.totalDevis, 0)
})

const totalDepenses = computed(() => {
  return filteredBenefices.value.reduce((sum, b) => sum + b.totalBonsCommande, 0)
})

const totalBenefice = computed(() => {
  return filteredBenefices.value.reduce((sum, b) => sum + b.profit, 0)
})

const margeAverage = computed(() => {
  if (filteredBenefices.value.length === 0) return 0
  const totalMarge = filteredBenefices.value.reduce((sum, b) => sum + b.marge, 0)
  return totalMarge / filteredBenefices.value.length
})

const maxBenefice = computed(() => {
  if (filteredBenefices.value.length === 0) return 0
  return Math.max(...filteredBenefices.value.map(b => Math.abs(b.profit)))
})

const getClientName = (clientId) => {
  const client = dataService.clients.value.find(c => c.id === clientId)
  return client ? `${client.nom} ${client.prenom}` : 'Inconnu'
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  return new Date(dateString).toLocaleDateString('fr-FR')
}

const filterData = () => {
  // Implémentation du filtrage par période
  console.log('Filtrage par période:', selectedPeriod.value)
}
</script>

<style scoped>
.page-container {
  padding: 20px;
  max-width: 1400px;
  margin: 0 auto;
}

.filters {
  display: flex;
  gap: 20px;
  margin-bottom: 30px;
}

.filter-group {
  display: flex;
  align-items: center;
  gap: 10px;
}

.filter-group label {
  font-weight: bold;
  color: #2c3e50;
}

.filter-group select {
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  background: white;
}

.summary-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 40px;
}

.summary-card {
  background: white;
  padding: 25px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  text-align: center;
}

.summary-card h3 {
  margin: 0 0 15px 0;
  color: #7f8c8d;
  font-size: 14px;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.summary-card .amount {
  font-size: 28px;
  font-weight: bold;
  margin: 0;
}

.summary-card.total .amount { color: #3498db; }
.summary-card.expenses .amount { color: #e74c3c; }
.summary-card.profit .amount { color: #27ae60; }
.summary-card.margin .amount { color: #f39c12; }

.table-container {
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  margin-bottom: 40px;
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

.data-table tbody tr.negative {
  background: #fdf2f2;
}

.amount {
  text-align: right;
  font-weight: 500;
}

.profit {
  color: #27ae60;
}

.loss {
  color: #e74c3c;
}

.good-margin {
  color: #27ae60;
  font-weight: bold;
}

.poor-margin {
  color: #e74c3c;
  font-weight: bold;
}

.status {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: bold;
  text-transform: uppercase;
}

.status.terminé {
  background: #27ae60;
  color: white;
}

.status.en-cours {
  background: #f39c12;
  color: white;
}

.chart-section {
  background: white;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.chart-section h2 {
  color: #2c3e50;
  margin-bottom: 20px;
}

.chart-placeholder {
  height: 200px;
  display: flex;
  align-items: end;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 4px;
}

.bars-container {
  display: flex;
  align-items: end;
  gap: 15px;
  width: 100%;
  height: 100%;
}

.bar-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  flex: 1;
}

.bar {
  width: 30px;
  min-height: 5px;
  border-radius: 2px 2px 0 0;
  margin-bottom: 5px;
}

.bar-label {
  font-size: 11px;
  color: #7f8c8d;
  transform: rotate(-45deg);
}
</style>
