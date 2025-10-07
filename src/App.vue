<template>
  <div class="app-container">
    <!-- Menu fixe à gauche -->
    <nav class="sidebar">
      <div class="sidebar-header">
        <h2>Gestion Garage</h2>
      </div>
      <ul class="nav-menu">
        <li><router-link to="/" class="nav-link">Accueil</router-link></li>
        <li><router-link to="/clients" class="nav-link">Clients</router-link></li>
        <li><router-link to="/fournisseurs" class="nav-link">Fournisseurs</router-link></li>
        <li><router-link to="/articles" class="nav-link">Articles</router-link></li>
        <li><router-link to="/experts" class="nav-link">Experts</router-link></li>
        <li><router-link to="/assurances" class="nav-link">Assurances</router-link></li>
        <li><router-link to="/voitures" class="nav-link">Voitures</router-link></li>
        <li><router-link to="/affaires" class="nav-link">Affaires</router-link></li>
        <li><router-link to="/devis" class="nav-link">Devis</router-link></li>
        <li><router-link to="/bons-commande" class="nav-link">Bons de Commande</router-link></li>
        <li><router-link to="/benefices" class="nav-link">Bénéfices</router-link></li>
        <li><router-link to="/suivi-reparations-table" class="nav-link">Suivi Réparations (Tableau)</router-link></li>
        <li><router-link to="/suivi-reparations-cards" class="nav-link">Suivi Réparations (Cartes)</router-link></li>
        <li><router-link to="/test" class="nav-link">Test Page</router-link></li>
        <li><router-link to="/test-reparation" class="nav-link">Test Reparation</router-link></li>
      </ul>
    </nav>

    <!-- Contenu principal -->
    <main class="main-content">
      <router-view />
    </main>
  </div>
</template>

<style scoped>
.app-container {
  display: flex;
  min-height: 100vh;
}

.sidebar {
  position: fixed;
  left: 0;
  top: 0;
  width: 250px;
  height: 100vh;
  background-color: #2c3e50;
  color: white;
  padding: 0;
  overflow-y: auto;
}

.sidebar-header {
  padding: 20px;
  border-bottom: 1px solid #34495e;
}

.sidebar-header h2 {
  margin: 0;
  font-size: 1.5rem;
}

.nav-menu {
  list-style: none;
  padding: 0;
  margin: 0;
}

.nav-menu li {
  border-bottom: 1px solid #34495e;
}

.nav-link {
  display: block;
  padding: 15px 20px;
  color: white;
  text-decoration: none;
  transition: background-color 0.3s;
}

.nav-link:hover,
.nav-link.router-link-active {
  background-color: #3498db;
}

.main-content {
  margin-left: 250px;
  padding: 20px;
  flex: 1;
  background-color: #f8f9fa;
  min-height: 100vh;
}
</style>