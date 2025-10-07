
<template>
  <div class="page-container">
    <h1>Gestion des Devis</h1>
    
    <!-- Section liste des devis -->
    <div v-if="!showForm" class="devis-list">
      <div class="list-header">
        <h2>Liste des Devis</h2>
        <button @click="showAddForm" class="btn btn-primary">
          Ajouter un devis
        </button>
      </div>
      
      <div class="devis-table">
        <table>
          <thead>
            <tr>
              <th>Numéro</th>
              <th>Date</th>
              <th>Affaire</th>
              <th>Statut</th>
              <th>Montant HT</th>
              <th>Montant TTC</th>
              <th>Actions</th>
              <th>Prix Achat Final</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="d in devis" :key="d.id">
              <td>{{ d.numero_devis || `${d.id}/${new Date(d.date_devis).toLocaleDateString('fr-FR').replace(/\//g, '-')}` }}</td>
              <td>{{ new Date(d.date_devis).toLocaleDateString('fr-FR') }}</td>
              <td>{{ getAffaire(d.affaire_id).numero_affaire || 'N/A' }}</td>
              <td>
                <select 
                  :value="d.statut || 'nouveau Devis'"
                  @change="changeStatut(d.id, $event.target.value, d.statut)"
                  class="status-select"
                  :class="{'status-accepted': d.statut === 'devis accepter'}"
                >
                  <option>nouveau Devis</option>
                  <option>devis enregistrer</option>
                  <option>devis envoyer</option>
                  <option>en attente reponse</option>
                  <option>devis refuser</option>
                  <option>devis accepter</option>
                </select>
              </td>
              <td>{{ d.montant_ht.toFixed(2) }} Dhs</td>
              <td>{{ d.montant_ttc.toFixed(2) }} Dhs</td>
              <td>
                <button @click="editDevis(d)" class="btn btn-sm btn-secondary">
                  Éditer
                </button>
                <button @click="printDevis(d)" class="btn btn-sm btn-info">
                  Imprimer
                </button>
                <button @click="deleteDevis(d.id)" class="btn btn-sm btn-danger">
                  Supprimer
                </button>
              </td>
            </tr>
          </tbody>
        </table>
        
        <div v-if="devis.length === 0" class="empty-state">
          <p>Aucun devis trouvé.</p>
          <button @click="showAddForm" class="btn btn-primary">
            Créer votre premier devis
          </button>
        </div>
      </div>
    </div>
    
    <!-- Section formulaire -->
    <form v-if="showForm" @submit.prevent="saveDevis" class="devis-form" id="devis-form">
      <div class="form-section">
        <h2>{{ editingDevis ? 'Modifier le devis' : 'Créer un nouveau devis' }}</h2>
        <div class="form-row">
          <div class="form-group">
            <label>Date</label>
            <input v-model="form.date_devis" type="date" required>
          </div>
        </div>
        
        <div class="form-group">
          <label>Affaire</label>
          <select v-model="form.affaire_id" required>
            <option :value="null">Sélectionner une affaire</option>
            <option v-for="affaire in affaires" :key="affaire.id" :value="affaire.id">
              {{ affaire.numero_affaire }}
            </option>
          </select>
        </div>

        <div class="form-group">
          <label>Statut</label>
          <select v-model="form.statut" required>
            <option>nouveau Devis</option>
            <option>devis enregistrer</option>
            <option>devis envoyer</option>
            <option>en attente reponse</option>
            <option>devis refuser</option>
            <option>devis accepter</option>
          </select>
        </div>

        <div class="form-section">
          <h2>Articles</h2>
          <div v-for="(article, index) in form.articles" :key="index" class="article-row">
            <div class="form-group">
              <label>Intervention</label>
              <select v-model="article.intervention">
                <option value="REMPLACEMENT">REMPLACEMENT</option>
                <option value="OCCASION">OCCASION</option>
                <option value="REDRESSAGE">REDRESSAGE</option>
                <option value="ADAPTABLE">ADAPTABLE</option>
                <option value="ORIGINE">ORIGINE</option>
              </select>
            </div>
            <div class="form-group">
              <label>Article</label>
              <input v-model="article.Description" @change="handleArticleInput(index)" list="articles-datalist" type="text" placeholder="Saisir ou sélectionner un article">
              <datalist id="articles-datalist">
                <option v-for="art in articles" :key="art.id" :value="art.Description"></option>
              </datalist>
            </div>
            <div class="form-group">
              <label>Fournisseur</label>
              <select v-model="article.fournisseur_id" :disabled="!!article.article_id">
                <option :value="null">Sélectionner un fournisseur</option>
                <option v-for="f in fournisseurs" :key="f.id" :value="f.id">{{ f.nom }}</option>
              </select>
            </div>
            <div class="form-group">
              <label>Prix HT</label>
              <input v-model.number="article.prix_ht" type="number" step="0.01">
            </div>
            <div class="form-group">
              <label>Quantité</label>
              <input v-model.number="article.quantite" type="number" min="1">
            </div>
            <div class="form-group">
              <label>Prix Achat Final</label>
              <input v-model.number="article.prix_achat_final" type="number" step="0.01">
            </div>
            <div class="form-group">
               <label>Total HT</label>
               <input :value="(article.prix_ht * article.quantite).toFixed(2)" type="text" disabled>
             </div>
            <div class="form-group">
               <label>TVA</label>
               <input :value="article.intervention === 'OCCASION' ? '0%' : '20%'" type="text" disabled>
             </div>
            <div class="form-group">
               <label>Total TTC</label>
               <input :value="getTotalTTCForArticle(article).toFixed(2)" type="text" disabled>
             </div>
            <button type-="button" @click="removeArticle(index)" class="btn-remove">
              &times;
            </button>
          </div>
          <button type="button" @click="addArticle" class="btn-add">
            Ajouter un article
          </button>
        </div>

        <div class="form-section">
          <h2>Prix (Main d'oeuvre, etc.)</h2>
          <div class="form-row">
            <div class="form-group">
              <label>MAIN D'OUVRE Tolerie</label>
              <input v-model.number="form.MO_tolerie" type="number" step="0.01" required>
            </div>
            <div class="form-group">
              <label>  Main d'Oeuvre Peinture</label>
              <input v-model.number="form.MO_peinture" type="number" step="0.01" required>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>MAIN D'OUVRE Mécanique</label>
              <input v-model.number="form.MO_mecanique" type="number" step="0.01" required>
            </div>
            <div class="form-group">
              <label>MAIN D'OUVRE Électrique</label>
              <input v-model.number="form.MO_electrique" type="number" step="0.01" required>
            </div>
          </div>
        </div>

        <div class="form-section">
          <h2>Totaux</h2>
          <div class="totals">
            <div class="total-row">
              <span>Total HT:</span>
              <span>{{ form.montant_ht.toFixed(2) }} Dhs</span>
            </div>
            <div class="total-row">
              <span>TVA (20%):</span>
              <span>{{ form.montant_tva.toFixed(2) }} Dhs</span>
            </div>
            <div class="total-row total-ttc">
              <strong>
                <span>Total TTC:</span>
                <span>{{ form.montant_ttc.toFixed(2) }} Dhs</span>
              </strong>
            </div>
          </div>
        </div>

        <div class="form-actions">
          <button type="submit" class="btn btn-primary">Enregistrer le devis</button>
          <button type="button" @click="cancelForm" class="btn btn-secondary">Annuler</button>
          <button type="button" @click="printDevis(form)" class="btn btn-info">Imprimer</button>
        </div>
      </div>
    </form>

    <div v-if="devisToPrint" style="position: absolute; left: -9999px; top: -9999px;">
      <DevisPDF
        id="pdf-content"
        :devis="devisToPrint"
        :affaire="getAffaire(devisToPrint.affaire_id)"
        :client="getClient(getAffaire(devisToPrint.affaire_id).client_id)"
        :voiture="getVoiture(getAffaire(devisToPrint.affaire_id).voiture_id)"
        :assurance="getAssurance(getAffaire(devisToPrint.affaire_id).assurance_id)"
        :expert="getExpert(getAffaire(devisToPrint.affaire_id).expert_id)"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import { useDataService } from '../composables/useDataService'
import DevisPDF from '../components/DevisPDF.vue'
import jsPDF from 'jspdf'
import html2canvas from 'html2canvas'

const { devis, affaires, clients, voitures, assurances, experts, articles, fournisseurs, dataService, loadAllData } = useDataService()

const showForm = ref(false) // Cacher le formulaire par défaut, afficher la liste
const editingDevis = ref(null)
const devisToPrint = ref(null)

const form = ref({
  date_devis: new Date().toISOString().split('T')[0],
  affaire_id: null,
  statut: 'nouveau Devis',
  montant_ht: 0,
  montant_tva: 0,
  montant_ttc: 0,
  MO_tolerie: 0,
  MO_peinture: 0,
  MO_mecanique: 0,
  MO_electrique: 0,
  articles: []
})

watch(() => [form.value.MO_tolerie, form.value.MO_peinture, form.value.MO_mecanique, form.value.MO_electrique, form.value.articles], () => {
  const articlesTotal = form.value.articles.reduce((sum, art) => sum + (art.prix_ht * art.quantite), 0);
  const articlesTVA = form.value.articles.reduce((sum, art) => {
    const totalHT = art.prix_ht * art.quantite;
    const tvaRate = art.intervention === 'OCCASION' ? 0 : 0.20;
    return sum + (totalHT * tvaRate);
  }, 0);
  
  const otherPrices = (form.value.MO_tolerie || 0) +
                    (form.value.MO_peinture || 0) +
                    (form.value.MO_mecanique || 0) +
                    (form.value.MO_electrique || 0);
  const otherPricesTVA = otherPrices * 0.20;
  
  const ht = articlesTotal + otherPrices;
  form.value.montant_ht = ht;
  form.value.montant_tva = articlesTVA + otherPricesTVA;
  form.value.montant_ttc = form.value.montant_ht + form.value.montant_tva;
}, { deep: true })

const resetForm = () => {
  form.value = {
    date_devis: new Date().toISOString().split('T')[0],
    affaire_id: null,
    statut: 'nouveau Devis',
    montant_ht: 0,
    montant_tva: 0,
    montant_ttc: 0,
    MO_tolerie: 0,
    MO_peinture: 0,
    MO_mecanique: 0,
    MO_electrique: 0,
    articles: []
  }
  editingDevis.value = null
}

const addArticle = () => {
  form.value.articles.push({
    article_id: null,
    Description: '',
    quantite: 1,
    prix_ht: 0,
    fournisseur_id: null,
    original_prix_ht: 0,
    intervention: 'REMPLACEMENT',
    prix_achat_final: 0
  });
};

const removeArticle = (index) => {
  form.value.articles.splice(index, 1);
};

const handleArticleInput = (index) => {
  const currentArticle = form.value.articles[index];
  const existingArticle = articles.value.find(a => a.Description.toLowerCase() === currentArticle.Description.toLowerCase());

  if (existingArticle) {
    currentArticle.article_id = existingArticle.id;
    updateArticleDetails(index);
  } else {
    currentArticle.article_id = null;
  }
};

const updateArticleDetails = (index) => {
  const currentArticle = form.value.articles[index];
  const selectedArticle = articles.value.find(a => a.id === currentArticle.article_id);
  if (selectedArticle) {
    currentArticle.Description = selectedArticle.Description;
    currentArticle.prix_ht = selectedArticle.PrixHT;
    currentArticle.fournisseur_id = selectedArticle.Fournisseur;
    currentArticle.original_prix_ht = selectedArticle.PrixHT;
  }
};

const getFournisseurName = (fournisseurId) => {
   if (!fournisseurId) return 'N/A';
   const fournisseur = fournisseurs.value.find(f => f.id === fournisseurId);
   return fournisseur ? fournisseur.nom : 'Inconnu';
};

const getTotalTTCForArticle = (article) => {
  const totalHT = article.prix_ht * article.quantite;
  const tvaRate = article.intervention === 'OCCASION' ? 0 : 0.20;
  return totalHT * (1 + tvaRate);
};

const saveDevis = async () => {
  try {
    let devisData = { ...form.value };
    delete devisData.articles;
    if (editingDevis.value) {
      delete devisData.id; // Ne pas essayer de mettre à jour l'ID auto-généré
    }
    let devisId;
    const previousStatus = editingDevis.value?.statut;

    if (editingDevis.value) {
      devisId = editingDevis.value.id;
      await dataService.updateDevis(devisId, devisData);
    } else {
      // Logique de secours pour la génération de numéro de devis
      const allDevis = await dataService.getAllDevis();
      const currentYear = new Date().getFullYear();
      const yearSuffix = String(currentYear).slice(-2);
      const existingDevisThisYear = allDevis.filter(d => d.numero_devis && d.numero_devis.startsWith(yearSuffix + 'AF'));
      const nextNumber = existingDevisThisYear.length + 1;
      const formattedNumber = String(nextNumber).padStart(5, '0');
      const numero_devis = `${yearSuffix}AF${formattedNumber}`;
      
      const finalDevisData = { ...devisData, numero_devis };
      const newDevis = await dataService.createDevis(finalDevisData);
      devisId = newDevis.id;
    }

    // Si le statut passe à "devis accepter", créer un bon de commande
    if (devisData.statut === 'devis accepter' && previousStatus !== 'devis accepter') {
      await dataService.convertDevisToBonCommande(devisId);
      alert('✅ Devis accepté avec succès ! Un bon de commande a été créé automatiquement.');
    }

    await dataService.deleteAllDevisArticles(devisId);
    
    // Sauvegarder les articles normaux
    for (let article of form.value.articles) {
      let artId = article.article_id;
      if (!artId && article.Description) {
        const newArticleData = {
          Description: article.Description,
          PrixHT: article.prix_ht,
          Fournisseur: article.fournisseur_id
        };
        const newArt = await dataService.createArticle(newArticleData);
        artId = newArt.id;
      } else if (artId && article.prix_ht !== article.original_prix_ht) {
        await dataService.updateArticle(artId, { PrixHT: article.prix_ht });
      }
      const articleData = {
        devis_id: devisId,
        article_id: artId,
        description: article.Description,
        quantite: article.quantite,
        prix_ht: article.prix_ht,
        fournisseur_id: article.fournisseur_id,
        intervention: article.intervention
      };
      await dataService.createDevisArticle(articleData);
    }

    // Les prix de main d'œuvre sont déjà sauvegardés dans la table 'devis' via devisData.
    // Il n'est plus nécessaire de les créer comme des articles séparés.

    await loadAllData();
    cancelForm();
  } catch (error) {
    console.error("Erreur lors de la sauvegarde du devis:", error);
    alert(`Erreur lors de la sauvegarde du devis: ${error.message}`);
  }
};

const editDevis = async (d) => {
  editingDevis.value = d;
  
  // Charger les articles associés à ce devis (ne devrait plus contenir la main d'œuvre)
  const loadedArticles = await dataService.getDevisArticles(d.id);
  
  const formattedArticles = loadedArticles.map(art => {
    const mainArticle = articles.value.find(a => a.id === art.article_id);
    const origPrice = mainArticle ? mainArticle.PrixHT : art.prix_ht;
    return {
      id: art.id,
      article_id: art.article_id,
      Description: art.description || (mainArticle ? mainArticle.Description : ''),
      quantite: art.quantite,
      prix_ht: art.prix_ht,
      fournisseur_id: art.fournisseur_id,
      original_prix_ht: origPrice,
      intervention: art.intervention || 'REMPLACEMENT'
    };
  });

  // Pré-remplir le formulaire avec les données du devis et ses articles
  form.value = {
    id: d.id,
    date_devis: d.date_devis.split('T')[0],
    affaire_id: d.affaire_id,
    statut: d.statut || 'nouveau Devis',
    montant_ht: d.montant_ht,
    montant_tva: d.montant_tva,
    montant_ttc: d.montant_ttc,
    MO_tolerie: d.MO_tolerie,
    MO_peinture: d.MO_peinture,
    MO_mecanique: d.MO_mecanique,
    MO_electrique: d.MO_electrique,
    articles: formattedArticles,
    numero_devis: d.numero_devis
  };
  
  showForm.value = true;
}

const deleteDevis = async (id) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer ce devis ?')) {
    try {
      await dataService.deleteAllDevisArticles(id)
      await dataService.deleteDevis(id)
      await loadAllData()
    } catch (error) {
      console.error('Erreur lors de la suppression du devis:', error)
    }
  }
}

