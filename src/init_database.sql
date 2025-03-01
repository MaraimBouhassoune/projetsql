CREATE TABLE IF NOT EXISTS stations (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    zone INTEGER NOT NULL
);

CREATE TYPE moyen_transport AS ENUM ('metro', 'rer');

CREATE TABLE IF NOT EXISTS lignes (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(32) NOT NULL,
    type moyen_transport NOT NULL,
    capacite_max INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS arrets (
    id SERIAL PRIMARY KEY,
    id_station INTEGER NOT NULL,
    id_ligne INTEGER NOT NULL
);

ALTER TABLE arrets ADD CONSTRAINT fk_arrets_stations FOREIGN KEY (id_station) REFERENCES stations(id);
ALTER TABLE arrets ADD CONSTRAINT fk_arrets_lignes FOREIGN KEY (id_ligne) REFERENCES lignes(id);

CREATE TABLE IF NOT EXISTS horaires (
    id SERIAL PRIMARY KEY,
    id_arret INTEGER NOT NULL,
    horaire TIME NOT NULL);
ALTER TABLE horaires ADD CONSTRAINT fk_horaires_arrets FOREIGN KEY (id_arret) REFERENCES arrets(id);

CREATE TABLE IF NOT EXISTS supports (
    id SERIAL PRIMARY KEY,
    identifiant VARCHAR(12) NOT NULL,
    date_achat TIMESTAMP NOT NULL);
CREATE TABLE IF NOT EXISTS abonnements (
    id SERIAL PRIMARY KEY,
    id_support INTEGER,
    id_dossier INTEGER,
    id_tarification INTEGER,
    date_debut TIMESTAMP,
    date_fin TIMESTAMP NOT NULL);
ALTER TABLE abonnements ADD CONSTRAINT fk_abonnements_supports FOREIGN KEY (id_support) REFERENCES supports(id);

CREATE TABLE IF NOT EXISTS tarifications (
    id SERIAL PRIMARY KEY,
    nom TEXT NOT NULL,
    zone_min INTEGER NOT NULL,
    zone_max INTEGER NOT NULL,
    prix_centimes INTEGER NOT NULL);
ALTER TABLE abonnements ADD CONSTRAINT fk_abonnements_tarifications FOREIGN KEY (id_tarification) REFERENCES tarifications(id);

CREATE TYPE statut_dossier_client AS ENUM ('incomplet', 'validation', 'validé', 'rejeté');

CREATE TABLE IF NOT EXISTS dossiers_client (
    id SERIAL PRIMARY KEY,
    status statut_dossier_client,
    prenoms TEXT,
    nom_de_famille TEXT,
    date_naissance DATE,
    id_adresse_residence INTEGER,
    id_adresse_facturation INTEGER,
    email VARCHAR(128),
    tel VARCHAR(15),
    iban VARCHAR(34),
    bic VARCHAR(11),
    date_creation TIMESTAMP NOT NULL);
ALTER TABLE abonnements ADD CONSTRAINT fk_abonnements_dossiers FOREIGN KEY (id_dossier) REFERENCES dossiers_client(id);

CREATE TABLE IF NOT EXISTS adresses_client (
    id SERIAL PRIMARY KEY,
    ligne_1 TEXT NOT NULL,
    ligne_2 TEXT,
    ville VARCHAR(255),
    departement VARCHAR(255),
    code_postal VARCHAR(5),
    pays VARCHAR(255));
ALTER TABLE dossiers_client ADD CONSTRAINT fk_dossiers_client_adresses_residence FOREIGN KEY (id_adresse_residence) REFERENCES adresses_client(id);
ALTER TABLE dossiers_client ADD CONSTRAINT fk_dossiers_client_adresses_facturation FOREIGN KEY (id_adresse_facturation) REFERENCES adresses_client(id);

CREATE TABLE IF NOT EXISTS tickets (
    id SERIAL PRIMARY KEY,
    id_support INTEGER NOT NULL,
    date_achat TIMESTAMP NOT NULL,
    date_expiration TIMESTAMP NOT NULL,
    prix_unitaire_centimes INTEGER NOT NULL,
    id_station INTEGER NOT NULL,
    date_heure_validation TIMESTAMP);
ALTER TABLE tickets ADD CONSTRAINT fk_tickets_supports FOREIGN KEY (id_support) REFERENCES supports(id);
ALTER TABLE tickets ADD CONSTRAINT fk_tickets_stations FOREIGN KEY (id_station) REFERENCES stations(id);

CREATE TABLE IF NOT EXISTS validations (
    id SERIAL PRIMARY KEY,
    id_support INTEGER NOT NULL,
    id_station INTEGER NOT NULL,
    date_heure_validation TIMESTAMP NOT NULL);
ALTER TABLE validations ADD CONSTRAINT fk_validations_supports FOREIGN KEY (id_support) REFERENCES supports(id);
ALTER TABLE validations ADD CONSTRAINT fk_validations_stations FOREIGN KEY (id_station) REFERENCES stations(id);
