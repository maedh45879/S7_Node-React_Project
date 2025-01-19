const oracledb = require('oracledb');
const dbConfig = require('./config/dbConfig');

async function testConnection() {
    let connection;

    try {
        connection = await oracledb.getConnection(dbConfig);
        console.log('Connexion réussie à Oracle Database !');
    } catch (err) {
        console.error('Erreur de connexion :', err);
    } finally {
        if (connection) {
            await connection.close();
        }
    }
}

testConnection();