const showAddForm = () => {
  resetForm()
  showForm.value = true
}

const cancelForm = () => {
  resetForm()
  showForm.value = false
}

const printDevis = async (devisData) => {
  let articlesForPrint = [];
  if (showForm.value && (editingDevis.value?.id === devisData.id || !editingDevis.value)) {
    articlesForPrint = form.value.articles;
  } else {
    // Avec la nouvelle logique, getDevisArticles ne retourne plus les articles de main d'œuvre
    const loadedArticles = await dataService.getDevisArticles(devisData.id);
    articlesForPrint = loadedArticles.map(art => ({
      ...art,
      Description: art.description,
      intervention: art.intervention || 'REMPLACEMENT'
    }));
  }
  devisToPrint.value = {
    ...devisData,
    articles: articlesForPrint.map(art => ({
      ...art,
      description: articles.value.find(a => a.id === art.article_id)?.Description || art.Description || 'N/A',
      intervention: art.intervention || 'REMPLACEMENT'
    }))
  }
  setTimeout(() => {
    const pdfElement = document.getElementById('pdf-content')
    if (pdfElement) {
      html2canvas(pdfElement).then(canvas => {
        const imgData = canvas.toDataURL('image/png')
        const pdf = new jsPDF('p', 'mm', 'a4')
        const pdfWidth = pdf.internal.pageSize.getWidth()
        const pdfHeight = (canvas.height * pdfWidth) / canvas.width
        pdf.addImage(imgData, 'PNG', 0, 0, pdfWidth, pdfHeight)
        pdf.save(`devis-${devisData.numero_devis || 'nouveau'}.pdf`)
        devisToPrint.value = null
      })
    }
  }, 100)
}

