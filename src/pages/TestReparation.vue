<template>
  <div class="container mx-auto p-6">
    <h1 class="text-2xl font-bold mb-6">Test Reparation</h1>

    <table class="table-auto w-full border-collapse border border-gray-300">
      <thead>
        <tr>
          <th class="border border-gray-300 px-4 py-2">ID</th>
          <th class="border border-gray-300 px-4 py-2">Repair ID</th>
          <th class="border border-gray-300 px-4 py-2">State</th>
          <th class="border border-gray-300 px-4 py-2">Updated At</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in repairTracking" :key="row.id">
          <td class="border border-gray-300 px-4 py-2">{{ row.id }}</td>
          <td class="border border-gray-300 px-4 py-2">{{ row.repair_id }}</td>
          <td class="border border-gray-300 px-4 py-2">{{ row.state }}</td>
          <td class="border border-gray-300 px-4 py-2">{{ row.updated_at }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import { supabase } from '../supabase';

export default {
  name: 'TestReparation',
  data() {
    return {
      repairTracking: []
    };
  },
  async mounted() {
    await this.fetchRepairTracking();
  },
  methods: {
    async fetchRepairTracking() {
      try {
        const { data, error } = await supabase
          .from('repair_tracking')
          .select('*');

        if (error) {
          console.error('Error fetching repair tracking data:', error);
        } else {
          this.repairTracking = data;
        }
      } catch (e) {
        console.error('Unexpected error:', e);
      }
    }
  }
};
</script>

<style scoped>
.container {
  max-width: 1000px;
}
.table-auto {
  width: 100%;
  border-collapse: collapse;
}
th, td {
  border: 1px solid #ddd;
  padding: 8px;
  text-align: left;
}
th {
  background-color: #f4f4f4;
}
</style>
