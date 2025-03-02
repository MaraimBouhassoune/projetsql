# Projet SQL – Ratpi_DB

Ce projet met en place une base de données PostgreSQL configurée via Docker. Les scripts SQL (création de tables, insertion des données, requêtes et vues pour différents niveaux) se trouvent dans le dossier `./src/`.

## Installation

### 1. Cloner le dépôt

Ouvrez un terminal et exécutez :

```bash
git clone https://github.com/MaraimBouhassoune/projetsql

sudo apt update
```
### 2. Mettre à jour les paquets et installer le client PostgreSQL

```bash
### 2.
sudo apt install postgresql-client
```

### 3. Lancer l'environnement Docker
Utilisez Docker Compose pour démarrer le container :

```bash
docker-compose up -d
```

### 3. Connexion à la Base de Données
Pour vous connecter à la base de données ratpi_db, utilisez la commande suivante (le mot de passe est root) :

```
psql -h localhost -U root -d ratpi_db
```
```