const changeStatut = async (devisId, newStatut, previousStatut) => {
  try {
    await dataService.updateDevis(devisId, { statut: newStatut });
    
    // Si le statut passe à "devis accepter", créer un bon de commande
    if (newStatut === 'devis accepter' && previousStatut !== 'devis accepter') {
      const createdBonsCommande = await dataService.convertDevisToBonCommande(devisId);
      const nbBons = createdBonsCommande.length;
      const fournisseurText = nbBons > 1 ? `${nbBons} bons de commande ont été créés` : 'Un bon de commande a été créé';
      alert(`✅ Devis accepté avec succès ! ${fournisseurText} automatiquement (un par fournisseur).`);
    }
    
    await loadAllData();
  } catch (error) {
    console.error("Erreur lors de la modification du statut:", error);
    alert(`Erreur lors de la modification du statut: ${error.message}`);
  }
};

const getAffaire = (affaireId) => affaires.value.find(a => a.id === affaireId) || {}
const getClient = (clientId) => clients.value.find(c => c.id === clientId) || {}
const getVoiture = (voitureId) => voitures.value.find(v => v.id === voitureId) || {}
const getAssurance = (assuranceId) => assurances.value.find(a => a.id === assuranceId) || {}
const getExpert = (expertId) => experts.value.find(e => e.id === expertId) || {}

