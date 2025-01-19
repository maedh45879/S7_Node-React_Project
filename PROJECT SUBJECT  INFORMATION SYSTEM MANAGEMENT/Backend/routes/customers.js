const express = require('express');
const router = express.Router();
const oracledb = require('oracledb');
const dbConfig = require('../config/dbConfig');

// Route pour récupérer tous les clients
router.get('/', async (req, res) => {
    let connection;
    try {
        connection = await oracledb.getConnection(dbConfig);
        const result = await connection.execute('SELECT * FROM customers');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).send('Erreur lors de la récupération des clients');
    } finally {
        if (connection) {
            await connection.close();
        }
    }
});

// Exportation des routes
module.exports = router;
