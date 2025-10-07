import { supabase } from '@/supabase';

class DataService {
  // Méthodes génériques CRUD
  async getAll(table) {
    const { data, error } = await supabase.from(table).select('*');
    if (error) throw error;
    return data;
  }

  async getById(table, id) {
    const { data, error } = await supabase.from(table).select('*').eq('id', id).single();
    if (error) throw error;
    return data;
  }

  async create(table, items) {
    const itemsArray = Array.isArray(items) ? items : [items];
    console.log('Creating item(s) in table:', table, 'with data:', itemsArray);
    const { data, error } = await supabase.from(table).insert(itemsArray).select();
    if (error) {
      console.error('Error during creation:', error);
      throw error;
    }
    return Array.isArray(items) ? data : data[0];
  }

  async update(table, id, updates) {
    const { data, error } = await supabase.from(table).update(updates).eq('id', id).select().single();
    if (error) throw error;
    return data;
  }

  async delete(table, id) {
    const { error } = await supabase.from(table).delete().eq('id', id);
    if (error) throw error;
    return true;
  }

  async deleteWhere(table, column, value) {
    const { error } = await supabase.from(table).delete().eq(column, value);
    if (error) throw error;
    return true;
  }

  async getAllByField(table, field, value) {
    const { data, error } = await supabase.from(table).select('*').eq(field, value);
    if (error) throw error;
    return data;
  }

  // Méthodes spécifiques pour les clients
  getAllClients() {
    return this.getAll('clients');
  }

  createClient(client) {
    return this.create('clients', client);
  }

  async updateClient(id, client) {
    // Ne pas inclure l'ID dans les données à mettre à jour
    const { id: _, ...clientData } = client;
    return this.update('clients', id, clientData);
  }

  deleteClient(id) {
    return this.delete('clients', id);
  }

  async checkClientExists(ice, email, excludeId = null) {
    const iceValue = ice ? ice.trim() : null;
    const emailValue = email ? email.trim().toLowerCase() : null;

    if (!iceValue && !emailValue) {
      return { exists: false };
    }

    const orConditions = [];
    if (iceValue) {
      orConditions.push(`ice.eq.${iceValue}`);
    }
    if (emailValue) {
      // Recherche insensible à la casse pour l'email
      orConditions.push(`email.ilike.${emailValue}`);
    }

    let query = supabase.from('clients').select('id, ice, email').or(orConditions.join(','));

    const { data, error } = await query;

    if (error) throw error;

    const conflictingClient = excludeId
      ? data.find(c => c.id !== excludeId)
      : (data.length > 0 ? data[0] : null);

    if (conflictingClient) {
      if (iceValue && conflictingClient.ice === iceValue) {
        return { exists: true, field: 'ICE' };
      }
      if (emailValue && conflictingClient.email.toLowerCase() === emailValue) {
        return { exists: true, field: 'Email' };
      }
    }

    return { exists: false };
  }

  // Méthodes spécifiques pour les voitures
  getAllVoitures() {
    return this.getAll('voitures');
  }

  createVoiture(voiture) {
    return this.create('voitures', voiture);
  }

  updateVoiture(id, voiture) {
    return this.update('voitures', id, voiture);
  }

  deleteVoiture(id) {
    return this.delete('voitures', id);
  }

  // Méthodes spécifiques pour les devis
  getAllDevis() {
    return this.getAll('devis');
  }

  createDevis(devis) {
    return this.create('devis', devis);
  }

  updateDevis(id, devis) {
    return this.update('devis', id, devis);
  }

  deleteDevis(id) {
    return this.delete('devis', id);
  }

  async getNextDevisNumber() {
    const { data, error } = await supabase.rpc('get_next_devis_number');
    if (error) {
      console.error('Error fetching next devis number:', error);
      throw error;
    }
    return data;
  }

