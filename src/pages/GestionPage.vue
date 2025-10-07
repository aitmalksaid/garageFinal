<template>
    <div class="container mx-auto p-6">
        <h1 class="text-2xl font-bold mb-6">Gestion du devis #{{ devi.id }}</h1>
        
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
                        v-model="item.statut_id"
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
export default {
    data() {
        return {
            devi: {
                id: 123,
                client: 'Client Exemple',
                vehicule: 'Peugeot 308 - AB-123-CD',
                items: [
                    { 
                        designation: 'MAIN D'OUVRE Tolerie', 
                        type: 'main_oeuvre',
                        sous_type: 'Tolerie',
                        statut_id: 3 
                    },
                    { 
                        designation: 'MAIN D'OUVRE Peinture',
                        type: 'main_oeuvre',
                        sous_type: 'Peinture',
                        statut_id: 2 
                    },
                    { 
                        designation: 'feu rouge', 
                        type: 'piece',
                        reference: 'REF-001',
                        statut_id: 4 
                    }
                ]
            },
            statuts: [
                { id: 1, nom: 'En recherche' },
                { id: 2, nom: 'En attente pièce' },
                { id: 3, nom: 'En cours de montage' },
                { id: 4, nom: 'Terminé' }
            ],
            statusLabels: {
                1: 'En recherche',
                2: 'En attente pièce',
                3: 'En cours de montage',
                4: 'Terminé'
            },
            statusClasses: {
                1: 'bg-yellow-100 border-yellow-200 text-yellow-800',
                2: 'bg-orange-100 border-orange-200 text-orange-800',
                3: 'bg-blue-100 border-blue-200 text-blue-800',
                4: 'bg-green-100 border-green-200 text-green-800'
            }
        }
    },
    computed: {
        progression() {
            const total = this.devi.items.length;
            const completed = this.devi.items.filter(item => item.statut_id === 4).length;
            return Math.round((completed / total) * 100);
        }
    },
    methods: {
        async updateStatus(item) {
            try {
                const { error } = await this.$supabase
                    .from('devis_items')
                    .update({ statut_id: item.statut_id })
                    .eq('id', item.id);
                
                if (error) throw error;
                console.log('Statut mis à jour avec succès');
            } catch (error) {
                console.error('Erreur de mise à jour:', error.message);
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
statuts: [
        { id: 1, nom: 'En recherche', couleur: 'yellow' },
        { id: 2, nom: 'En attente pièce', couleur: 'orange' },
        { id: 3, nom: 'En cours de montage', couleur: 'blue' },
        { id: 4, nom: 'Terminé', couleur: 'green' }
      ],
</script>

<style scoped>
.container {
    max-width: 1000px;
}
</style>