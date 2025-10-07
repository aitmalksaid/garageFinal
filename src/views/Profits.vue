
<template>
  <div class="profits-page">
    <div class="page-header">
      <h1>Bénéfices par Affaire</h1>
      <div class="filters">
        <select v-model="selectedPeriod" @change="filterData" class="period-select">
          <option value="all">Toutes les périodes</option>
          <option value="month">Ce mois</option>
          <option value="quarter">Ce trimestre</option>
          <option value="year">Cette année</option>
        </select>
      </div>
    </div>

    <!-- Résumé des bénéfices -->
    <div class="summary-cards">
      <div class="summary-card">
        <h3>Total Dépenses</h3>
        <p class="amount expense">{{ totalExpenses.toFixed(2) }} Dhs</p>
      </div>
      <div class="summary-card">
        <h3>Total Revenus</h3>
        <p class="amount revenue">{{ totalRevenue.toFixed(2) }} Dhs</p>
      </div>
      <div class="summary-card">
        <h3>Bénéfice Total</h3>
        <p class="amount" :class="totalProfit >= 0 ? 'profit' : 'loss'">
          {{ totalProfit.toFixed(2) }} Dhs
        </p>
      </div>
      <div class="summary-card">
        <h3>Marge (%)</h3>
        <p class="amount" :class="profitMargin >= 0 ? 'profit' : 'loss'">
          {{ profitMargin.toFixed(1) }}%
        </p>
      </div>
    </div>

    <!-- Tableau détaillé des bénéfices -->
    <div class="profits-list">
      <h2>Détail par Affaire</h2>
      <div class="table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>ID Affaire</th>
              <th>Client</th>
              <th>Date</th>
              <th>Dépenses (Dhs)</th>
              <th>Revenus (Dhs)</th>
              <th>Bénéfice (Dhs)</th>
              <th>Marge (%)</th>
              <th>Statut</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="profit in filteredProfits" :key="profit.id">
              <td>{{ profit.idAffaire }}</td>
              <td>{{ profit.client }}</td>
              <td>{{ formatDate(profit.date) }}</td>
              <td class="amount expense">{{ profit.totalDepenses.toFixed(2) }}</td>
              <td class="amount revenue">{{ profit.totalDevis.toFixed(2) }}</td>
              <td class="amount" :class="profit.benefice >= 0 ? 'profit' : 'loss'">
                {{ profit.benefice.toFixed(2) }}
              </td>
              <td class="amount" :class="profit.marge >= 0 ? 'profit' : 'loss'">
                {{ profit.marge.toFixed(1) }}%
              </td>
              <td>
                <span :class="getStatusClass(profit.statut)">
                  {{ profit.statut }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Graphique des bénéfices (simulation) -->
    <div class="chart-section">
      <h2>Évolution des Bénéfices</h2>
      <div class="chart-placeholder">
        <p>Graphique des bénéfices par mois</p>
        <div class="chart-bars">
          <div v-for="(month, index) in chartData" :key="index" class="chart-bar">
            <div class="bar" :style="{ height: `${Math.max(month.profit / 1000 * 100, 10)}px` }"></div>
            <span class="bar-label">{{ month.name }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed } from 'vue'

export default {
  name: 'Profits',
  setup() {
    const selectedPeriod = ref('all')
    
    const profits = ref([
      {
        id: 1,
        idAffaire: 'AFF-001',
        client: 'Dupont Jean',
        date: '2024-01-15',
        totalDepenses: 800, // achats + main d'œuvre
        totalDevis: 1200,
        benefice: 400,
        marge: 33.3,
        statut: 'Terminé'
      },
      {
        id: 2,
        idAffaire: 'AFF-002',
        client: 'Martin Paul',
        date: '2024-01-20',
        totalDepenses: 1500,
        totalDevis: 2000,
        benefice: 500,
        marge: 25.0,
        statut: 'En cours'
      },
      {
        id: 3,
        idAffaire: 'AFF-003',
        client: 'Durand Marie',
        date: '2024-02-01',
        totalDepenses: 600,
        totalDevis: 900,
        benefice: 300,
        marge: 33.3,
        statut: 'Terminé'
      },
      {
        id: 4,
        idAffaire: 'AFF-004',
        client: 'Moreau Pierre',
        date: '2024-02-10',
        totalDepenses: 1200,
        totalDevis: 1100,
        benefice: -100,
        marge: -9.1,
        statut: 'Problème'
      }
    ])

    const chartData = ref([
      { name: 'Jan', profit: 900 },
      { name: 'Fév', profit: 200 },
      { name: 'Mar', profit: 1200 },
      { name: 'Avr', profit: 800 },
      { name: 'Mai', profit: 1500 },
      { name: 'Jun', profit: 1000 }
    ])

    const filteredProfits = computed(() => {
      if (selectedPeriod.value === 'all') {
        return profits.value
      }
      // Ici on pourrait implémenter la logique de filtrage par période
      return profits.value
    })

    const totalExpenses = computed(() => {
      return filteredProfits.value.reduce((sum, profit) => sum + profit.totalDepenses, 0)
    })

    const totalRevenue = computed(() => {
      return filteredProfits.value.reduce((sum, profit) => sum + profit.totalDevis, 0)
    })

    const totalProfit = computed(() => {
      return totalRevenue.value - totalExpenses.value
    })

    const profitMargin = computed(() => {
      if (totalRevenue.value === 0) return 0
      return (totalProfit.value / totalRevenue.value) * 100
    })

    const filterData = () => {
      // Logique de filtrage par période
      console.log('Filtrage par période:', selectedPeriod.value)
    }

    const formatDate = (dateStr) => {
      return new Date(dateStr).toLocaleDateString('fr-FR')
    }

    const getStatusClass = (status) => {
      const classMap = {
        'Terminé': 'status-success',
        'En cours': 'status-warning',
        'Problème': 'status-danger'
      }
      return `status-badge ${classMap[status] || ''}`
    }

    return {
      selectedPeriod,
      profits,
      filteredProfits,
      chartData,
      totalExpenses,
      totalRevenue,
      totalProfit,
      profitMargin,
      filterData,
      formatDate,
      getStatusClass
    }
  }
}
</script>

<style scoped>
.profits-page {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.period-select {
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  background: white;
}

.summary-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.summary-card {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  text-align: center;
}

.summary-card h3 {
  margin: 0 0 10px 0;
  color: #666;
  font-size: 14px;
  text-transform: uppercase;
}

.amount {
  font-size: 24px;
  font-weight: bold;
  margin: 0;
}

.amount.expense { color: #dc3545; }
.amount.revenue { color: #007bff; }
.amount.profit { color: #28a745; }
.amount.loss { color: #dc3545; }

.profits-list {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  margin-bottom: 30px;
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

.data-table .amount {
  text-align: right;
  font-weight: bold;
  font-size: 14px;
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

.chart-section {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.chart-placeholder {
  text-align: center;
  padding: 40px;
  background: #f8f9fa;
  border-radius: 4px;
  border: 2px dashed #dee2e6;
}

.chart-bars {
  display: flex;
  justify-content: center;
  align-items: flex-end;
  gap: 15px;
  margin-top: 20px;
  height: 120px;
}

.chart-bar {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
}

.bar {
  width: 30px;
  background: linear-gradient(to top, #007bff, #66b3ff);
  border-radius: 4px 4px 0 0;
  min-height: 10px;
}

.bar-label {
  font-size: 12px;
  color: #666;
}
</style>