  // Convertir un devis en bon de commande avec la nouvelle logique
  async convertDevisToBonCommande(devisId) {
    const devis = await this.getById('devis', devisId);
    if (!devis) {
      throw new Error('Devis non trouvé');
    }

    // Récupérer les articles du devis
    const devisArticles = await this.getDevisArticles(devisId);

    // Grouper les articles par fournisseur
    const articlesByFournisseur = {};

    for (const article of devisArticles) {
      const fournisseurId = article.fournisseur_id || null;
      if (!articlesByFournisseur[fournisseurId]) {
        articlesByFournisseur[fournisseurId] = [];
      }
      articlesByFournisseur[fournisseurId].push(article);
    }

    const createdBonsCommande = [];

    // Créer un bon de commande pour chaque fournisseur
    for (const [fournisseurId, articles] of Object.entries(articlesByFournisseur)) {
      const bonCommandeData = {
        affaire_id: devis.affaire_id,
        fournisseur_id: fournisseurId === 'null' ? null : parseInt(fournisseurId),
        devis_id: devisId,
        date_commande: new Date().toISOString().split('T')[0],
        statut: 'brouillon',
        montant_total: 0, // Sera calculé par le trigger
        notes: `Bon de commande généré automatiquement depuis le devis ${devis.numero_devis}`
      };

      // Créer le bon de commande
      const bonCommande = await this.create('bons_commande', bonCommandeData);

      // Ajouter les articles au bon de commande
      for (const article of articles) {
        const totalHT = article.prix_ht * article.quantite;
        const bonCommandeArticleData = {
          bon_commande_id: bonCommande.id,
          article_id: article.article_id,
          description: article.description,
          quantite: article.quantite,
          prix_unitaire: article.prix_ht,
          total_ht: totalHT,
          statut: 'en_attente',
          intervention: article.intervention || 'REMPLACEMENT'
        };

        await this.create('bons_commande_articles', bonCommandeArticleData);
      }

      createdBonsCommande.push(bonCommande);
    }

    return createdBonsCommande;
  }

  // Méthodes pour les articles de devis
  async getDevisArticles(devisId) {
    return this.getAllByField('devis_articles', 'devis_id', devisId);
  }

  async createDevisArticle(articleData) {
    try {
      // Utiliser une insertion directe pour contourner le cache de schéma
      const { data, error } = await supabase
        .from('devis_articles')
        .insert([{
          devis_id: articleData.devis_id,
          article_id: articleData.article_id,
          description: articleData.description,
          quantite: articleData.quantite,
          prix_ht: articleData.prix_ht,
          fournisseur_id: articleData.fournisseur_id,
          intervention: articleData.intervention || 'REMPLACEMENT',
          prix_achat_final: articleData.prix_achat_final
        }])
        .select()
        .single();

      if (error) {
        console.error('Error creating devis article:', error);
        throw error;
      }

      return data;
    } catch (error) {
      console.error('Error in createDevisArticle:', error);
      throw error;
    }
  }

  async updateDevisArticle(id, articleData) {
    const { id: _, ...articleDataWithoutId } = articleData;
    return this.update('devis_articles', id, articleDataWithoutId);
  }

  async deleteAllDevisArticles(devisId) {
    return this.deleteWhere('devis_articles', 'devis_id', devisId);
  }

  // Méthodes pour les affaires
  async getAllAffaires() {
    const { data, error } = await supabase
      .from('affaires')
      .select('id, numero_affaire, date_ouverture, voiture_id, client_id, assurance_id, expert_id, expert_id_2, statut, ref_Sin');
    if (error) throw error;
    return data;
  }

  // Méthode pour récupérer les affaires avec toutes les relations
  async getAllAffairesWithRelations() {
    const { data, error } = await supabase
      .from('affaires')
      .select(`
        id,
        numero_affaire,
        date_ouverture,
        statut,
        ref_Sin,
        expert_id_2,
        clients!client_id (
          id,
          nom,
          prenom
        ),
        voitures!voiture_id (
          id,
          marque,
          modele,
          immatriculation
        ),
        experts!expert_id (
          id,
          nom,
          prenom
        ),
        assurances!assurance_id (
          id,
          nom
        )
      `);
    if (error) throw error;
    return data;
  }

  createAffaire(affaire) {
    return this.create('affaires', affaire);
  }

  updateAffaire(id, affaire) {
    return this.update('affaires', id, affaire);
  }

  deleteAffaire(id) {
    return this.delete('affaires', id);
  }

  // Méthodes pour les experts
  getAllExperts() {
    return this.getAll('experts');
  }

  createExpert(expert) {
    return this.create('experts', expert);
  }

  updateExpert(id, expert) {
    return this.update('experts', id, expert);
  }

  deleteExpert(id) {
    return this.delete('experts', id);
  }

  // Méthodes pour les assurances
  getAllAssurances() {
    return this.getAll('assurances');
  }

  createAssurance(assurance) {
    return this.create('assurances', assurance);
  }

  updateAssurance(id, assurance) {
    return this.update('assurances', id, assurance);
  }

  deleteAssurance(id) {
    return this.delete('assurances', id);
  }

  // Méthodes pour les fournisseurs
  getAllFournisseurs() {
    return this.getAll('fournisseurs');
  }

  createFournisseur(fournisseur) {
    const fournisseurData = {
      ...fournisseur,
      categorie: fournisseur.categorie || 'tous' // Valeur par défaut
    };
    return this.create('fournisseurs', fournisseurData);
  }

  updateFournisseur(id, fournisseur) {
    return this.update('fournisseurs', id, fournisseur);
  }

