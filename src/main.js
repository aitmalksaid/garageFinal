import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import App from './App.vue'
import './assets/main.css'

// Import des composants
import HomePage from './pages/HomePage.vue'
import ClientsPage from './pages/ClientsPage.vue'
import FournisseursPage from './pages/FournisseursPage.vue'
import ExpertsPage from './pages/ExpertsPage.vue'
import AssurancesPage from './pages/AssurancesPage.vue'
import VoituresPage from './pages/VoituresPage.vue'
import AffairesPage from './pages/AffairesPage.vue'
import DevisPage from './pages/DevisPage.vue'
import BonsCommandePage from './pages/BonsCommandePage.vue'
import BeneficesPage from './pages/BeneficesPage.vue'
import ArticlesPage from './pages/ArticlesPage.vue'
import TestPage from './pages/TestPage.vue'
import SuiviReparationsTablePage from './pages/SuiviReparationsTablePage.vue';
import SuiviReparationsCardsPage from './pages/SuiviReparationsCardsPage.vue';
import TestReparation from './pages/TestReparation.vue';

const routes = [
  { path: '/', component: HomePage },
  { path: '/clients', component: ClientsPage },
  { path: '/fournisseurs', component: FournisseursPage },
  { path: '/experts', component: ExpertsPage },
  { path: '/assurances', component: AssurancesPage },
  { path: '/voitures', component: VoituresPage },
  { path: '/affaires', component: AffairesPage },
  { path: '/devis', component: DevisPage },
  { path: '/bons-commande', component: BonsCommandePage },
  { path: '/benefices', component: BeneficesPage },
  { path: '/articles', component: ArticlesPage },
  { path: '/test', component: TestPage },
  { path: '/suivi-reparations-table', component: SuiviReparationsTablePage },
  { path: '/suivi-reparations-cards', component: SuiviReparationsCardsPage },
  { path: '/test-reparation', component: TestReparation }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

const app = createApp(App)
app.use(router)
app.mount('#app')
