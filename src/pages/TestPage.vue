<template>
  <div class="container mx-auto p-6">
    <h1 class="text-2xl font-bold mb-6">Gestion du devis #{{ devi.id }}</h1>
    <h1 class="text-2xl font-bold mb-6">Test Supabase Connection</h1>

    <div class="bg-white rounded-lg shadow-md p-6 mb-6">
      <p>Connection Status: {{ connectionStatus }}</p>
    </div>

    <div class="bg-white rounded-lg shadow-md p-6 mb-6">
      <div class="flex justify-between items-center mb-4">
        <div>
          <h2 class="text-xl font-semibold">{{ devi.client }}</h2>
          <p class="text-gray-600">{{ devi.vehicule }}</p>
        </div>
        <div class="text-right">
          <span class="text-lg font-bold text-blue-600">
            Progression : {{ progression }}%
          </span>
        </div>
      </div>

      <div class="space-y-4">
        <div v-for="(item, index) in devi.items" :key="index" class="border rounded-lg p-4">
          <div class="flex justify-between items-center">
            <div>
              <h3 class="font-medium">{{ item.designation }}</h3>
              <p class="text-sm text-gray-500">{{ item.reference }}</p>
            </div>
            <select 
              v-model="item.status"
              @change="updateStatus(item)"
              class="px-4 py-2 rounded-lg border focus:outline-none focus:ring-2"
              :class="statusClasses[item.status]"
            >
              <option v-for="(label, key) in statusLabels" :key="key" :value="key">
                {{ label }}
              </option>
            </select>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { supabase } from '../supabase'

export default {
  data() {
    return {
      devi: {
        id: 123,
        client: 'Client Exemple',
        vehicule: 'Peugeot 308 - AB-123-CD',
        items: [
          { designation: 'Amortisseur avant', reference: 'REF-001', status: 'en_cours' },
          { designation: 'Plaquettes de frein', reference: 'REF-002', status: 'en_attente' },
          { designation: 'Disque de frein', reference: 'REF-003', status: 'termine' },
        ]
      },
      statusLabels: {
        en_recherche: 'En recherche',
        en_attente: 'En attente pièce',
        en_cours: 'En cours de montage',
        termine: 'Terminé'
      },
      statusClasses: {
        en_recherche: 'bg-yellow-100 border-yellow-200 text-yellow-800',
        en_attente: 'bg-orange-100 border-orange-200 text-orange-800',
        en_cours: 'bg-blue-100 border-blue-200 text-blue-800',
        termine: 'bg-green-100 border-green-200 text-green-800'
      },
      connectionStatus: 'Not Tested'
    }
  },
  computed: {
    progression() {
      const total = this.devi.items.length
      const completed = this.devi.items.filter(item => item.status === 'termine').length
      return Math.round((completed / total) * 100)
    }
  },
  async mounted() {
    await this.testConnection()
  },
  methods: {
    updateStatus(item) {
      // Logique de mise à jour à connecter avec l'API
      console.log('Statut mis à jour pour', item.designation, ':', item.status)
    },
    async testConnection() {
      try {
        const { data, error } = await supabase
          .from('marques')
          .select('*')
          .limit(1);

        if (error) {
          console.error('Error fetching data:', error)
          this.connectionStatus = 'Error: ' + error.message
        } else {
          console.log('Data fetched successfully:', data)
          this.connectionStatus = 'Success!'
        }
      } catch (e) {
        console.error('Unexpected error:', e)
        this.connectionStatus = 'Error: ' + e.message
      }
    }
  }
}
</script>

<style scoped>
.container {
  max-width: 1000px;
}
</style>