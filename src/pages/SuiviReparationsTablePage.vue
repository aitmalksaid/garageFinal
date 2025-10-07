<template>
  <div class="suivi-reparations-table">
    <header>
      <h1>Suivi des réparations (Tableau)</h1>
    </header>
    <section>
      <table>
        <thead>
          <tr>
            <th>Désignation</th>
            <th>Référence</th>
            <th>Quantité</th>
            <th>Prix</th>
            <th>État</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="reparation in reparations" :key="reparation.id">
            <td>{{ reparation.designation }}</td>
            <td>{{ reparation.reference }}</td>
            <td>{{ reparation.quantite }}</td>
            <td>{{ reparation.prix }}</td>
            <td>
              <select v-model="reparation.etape">
                <option v-for="(step, idx) in steps" :value="idx">{{ step }}</option>
              </select>
            </td>
          </tr>
        </tbody>
      </table>
    </section>
  </div>
</template>

<script>
export default {
  name: 'SuiviReparationsTablePage',
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
      reparations: [
        {
          id: 1,
          designation: 'Plaquette de frein',
          reference: 'PF-123',
          quantite: 2,
          prix: 80,
          etape: 2
        },
        {
          id: 2,
          designation: 'Amortisseur avant',
          reference: 'AM-456',
          quantite: 1,
          prix: 150,
          etape: 4
        },
        {
          id: 3,
          designation: 'Filtre à huile',
          reference: 'FO-789',
          quantite: 1,
          prix: 20,
          etape: 1
        }
      ]
    };
  }
};
</script>

<style scoped>
.suivi-reparations-table {
  padding: 2rem;
}
table {
  width: 100%;
  border-collapse: collapse;
}
th, td {
  border: 1px solid #ddd;
  padding: 0.5rem;
  text-align: left;
}
th {
  background-color: #f4f4f4;
}
select {
  padding: 0.3rem;
  border: 1px solid #ddd;
  border-radius: 4px;
}
</style>