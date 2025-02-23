SELECT stations.nom
FROM stations
JOIN arret ON stations.id = arret.station_id
JOIN lignes ON arret.ligne_id = lignes.id
WHERE lignes.type IN ('Metro', 'RER')
GROUP BY stations.nom
HAVING COUNT(DISTINCT lignes.type) = 2
ORDER BY stations.nom;

SELECT tarifications.nom AS nom_forfait, COUNT(abonnements.id) AS nb_abonnements
FROM tarifications
JOIN abonnements ON tarifications.id = abonnements.tarification_id
GROUP BY tarifications.nom
ORDER BY nb_abonnements DESC
LIMIT 3;

SELECT stations.name AS station, SUM(capacite_max) / COUNT(DISTINCT lignes.id) AS capacite_moy
FROM stations
JOIN arrets ON stations.id = arrets.station_id
JOIN lignes ON arrets.ligne_id = lignes.id
GROUP BY stations.name
ORDER BY station;

CREATE VIEW abonnes_par_departement AS
SELECT adresses_client.departement AS departement, 
       adresses_client.code_postal, 
       COUNT(abonnements.id) AS nb_abonnes
FROM abonnements
JOIN dossiers_client ON abonnements.dossier_id = dossiers_client.id
JOIN adresses_client ON dossiers_client.id_adresse_residence = adresses_client.id
GROUP BY adresses_client.departement, adresses_client.code_postal
ORDER BY adresses_client.code_postal;

SELECT 
    COUNT(CASE WHEN date_naissance > CURRENT_DATE - INTERVAL '18 years' THEN 1 END) AS moins_18,
    COUNT(CASE WHEN date_naissance BETWEEN CURRENT_DATE - INTERVAL '24 years' AND CURRENT_DATE - INTERVAL '18 years' THEN 1 END) AS 18_24,
    COUNT(CASE WHEN date_naissance BETWEEN CURRENT_DATE - INTERVAL '40 years' AND CURRENT_DATE - INTERVAL '25 years' THEN 1 END) AS 25_40,
    COUNT(CASE WHEN date_naissance BETWEEN CURRENT_DATE - INTERVAL '60 years' AND CURRENT_DATE - INTERVAL '40 years' THEN 1 END) AS 40_60,
    COUNT(CASE WHEN date_naissance < CURRENT_DATE - INTERVAL '60 years' THEN 1 END) AS plus_60
FROM abonnements
JOIN dossiers_client ON abonnements.dossier_id = dossiers_client.id;

CREATE VIEW frequentation_stations AS
SELECT stations.nom AS station, 
       COUNT(validations.id) AS frequentation
FROM stations
JOIN validations ON stations.id = validations.station_id
GROUP BY stations.nom
ORDER BY frequentation DESC;

SELECT * FROM frequentation_stations LIMIT 10;
