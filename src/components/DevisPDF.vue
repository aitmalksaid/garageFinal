<template>
  <div class="pdf-container">
    <div class="header">
      <div class="logo">
        <img src="/logo.png" alt="CNG Logo" />
      </div>
      <div class="title">
        <h1>Devis</h1>
        <p>{{ devis.numero_devis }}</p>
      </div>
      <div class="details">
        <p>MARRAKECH, LE : {{ formatDate(devis.date_devis) }}</p>
        <p>DOSSIER N° : {{ devis.numero_devis }}</p>
      </div>
    </div>

    <!-- Client and Assurance Info -->
    <div class="client-assurance-info">
      <div class="left-section">
        <div class="field">
          <span class="label">Nom Client :</span>
          <span class="value">{{ client.nom }} {{ client.prenom }}</span>
        </div>
        <div class="field">
          <span class="label">Téléphone :</span>
          <span class="value">{{ client.telephone || 'N/A' }}</span>
        </div>
        <div class="field">
          <span class="label">Code Client :</span>
          <span class="value">CL{{ String(client.id).padStart(5, '0') }}</span>
        </div>
        <div class="field">
          <span class="label">ICE :</span>
          <span class="value">{{ client.ice || 'N/A' }}</span>
        </div>
      </div>
      <div class="right-section">
        <div class="field">
          <span class="label">Véhicule :</span>
          <span class="value">{{ voiture.marque || 'N/A' }}</span>
        </div>
        <div class="field">
          <span class="label">Matricule :</span>
          <span class="value">{{ voiture.immatriculation || 'N/A' }}</span>
        </div>
        <div class="field">
          <span class="label">Date M.E.C :</span>
          <span class="value">{{ formatDate(voiture.date_mise_en_circulation) || 'N/A' }}</span>
        </div>
        <div class="field">
          <span class="label">Type Dossier :</span>
          <span class="value">BALI HANI</span>
        </div>
        <div class="field">
          <span class="label">Type :</span>
          <span class="value">{{ voiture.modele || 'N/A' }}</span>
        </div>
        <div class="field">
          <span class="label">Num chasis :</span>
          <span class="value">{{ voiture.numero_chassis || 'N/A' }}</span>
        </div>
        <div class="field">
          <span class="label">Réf Sin :</span>
          <span class="value">{{ affaire.ref_sin || 'N/A' }}</span>
        </div>
      </div>
    </div>

    <!-- Assurance and Expert Info -->
    <div class="assurance-expert-info">
      <div class="field">
        <span class="label">Compagnie :</span>
        <span class="value">{{ assurance.nom || 'N/A' }}</span>
      </div>
      <div class="field">
        <span class="label">N° Police :</span>
        <span class="value">{{ assurance.numero_police || 'N/A' }}</span>
      </div>
      <div class="field">
        <span class="label">Expert 1 :</span>
        <span class="value">{{ expert.nom }} {{ expert.prenom }}</span>
      </div>
      <div class="field">
        <span class="label">Expert 2 :</span>
        <span class="value">{{ getExpert2Name() }}</span>
      </div>
      <div class="field">
        <span class="label">Agent :</span>
        <span class="value">{{ assurance.agent || 'N/A' }}</span>
      </div>
    </div>

    <!-- Tableau des articles -->
    <div class="interventions-table">
      <table>
        <thead>
          <tr>
            <th class="col-intervention">Intervention</th>
            <th class="col-designation">Désignation</th>
            <th class="col-qty">Qté</th>
            <th class="col-pu">P.U/H.T</th>
            <th class="col-montant">Montant H.T</th>
            <th class="col-tva">TVA</th>
            <th class="col-ttc">Montant TTC</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="article in devis.articles" :key="article.article_id">
            <td>{{ article.intervention || 'N/A' }}</td>
            <td>{{ article.description || article.Description }}</td>
            <td class="text-center">{{ article.quantite }}</td>
            <td class="text-right">{{ formatPrice(article.prix_ht) }}</td>
            <td class="text-right">{{ formatPrice(article.prix_ht * article.quantite) }}</td>
            <td class="text-center">{{ article.intervention === 'OCCASION' ? '' : (article.prix_ht > 0 ? '20%' : '') }}</td>
            <td class="text-right">{{ formatPrice(article.intervention === 'OCCASION' ? 
                (article.prix_ht * article.quantite) : 
                (article.prix_ht * article.quantite * 1.2)) }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Totals Section -->
    <div class="totals-section">
      <div class="totals-grid">
        <div class="total-fourniture">
          <p class="total-label">Total HT</p>
          <p class="total-value">{{ formatPrice(calculateTotalHT()) }}</p>
          <p class="total-label">Total TTC</p>
          <p class="total-value">{{ formatPrice(calculateTotalTTC()) }}</p>
          <p class="total-label">TVA 20%</p>
          <p class="total-value">{{ formatPrice(calculateTotalTVA()) }}</p>
        </div>
        <div class="total-main-oeuvre">
          <p class="total-label">MO. Mécanique :</p>
          <p class="total-value">{{ formatPrice(calculateMOMecanique()) }}</p>
          <p class="total-label">MO. Électrique :</p>
          <p class="total-value">0,00</p>
          <p class="total-label">MO. Tôlerie :</p>
          <p class="total-value">{{ formatPrice(calculateMOTolerie()) }}</p>
          <p class="total-label">MO. Peinture :</p>
          <p class="total-value">{{ formatPrice(calculateMOPeinture()) }}</p>
        </div>
        <div class="total-autres">
          <p class="total-label">INGREDIENTS :</p>
          <p class="total-value">{{ formatPrice(calculateIngredients()) }}</p>
          <p class="total-label">ADAPTABLE :</p>
          <p class="total-value">0,00</p>
          <p class="total-label">ORIGINE :</p>
          <p class="total-value">{{ formatPrice(calculateTotalHT()) }}</p>
          <p class="total-label">OCCASSION :</p>
          <p class="total-value">{{ formatPrice(calculateOccasion()) }}</p>
          <p class="total-label">AUTRES :</p>
          <p class="total-value">0,00</p>
        </div>
      </div>
      <div class="grand-total">
        <p class="grand-total-text">Arrêté le présent devis à la somme de {{ nombreEnLettres(calculateTotalTTC()) }}</p>
        <p class="total-final">TOTAL : {{ formatPrice(calculateTotalTTC()) }}</p>
      </div>
    </div>

    <button @click="generatePDF" class="no-print">Générer le devis PDF</button>

    <div class="footer">
<img src="/pied.png" alt="Pied de page" class="footer-image" />    </div>
  </div>
</template>

<script setup>
import { defineProps } from 'vue';
import jsPDF from 'jspdf';

const props = defineProps({
  devis: {
    type: Object,
    default: () => ({ articles: [] })
  },
  voiture: {
    type: Object,
    default: () => ({})
  },
  client: {
    type: Object,
    default: () => ({})
  },
  assurance: {
    type: Object,
    default: () => ({})
  },
  affaire: {
    type: Object,
    default: () => ({})
  },
  expert: {
    type: Object,
    default: () => ({})
  },
  expert2: {
    type: Object,
    default: () => ({})
  },
});

const generatePDF = () => {
  const doc = new jsPDF();
  const element = document.querySelector('.pdf-container');

  doc.html(element, {
    callback: (pdf) => {
      pdf.save('devis.pdf');
    },
    x: 10,
    y: 10
  });
};

const formatDate = (dateString) => {
  if (!dateString) return 'N/A';
  const date = new Date(dateString);
  const day = String(date.getDate()).padStart(2, '0');
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const year = date.getFullYear();
  return `${day}/${month}/${year}`;
};

const formatPrice = (price) => {
  if (typeof price !== 'number') return '0,00';
  return price.toFixed(2)
    .replace('.', ',')
    .replace(/\B(?=(\d{3})+(?!\d))/g, ' ');
};

const getExpert2Name = () => {
  if (props.expert2 && props.expert2.nom) {
    return `${props.expert2.nom} ${props.expert2.prenom || ''}`;
  }
  return 'N/A';
};

const calculateTotalHT = () => {
  return props.devis.articles.reduce((total, article) => total + (article.prix_ht * article.quantite), 0);
};

const nombreEnLettres = (number) => {
  const unite = ['', 'un', 'deux', 'trois', 'quatre', 'cinq', 'six', 'sept', 'huit', 'neuf', 'dix', 'onze', 'douze', 'treize', 'quatorze', 'quinze', 'seize', 'dix-sept', 'dix-huit', 'dix-neuf'];
  const dizaine = ['', 'dix', 'vingt', 'trente', 'quarante', 'cinquante', 'soixante', 'soixante-dix', 'quatre-vingt', 'quatre-vingt-dix'];
  
  const convertirNombre = (n) => {
    if (n < 20) return unite[n];
    if (n < 100) {
      const div = Math.floor(n / 10);
      const reste = n % 10;
      if (div === 7 || div === 9) {
        return dizaine[div-1] + (reste ? '-' + unite[reste + 10] : '');
      }
      return dizaine[div] + (reste ? '-' + unite[reste] : '');
    }
    if (n < 1000) {
      const centaine = Math.floor(n / 100);
      const reste = n % 100;
      return (centaine === 1 ? 'cent' : unite[centaine] + ' cent') + (reste ? ' ' + convertirNombre(reste) : '');
    }
    if (n < 1000000) {
      const millier = Math.floor(n / 1000);
      const reste = n % 1000;
      return (millier === 1 ? 'mille' : convertirNombre(millier) + ' mille') + (reste ? ' ' + convertirNombre(reste) : '');
    }
    return 'nombre trop grand';
  };

  // Séparer les parties entière et décimale
  const parts = number.toFixed(2).split('.');
  const entier = parseInt(parts[0]);
  const decimales = parseInt(parts[1]);

  // Convertir la partie entière
  let result = convertirNombre(entier) + ' Dirhams';
  
  // Ajouter les centimes si non nuls
  if (decimales > 0) {
    result += ', ' + convertirNombre(decimales) + ' Centimes';
  }

  return result.charAt(0).toUpperCase() + result.slice(1);
};

const calculateTotalTTC = () => {
  const total = props.devis.articles.reduce((total, article) => {
    const montant = article.prix_ht * article.quantite;
    return total + (article.intervention === 'OCCASION' ? montant : montant * 1.2);
  }, 0);
  return total;
};

const calculateTotalTVA = () => {
  return props.devis.articles.reduce((total, article) => {
    if (article.intervention === 'OCCASION') return total;
    return total + ((article.prix_ht * article.quantite) * 0.2);
  }, 0);
};

const calculateMOMecanique = () => {
  return props.devis.mo_mecanique || 0;
};

const calculateMOTolerie = () => {
  return props.devis.mo_tolerie || 0;
};

const calculateMOPeinture = () => {
  return props.devis.mo_peinture || 0;
};

const calculateIngredients = () => {
  return props.devis.ingredients || 0;
};

const calculateOccasion = () => {
  return props.devis.articles.reduce((total, article) => {
    if (article.intervention === 'OCCASION') {
      return total + (article.prix_ht * article.quantite * 1.2);
    }
    return total;
  }, 0);
};
</script>

<style scoped>
.pdf-container {
  position: relative;
  width: 210mm;
  height: 297mm;
  padding: 10mm;
  background: white;
  font-family: Arial, sans-serif;
  font-size: 11px;  /* Augmenté de 3px */
  color: black;
  line-height: 1.3;  /* Ajusté pour la nouvelle taille */
}
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid black;
  padding-bottom: 5px;
  margin-bottom: 10px;
}
.logo img {
  width: 80px;
  height: auto;
}
.title {
  text-align: center;
}
.title h1 {
  font-size: 21px;  /* Augmenté de 3px */
  margin: 0;
  font-weight: bold;
}
.details {
  text-align: right;
  font-size: 11px;  /* Augmenté de 3px */
}
.details p {
  margin: 0;
}
.client-assurance-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
  gap: 10px;
}
.left-section, .right-section {
  width: 48%;
  border: 1px solid black;
  padding: 8px;
}
.field {
  margin-bottom: 3px;
  display: flex;
}
.label {
  font-weight: bold;
  font-size: 11px;  /* Augmenté de 3px */
  width: 100px;
  flex-shrink: 0;
}
.value {
  font-size: 11px;  /* Augmenté de 3px */
  margin-left: 5px;
}
.assurance-expert-info {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  margin-bottom: 10px;
  border: 1px solid black;
  padding: 8px;
}
.assurance-expert-info .field {
  width: 33%;
  box-sizing: border-box;
  padding-right: 10px;
  margin-bottom: 5px;
}
.interventions-table {
  margin-top: 10px;
  margin-bottom: 10px;
  width: 100%;
  border-collapse: collapse;
  font-size: 9px;  /* Augmenté de 2px */
  table-layout: fixed;
}
.interventions-table th, .interventions-table td {
  border: 0.5px solid black;
  padding: 4px 6px;  /* Padding uniforme */
  font-size: 9px;  /* Augmenté de 2px */
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.interventions-table th {
  background-color: #f5f5f5;
  font-weight: bold;
  font-size: 9px;  /* Augmenté de 2px */
}

/* Distribution des largeurs des colonnes */
.col-intervention { width: 15%; }    /* Intervention */
.col-designation { width: 45%; }     /* Désignation - largeur augmentée */
.col-qty { width: 5%; }             /* Qté */
.col-pu { width: 10%; }             /* P.U/H.T */
.col-montant { width: 10%; }        /* Montant H.T */
.col-tva { width: 5%; }             /* TVA */
.col-ttc { width: 10%; }            /* Montant TTC */
.text-right {
  text-align: right;
}
.text-center {
  text-align: center;
}
.totals-section {
  margin-top: 10px;
  padding-top: 5px;
}
.totals-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 5px;
}
.total-fourniture, .total-main-oeuvre, .total-autres {
  border: 0.5px solid black;
  padding: 3px;
  font-size: 7px;
}
.total-label {
  margin: 0;
  font-size: 10px;  /* Augmenté de 3px */
  display: inline-block;
  width: 60%;
}
.total-value {
  margin: 0;
  font-size: 10px;  /* Augmenté de 3px */
  text-align: right;
  display: inline-block;
  width: 35%;
}
.grand-total {
  margin-top: 5px;
  padding-top: 3px;
  text-align: center;
}
.grand-total-text {
  margin: 0;
  font-size: 10px;  /* Augmenté de 3px */
  font-weight: normal;
}
.total-final {
  margin: 0;
  font-size: 12px;  /* Augmenté de 3px */
  font-weight: bold;
  margin-top: 2px;
}
.button {
  text-align: center;
  margin-top: 10px;
}
.no-print {
  display: none;
}
.footer {
  position: absolute;
  bottom: 0;
  width: calc(100% - 20mm);
  text-align: center;
}
.footer-image {
  max-width: 100%;
  height: auto;
}
@media print {
  .no-print {
    display: none;
  }
}
</style>