  deleteFournisseur(id) {
    return this.delete('fournisseurs', id);
  }

  // Méthodes pour les articles
  getAllArticles() {
    return this.getAll('articles');
  }

  createArticle(article) {
    const { Description, PrixHT, Fournisseur } = article;
    return this.create('articles', {
      "Description": Description,
      "PrixHT": PrixHT,
      "Fournisseur": Fournisseur
    });
  }

  updateArticle(id, article) {
    const { id: _, Description, PrixHT, Fournisseur, ...rest } = article;
    const articleData = {
      "Description": Description,
      "PrixHT": PrixHT,
      "Fournisseur": Fournisseur,
      ...rest
    };
    return this.update('articles', id, articleData);
  }

  deleteArticle(id) {
    return this.delete('articles', id);
  }

  // Méthodes pour les bons de commande
  getAllBonsCommande() {
    return this.getAll('bons_commande');
  }

  async getAllBonsCommandeWithRelations() {
    const { data, error } = await supabase
      .from('bons_commande')
      .select(`
        id,
        numero_bon,
        date_commande,
        statut,
        montant_total,
        notes,
        date_prevue_livraison,
        affaires!affaire_id (
          id,
          numero_affaire,
          clients!client_id (
            id,
            nom,
            prenom
          ),
          voitures!voiture_id (
            id,
            marque,
            modele,
            immatriculation
          )
        ),
        fournisseurs!fournisseur_id (
          id,
          nom,
          telephone,
          email
        ),
        devis!devis_id (
          id,
          numero_devis
        )
      `);
    if (error) throw error;
    return data;
  }

  createBonCommande(bonCommande) {
    return this.create('bons_commande', bonCommande);
  }

  updateBonCommande(id, bonCommande) {
    return this.update('bons_commande', id, bonCommande);
  }

  deleteBonCommande(id) {
    return this.delete('bons_commande', id);
  }

  // Méthodes pour les articles de bons de commande
  async getBonCommandeArticles(bonCommandeId) {
    const { data, error } = await supabase
      .from('bons_commande_articles')
      .select('*')
      .eq('bon_commande_id', bonCommandeId);

    if (error) {
      console.error('Error fetching bon commande articles:', error);
      throw error;
    }

    return data;
  }

  async createBonCommandeArticle(articleData) {
    return this.create('bons_commande_articles', articleData);
  }

  async updateBonCommandeArticle(id, articleData) {
    return this.update('bons_commande_articles', id, articleData);
  }

  async deleteBonCommandeArticle(id) {
    return this.delete('bons_commande_articles', id);
  }

  async updateBonCommandeArticleStatus(articleId, statut, dateReception = null) {
    const updateData = { statut };
    if (dateReception) {
      updateData.date_reception = dateReception;
    }
    return this.update('bons_commande_articles', articleId, updateData);
  }
  
  async updateBonCommandeArticleStatus(articleId, statut) {
    return this.update('bons_commande_articles', articleId, { statut });
  }

  async getBonCommandeProgress(bonCommandeId) {
    const articles = await this.getBonCommandeArticles(bonCommandeId);
    if (articles.length === 0) return 0;

    const weights = {
      'en_attente': 0,
      'commande': 25,
      'recu': 75,
      'monte': 100
    };

    const totalWeight = articles.reduce((sum, article) => {
      return sum + (weights[article.statut] || 0);
    }, 0);

    return Math.round(totalWeight / articles.length);
  }

  
  // Méthodes pour les benefices
  getAllBenefices() {
    return this.getAll('benefices');
  }

  createBenefice(benefice) {
    return this.create('benefices', benefice);
  }

  updateBenefice(id, benefice) {
    return this.update('benefices', id, benefice);
  }

  deleteBenefice(id) {
    return this.delete('benefices', id);
  }

  // Calculer les bénéfices par affaire
  async calculateProfitsByAffaire() {
    const affaires = await this.getAllAffaires();
    const devis = await this.getAllDevis();
    const bonsCommande = await this.getAllBonsCommande();

    return affaires.map(affaire => {
      const affaireDevis = devis.filter(d => d.affaire_id === affaire.id);
      const affaireBonsCommande = bonsCommande.filter(bc => bc.affaire_id === affaire.id);

      const totalDevis = affaireDevis.reduce((sum, d) => sum + (d.montant_ttc || 0), 0);
      const totalBonsCommande = affaireBonsCommande.reduce((sum, bc) => sum + (bc.montant_total || 0), 0);

      return {
        affaireId: affaire.id,
        numeroAffaire: affaire.numero_affaire,
        totalDevis,
        totalBonsCommande,
        profit: totalDevis - totalBonsCommande
      };
    });
  }
}

const dataServiceInstance = new DataService();
export default dataServiceInstance;
