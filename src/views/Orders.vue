
<template>
  <div class="orders-page">
    <div class="page-header">
      <h1>Gestion des Bons de Commande</h1>
      <p class="info-text">Les bons de commande sont générés automatiquement à partir des devis acceptés</p>
    </div>

    <!-- Liste des bons de commande -->
    <div class="orders-list">
      <h2>Liste des Bons de Commande</h2>
      <div class="table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>N° BC</th>
              <th>N° Devis Source</th>
              <th>Date Création</th>
              <th>Client</th>
              <th>Véhicule</th>
              <th>Total TTC</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="order in orders" :key="order.id">
              <td>{{ order.numero }}</td>
              <td>{{ order.numeroDevisSource }}</td>
              <td>{{ formatDate(order.dateCreation) }}</td>
              <td>{{ order.client }}</td>
              <td>{{ order.matriculeVehicule }}</td>
              <td>{{ order.totalTTC?.toFixed(2) || '0.00' }} Dhs</td>
              <td class="actions">
                <button @click="viewOrderDetails(order)" class="btn btn-sm btn-primary">Détails</button>
                <button @click="printOrder(order)" class="btn btn-sm btn-secondary">Imprimer</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal détails du bon de commande -->
    <div v-if="selectedOrder" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>Bon de Commande {{ selectedOrder.numero }}</h3>
          <button @click="closeModal" class="close-btn">&times;</button>
        </div>
        
        <div class="modal-body">
          <div class="order-info">
            <div class="info-section">
              <h4>Informations générales</h4>
              <p><strong>Numéro BC:</strong> {{ selectedOrder.numero }}</p>
              <p><strong>Devis source:</strong> {{ selectedOrder.numeroDevisSource }}</p>
              <p><strong>Date création:</strong> {{ formatDate(selectedOrder.dateCreation) }}</p>
              <p><strong>Client:</strong> {{ selectedOrder.client }}</p>
              <p><strong>Véhicule:</strong> {{ selectedOrder.matriculeVehicule }}</p>
            </div>
          </div>

          <div class="articles-section">
            <h4>Articles commandés</h4>
            <table class="articles-table">
              <thead>
                <tr>
                  <th>Pièce</th>
                  <th>Statut</th>
                  <th>Prix HT</th>
                  <th>TVA</th>
                  <th>Prix TTC</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(article, index) in selectedOrder.articles" :key="index">
                  <td>{{ article.piece }}</td>
                  <td>
                    <select v-model="article.statut" @change="updateArticleStatus(article)" class="status-select">
                      <option value="demande_envoyee">Demande envoyée</option>
                      <option value="en_cours_montage">En cours de montage</option>
                      <option value="finalise">Finalisé</option>
                    </select>
                  </td>
                  <td>{{ article.totalHT?.toFixed(2) || '0.00' }} Dhs</td>
                  <td>{{ article.tva?.toFixed(2) || '0.00' }} Dhs</td>
                  <td>{{ article.totalTTC?.toFixed(2) || '0.00' }} Dhs</td>
                  <td>
                    <span :class="getArticleStatusClass(article.statut)">
                      {{ getArticleStatusText(article.statut) }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="totals-section">
            <p><strong>Total HT: {{ selectedOrder.totalHT?.toFixed(2) || '0.00' }} Dhs</strong></p>
            <p><strong>Total TVA: {{ selectedOrder.totalTVA?.toFixed(2) || '0.00' }} Dhs</strong></p>
            <p><strong>Total TTC: {{ selectedOrder.totalTTC?.toFixed(2) || '0.00' }} Dhs</strong></p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'

export default {
  name: 'Orders',
  setup() {
    const selectedOrder = ref(null)
    const orders = ref([
      {
        id: 1,
        numero: 'BC-2024-001',
        numeroDevisSource: 'DEV-2024-001',
        dateCreation: '2024-01-16',
        client: 'Dupont Jean',
        matriculeVehicule: 'ABC-123',
        articles: [
          {
            piece: 'Pare-choc avant',
            statut: 'demande_envoyee',
            totalHT: 200,
            tva: 40,
            totalTTC: 240
          }
        ],
        totalHT: 200,
        totalTVA: 40,
        totalTTC: 240
      }
    ])

    const viewOrderDetails = (order) => {
      selectedOrder.value = { ...order }
    }

    const closeModal = () => {
      selectedOrder.value = null
    }

    const updateArticleStatus = (article) => {
      // Logique pour mettre à jour le statut de l'article
      console.log('Statut article mis à jour:', article)
    }

    const printOrder = (order) => {
      // Logique d'impression
      alert(`Impression du bon de commande ${order.numero}`)
    }

    const formatDate = (dateStr) => {
      return new Date(dateStr).toLocaleDateString('fr-FR')
    }

    const getArticleStatusText = (status) => {
      const statusMap = {
        'demande_envoyee': 'Demande envoyée',
        'en_cours_montage': 'En cours de montage',
        'finalise': 'Finalisé'
      }
      return statusMap[status] || status
    }

    const getArticleStatusClass = (status) => {
      const classMap = {
        'demande_envoyee': 'status-warning',
        'en_cours_montage': 'status-info',
        'finalise': 'status-success'
      }
      return `status-badge ${classMap[status] || ''}`
    }

    return {
      selectedOrder,
      orders,
      viewOrderDetails,
      closeModal,
      updateArticleStatus,
      printOrder,
      formatDate,
      getArticleStatusText,
      getArticleStatusClass
    }
  }
}
</script>

<style scoped>
.orders-page {
  padding: 20px;
}

.page-header {
  margin-bottom: 30px;
}

.info-text {
  color: #6c757d;
  font-style: italic;
  margin-top: 5px;
}

.orders-list {
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

.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.btn-primary { background-color: #007bff; color: white; }
.btn-secondary { background-color: #6c757d; color: white; }
.btn-sm { padding: 4px 8px; font-size: 12px; }

/* Modal styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  padding: 0;
  border-radius: 8px;
  max-width: 800px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #ddd;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #999;
}

.modal-body {
  padding: 20px;
}

.info-section {
  margin-bottom: 20px;
}

.info-section h4 {
  margin-bottom: 10px;
  color: #333;
}

.articles-section {
  margin: 20px 0;
}

.articles-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 10px;
}

.articles-table th,
.articles-table td {
  padding: 8px;
  text-align: left;
  border-bottom: 1px solid #ddd;
}

.articles-table th {
  background-color: #f8f9fa;
}

.status-select {
  padding: 4px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 12px;
}

.status-badge {
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: bold;
}

.status-success { background-color: #d4edda; color: #155724; }
.status-warning { background-color: #fff3cd; color: #856404; }
.status-info { background-color: #d1ecf1; color: #0c5460; }

.totals-section {
  border-top: 2px solid #007bff;
  padding-top: 15px;
  text-align: right;
}
</style>
