import { ref, onMounted } from 'vue'
import dataService from '@/services/dataService.js'

const updateVoiture = async (id, voitureData) => {
  const { data, error } = await supabase
    .from('voitures')
    .update(voitureData)
    .eq('id', id)

  if (error) throw error
  return data
}

export function useDataService() {
  const devis = ref([])
  const clients = ref([])
  const voitures = ref([])
  const fournisseurs = ref([])
  const experts = ref([])
  const assurances = ref([])
  const affaires = ref([])
  const bonsCommande = ref([])
  const benefices = ref([])
  const articles = ref([])

  // Fonction pour charger toutes les données
  const loadAllData = async () => {
    try {
      [
        devis.value,
        clients.value,
        voitures.value,
        fournisseurs.value,
        experts.value,
        assurances.value,
        affaires.value,
        bonsCommande.value,
        benefices.value,
        articles.value
      ] = await Promise.all([
        dataService.getAllDevis(),
        dataService.getAllClients(),
        dataService.getAllVoitures(),
        dataService.getAllFournisseurs(),
        dataService.getAllExperts(),
        dataService.getAllAssurances(),
        dataService.getAllAffaires(),
        dataService.getAllBonsCommande(),
        dataService.getAllBenefices(),
        dataService.getAllArticles()
      ]);
    } catch (error) {
      console.error('Error loading data:', error);
      throw error;
    }
  }

  // Initialiser les données
  onMounted(loadAllData);

  return {
    // Données réactives
    devis,
    clients,
    voitures,
    fournisseurs,
    experts,
    assurances,
    affaires,
    bonsCommande,
    benefices,
    articles,

    // Fonctions
    loadAllData,
    
    getBonCommandeArticles: dataService.getBonCommandeArticles,
    updateBonCommandeArticleStatus: dataService.updateBonCommandeArticleStatus,

    // Service direct
    dataService
  }
}
