const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

// Import des routes
const bankersRoutes = require('./routes/bankers');
const customersRoutes = require('./routes/customers');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Utilisation des routes
app.use('/api/bankers', bankersRoutes);
app.use('/api/customers', customersRoutes);

// Route de vérification de santé
app.get('/health', (req, res) => {
    res.status(200).json({ message: 'Server is healthy!' });
});

// Démarrage du serveur
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