</script>

<style scoped>
.page-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.devis-form {
  background: white;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.form-section {
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 1px solid #eee;
}

.form-section:last-child {
  border-bottom: none;
}

.form-section h2 {
  color: #2c3e50;
  margin-bottom: 20px;
}

.form-row {
  display: flex;
  gap: 20px;
  margin-bottom: 15px;
}

.form-group {
  flex: 1;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
  color: #34495e;
}

.form-group input,
.form-group select {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.article-row {
  display: grid;
  grid-template-columns: 1fr 2fr 1.5fr 1fr 1fr 1fr 0.8fr 1fr auto;
  gap: 15px;
  align-items: end;
  margin-bottom: 15px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 4px;
}

.price-alert {
  color: #e74c3c;
  font-size: 12px;
  margin-top: 5px;
  font-weight: bold;
}

.btn-add,
.btn-remove {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.btn-add {
  background: #27ae60;
  color: white;
}

.btn-remove {
  background: #e74c3c;
  color: white;
  height: fit-content;
}

.totals {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 4px;
}

.total-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
  font-size: 16px;
}

.total-ttc {
  border-top: 2px solid #2c3e50;
  padding-top: 10px;
  font-size: 18px;
}

.form-actions {
  display: flex;
  gap: 15px;
  justify-content: flex-end;
  margin-top: 30px;
}

.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;
}

.btn-primary {
  background: #3498db;
  color: white;
}

.btn-secondary {
  background: #95a5a6;
  color: white;
}

.btn:hover {
  opacity: 0.9;
}

/* Styles pour la liste des devis */
.devis-list {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  margin-bottom: 30px;
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 30px;
  border-bottom: 1px solid #eee;
}

.list-header h2 {
  color: #2c3e50;
  margin: 0;
}

.devis-table {
  padding: 30px;
}

table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 20px;
}

