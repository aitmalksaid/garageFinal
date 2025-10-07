<template>
	<div class="suivi-reparations-cards">
		<header>
			<h1>Suivi des réparations (Cartes)</h1>
			<div class="devis-info">
				<!-- Infos du devis à afficher ici -->
			</div>
		</header>
		<section class="cards-container">
			<div v-for="reparation in reparations" :key="reparation.id" class="reparation-card">
				<h2>{{ reparation.designation }}</h2>
				<p><strong>Référence :</strong> {{ reparation.reference }}</p>
				<p><strong>Quantité :</strong> {{ reparation.quantite }}</p>
				<p><strong>Prix :</strong> {{ reparation.prix }}</p>
				<div class="stepper">
					<div v-for="(step, idx) in steps" :key="step" class="step" :class="{active: idx === reparation.etape}" @click="changeStep(reparation, idx)">
						<span>{{ step }}</span>
					</div>
				</div>
			</div>
		</section>
	</div>
</template>

<script>
import { supabase } from '../supabase';

export default {
  name: 'SuiviReparationsCardsPage',
  data() {
    return {
      steps: [
        'Recherche de la pièce',
        'Demande de la pièce',
        'Réception de la pièce',
        'Changement de la pièce',
        'Test',
        'Terminé'
      ],
      reparations: []
    };
  },
  async mounted() {
    await this.fetchReparations();
  },
  methods: {
    async fetchReparations() {
      try {
        const { data: devisData, error: devisError } = await supabase
          .from('devis')
          .select('id')
          .eq('statut', 'devis accepter');

        if (devisError) {
          console.error('Error fetching accepted quotes:', devisError);
          return;
        }

        const devisIds = devisData.map(devis => devis.id);

        const { data: articlesData, error: articlesError } = await supabase
          .from('devis_articles')
          .select('id, description, reference, quantite, prix_ht, state')
          .filter('devis_id', 'in', `(${devisIds.join(',')})`);

        if (articlesError) {
          console.error('Error fetching articles for accepted quotes:', articlesError);
          return;
        }

        this.reparations = articlesData.map(article => ({
          id: article.id,
          designation: article.description, // Use `description` instead of `designation`
          reference: article.reference,
          quantite: article.quantite,
          prix: article.prix_ht, // Use `prix_ht` for price
          etape: article.state ?? 0 // Default to 'Recherche de la pièce'
        }));
      } catch (e) {
        console.error('Unexpected error:', e);
      }
    },
    async addArticleToRepairTracking(articleId) {
      try {
        const { data, error } = await supabase
          .from('repair_tracking')
          .insert({ repair_id: articleId, state: 0 }); // Default state: 'Recherche de la pièce'

        if (error) {
          console.error('Error adding article to repair tracking:', error);
        } else {
          console.log('Article added to repair tracking:', data);
          await this.fetchReparations();
        }
      } catch (e) {
        console.error('Unexpected error:', e);
      }
    },
    async changeStep(reparation, newStep) {
      try {
        const { error } = await supabase
          .from('repair_tracking')
          .update({ state: newStep })
          .eq('id', reparation.id);

        if (error) {
          console.error('Error updating repair state:', error);
        } else {
          reparation.etape = newStep;
        }
      } catch (e) {
        console.error('Unexpected error:', e);
      }
    }
  }
};
</script>

<style scoped>
.suivi-reparations-cards {
	padding: 2rem;
}
.cards-container {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
	gap: 1.5rem;
}
.reparation-card {
	background: #fff;
	border: 1px solid #ddd;
	border-radius: 8px;
	box-shadow: 0 2px 8px rgba(0,0,0,0.05);
	padding: 1.5rem;
}
.stepper {
	display: flex;
	flex-wrap: wrap;
	gap: 0.5rem;
	margin-top: 1rem;
}
.step {
	padding: 0.3rem 0.7rem;
	border-radius: 12px;
	background: #eee;
	font-size: 0.8rem;
	text-align: center;
	flex: 1;
	cursor: pointer;
}
.step.active {
	background: #1976d2;
	color: #fff;
	font-weight: bold;
}
.step:hover {
	background: #bbdefb;
}
</style>
