module.exports = {
    user: 'C##sys', // Nom d'utilisateur Oracle
    password: 'root', // Mot de passe Oracle
    connectString: 'localhost:1521/xe', // Adresse de connexion
    privilege: require('oracledb').SYSDBA
};