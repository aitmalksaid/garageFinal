
<template>
  <div class="home">
    <h1>Page d'accueil - Liste des Affaires</h1>
    
    <div class="filters">
      <select v-model="selectedCategory" class="filter-select">
        <option value="">Toutes les catégories</option>
        <option value="original">Original</option>
        <option value="adaptable">Adaptable</option>
        <option value="occasion">Occasion</option>
      </select>
      
      <select v-model="selectedStatus" class="filter-select">
        <option value="">Tous les statuts</option>
        <option value="en_cours">En cours</option>
        <option value="prepare">Préparé</option>
        <option value="envoye">Envoyé</option>
        <option value="accepte">Accepté</option>
        <option value="rejete">Rejeté</option>
      </select>
    </div>

    <div class="cases-grid">
      <div v-for="case_ in filteredCases" :key="case_.id" class="case-card">
        <div class="case-header">
          <h3>Affaire #{{ case_.id }}</h3>
          <span class="status-badge" :class="case_.status">{{ getStatusLabel(case_.status) }}</span>
        </div>
        <div class="case-details">
          <p><strong>Date:</strong> {{ formatDate(case_.dateEntree) }}</p>
          <p><strong>Client:</strong> {{ case_.client?.nom || 'Non défini' }}</p>
          <p><strong>Véhicule:</strong> {{ case_.vehicle?.marque }} {{ case_.vehicle?.modele }}</p>
          <p><strong>Expert:</strong> {{ case_.expert?.nom || 'Non assigné' }}</p>
          <p><strong>Assurance:</strong> {{ case_.insurance?.nom || 'Non définie' }}</p>
          <p><strong>Avancement:</strong> {{ case_.avancement }}%</p>
        </div>
        <div class="case-actions">
          <button @click="viewCase(case_.id)" class="btn btn-primary">Voir</button>
          <button @click="editCase(case_.id)" class="btn btn-secondary">Modifier</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const selectedCategory = ref('')
const selectedStatus = ref('')
const cases = ref([])

// Données d'exemple
onMounted(() => {
  cases.value = [
    {
      id: 1,
      dateEntree: new Date('2024-01-15'),
      client: { nom: 'Dupont Jean' },
      vehicle: { marque: 'Peugeot', modele: '208' },
      expert: { nom: 'Martin Expert' },
      insurance: { nom: 'AXA' },
      status: 'en_cours',
      avancement: 45,
      category: 'original'
    },
    {
      id: 2,
      dateEntree: new Date('2024-01-20'),
      client: { nom: 'Durand Marie' },
      vehicle: { marque: 'Renault', modele: 'Clio' },
      expert: { nom: 'Leblanc Expert' },
      insurance: { nom: 'MAIF' },
      status: 'accepte',
      avancement: 80,
      category: 'adaptable'
    }
  ]
})

const filteredCases = computed(() => {
  return cases.value.filter(case_ => {
    const categoryMatch = !selectedCategory.value || case_.category === selectedCategory.value
    const statusMatch = !selectedStatus.value || case_.status === selectedStatus.value
    return categoryMatch && statusMatch
  })
})

const getStatusLabel = (status) => {
  const labels = {
    en_cours: 'En cours',
    prepare: 'Préparé',
    envoye: 'Envoyé',
    accepte: 'Accepté',
    rejete: 'Rejeté'
  }
  return labels[status] || status
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('fr-FR')
}

const viewCase = (id) => {
  console.log('Voir affaire', id)
}

const editCase = (id) => {
  console.log('Modifier affaire', id)
}
</script>

<style scoped>
.home {
  max-width: 1200px;
}

.filters {
  display: flex;
  gap: 15px;
  margin-bottom: 20px;
}

.filter-select {
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  background-color: white;
}

.cases-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 20px;
}

.case-card {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  border: 1px solid #e0e0e0;
}

.case-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.case-header h3 {
  margin: 0;
  color: #2c3e50;
}

.status-badge {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: bold;
}

.status-badge.en_cours {
  background-color: #f39c12;
  color: white;
}

.status-badge.accepte {
  background-color: #27ae60;
  color: white;
}

.status-badge.rejete {
  background-color: #e74c3c;
  color: white;
}

.case-details p {
  margin: 8px 0;
  font-size: 0.9rem;
}

.case-actions {
  display: flex;
  gap: 10px;
  margin-top: 15px;
}

.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
}

.btn-primary {
  background-color: #3498db;
  color: white;
}

.btn-secondary {
  background-color: #95a5a6;
  color: white;
}

.btn:hover {
  opacity: 0.8;
}
</style>