table th,
table td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

table th {
  background-color: #f8f9fa;
  font-weight: bold;
  color: #2c3e50;
  border-bottom: 2px solid #dee2e6;
}

table tbody tr:hover {
  background-color: #f8f9fa;
}

.btn-sm {
  padding: 6px 12px;
  font-size: 12px;
  margin-right: 5px;
}

.btn-danger {
  background: #e74c3c;
  color: white;
}

.btn-info {
  background: #17a2b8;
  color: white;
}

.empty-state {
  text-align: center;
  padding: 40px 20px;
  color: #6c757d;
}

.empty-state p {
  font-size: 18px;
  margin-bottom: 20px;
}

/* Styles pour les badges de statut */
.status-badge {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: bold;
  text-transform: uppercase;
  display: inline-block;
  min-width: 80px;
  text-align: center;
}

.status-accepted {
  background-color: #27ae60;
  color: white;
}

.status-normal {
  background-color: #95a5a6;
  color: white;
}

/* Styles pour le select de statut */
.status-select {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: bold;
  text-transform: uppercase;
  border: 1px solid #ddd;
  background-color: #95a5a6;
  color: white;
  cursor: pointer;
  min-width: 140px;
}

.status-select.status-accepted {
  background-color: #27ae60;
  color: white;
}

.status-select:hover {
  opacity: 0.8;
}

.status-select:focus {
  outline: none;
  border-color: #3498db;
}
</style>
