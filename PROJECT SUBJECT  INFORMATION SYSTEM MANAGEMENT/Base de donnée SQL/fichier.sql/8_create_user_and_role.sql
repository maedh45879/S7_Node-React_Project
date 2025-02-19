DROP ROLE C##admin_role ;
DROP ROLE C##manager_role ;
DROP ROLE C##regular_user_role ;
DROP USER C##admin_user CASCADE;
DROP USER C##manager_user CASCADE;
DROP USER C##regular_user CASCADE;

DROP VIEW regular_user_view;
DROP TABLE Access_Log;

-- CREATION DES ROLES : Utilisation des rôles pour centraliser la gestion des privilèges, facilitant les modifications futures.

-- Création d'un rôle pour l'administrateur avec accès complet
CREATE ROLE C##admin_role;

-- Création d'un rôle pour le manager avec accès limité
CREATE ROLE C##manager_role;

-- Création d'un rôle pour l'utilisateur régulier avec accès en lecture seule
CREATE ROLE C##regular_user_role;


-- CREATION D'UTILISATEURS : Chaque utilisateur a un rôle spécifique correspondant à ses responsabilités

-- Création de l'utilisateur Administrateur avec le rôle admin_role
CREATE USER C##admin_user IDENTIFIED BY admin_password;
GRANT CONNECT TO C##admin_user; -- Permet à l'utilisateur de se connecter
GRANT C##admin_role TO C##admin_user; -- Assigne le rôle admin_role

-- Création de l'utilisateur Manager avec le rôle manager_role
CREATE USER C##manager_user IDENTIFIED BY manager_password;
GRANT CONNECT TO C##manager_user; -- Permet à l'utilisateur de se connecter
GRANT C##manager_role TO C##manager_user; -- Assigne le rôle manager_role

-- Création de l'utilisateur Régulier avec le rôle regular_user_role
CREATE USER C##regular_user IDENTIFIED BY regular_password;
GRANT CONNECT TO C##regular_user; -- Permet à l'utilisateur de se connecter
GRANT C##regular_user_role TO C##regular_user; -- Assigne le rôle regular_user_role

-- Création d'une vue pour l'utilisateur régulier
CREATE VIEW regular_user_view AS
SELECT Name, Surname, Phone
FROM Banker;

-- ATTRIBUTIONS DES PRIVILEGES : Privilèges attribués uniquement aux rôles, et non directement aux utilisateurs

-- L'administrateur a un accès complet à toutes les tables (lecture, écriture, mise à jour, suppression)
GRANT SELECT, INSERT, UPDATE, DELETE ON Banker TO C##admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON customers TO C##admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON loans TO C##admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON credit_history TO C##admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON deliquency TO C##admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON Financial_Obligations TO C##admin_role;

-- Le manager peut lire toutes les données et modifier uniquement certaines données sensibles
GRANT SELECT, INSERT, UPDATE ON customers TO C##manager_role; -- Modification autorisée uniquement pour les clients
GRANT SELECT ON loans TO C##manager_role; -- Lecture seule sur les prêts
GRANT SELECT ON Banker TO C##manager_role; -- Lecture seule sur les informations des banquiers

-- L'utilisateur régulier a uniquement un accès en lecture sur une vue sécurisée
GRANT SELECT ON regular_user_view TO C##regular_user_role;


-- SECURISATION DU SYSTEM 

-- Création d'une table pour journaliser les accès et les actions effectuées par les utilisateurs
-- et ainsi avoir une meilleure traçabilité.
CREATE TABLE Access_Log (
    log_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY, -- Identifiant unique pour chaque enregistrement
    user_name VARCHAR2(50), -- Nom de l'utilisateur ayant effectué l'action
    action_performed VARCHAR2(100), -- Description de l'action effectuée
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Date et heure de l'action
);

-- Politique de sécurité pour la gestion des mots de passe
ALTER PROFILE DEFAULT LIMIT
  PASSWORD_LIFE_TIME 90
  PASSWORD_GRACE_TIME 10
  PASSWORD_REUSE_TIME 180;


   