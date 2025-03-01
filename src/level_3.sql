SELECT
    TO_CHAR(date_achat, 'Month') AS mois,
    SUM(prix_unitaire_centimes) / 100 AS chiffre_affaires
FROM tickets
WHERE EXTRACT(YEAR FROM date_achat) = 2024
GROUP BY TO_CHAR(date_achat, 'Month')
ORDER BY TO_DATE(TO_CHAR(date_achat, 'Month'), 'Month');

SELECT lignes.nom
FROM horaires
JOIN arrets ON horaires.id_arret = arrets.id
JOIN stations ON arrets.id_station = stations.id
JOIN lignes ON arrets.id_ligne = lignes.id
WHERE stations.nom = 'Nation'
AND horaires.horaire BETWEEN '17:24:16' AND '17:32:16'
ORDER BY horaires.horaire;


SELECT
    tarifications.nom AS abonnement,
    AVG(validations_count) AS moy_validation
FROM (
    SELECT id_support, COUNT(*) AS validations_count, DATE_TRUNC('month', date_heure_validation)
    FROM validations
    GROUP BY id_support, DATE_TRUNC('month', date_heure_validation)
) AS validations_grouped
JOIN abonnements ON validations_grouped.id_support = abonnements.id_support
JOIN tarifications ON abonnements.id_tarification = tarifications.id
GROUP BY tarifications.nom
ORDER BY moy_validation DESC, abonnement ASC;

CREATE VIEW moy_passages_par_jour AS
SELECT
    TO_CHAR(date_heure_validation, 'Day') AS jour_semaine,
    COUNT(*) / 52 AS moy_passagers
FROM validations
WHERE date_heure_validation >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY TO_CHAR(date_heure_validation, 'Day')
ORDER BY TO_CHAR(date_heure_validation, 'Day');

CREATE VIEW taux_remplissage AS
WITH trains_par_jour AS (
    SELECT
        id,
        nom,
        CASE
            WHEN type = 'metro' THEN (60 / 6) * 20
            WHEN type = 'rer' THEN (60 / 15) * 20
        END AS nb_trains_par_jour
    FROM lignes
), remplissage AS (
    SELECT
        arrets.id_ligne,
        AVG(COUNT(validations.id)) OVER (PARTITION BY arrets.id_ligne) / trains_par_jour.nb_trains_par_jour / lignes.capacite_max AS taux_remplissage
    FROM validations
    JOIN arrets ON validations.id_station = arrets.id_station
    JOIN lignes ON arrets.id_ligne = lignes.id
    JOIN trains_par_jour ON arrets.id_ligne = trains_par_jour.id
    GROUP BY arrets.id_ligne, trains_par_jour.nb_trains_par_jour, lignes.capacite_max
)
SELECT lignes.nom AS nom_ligne, remplissage.taux_remplissage * 100 AS taux_remplissage
FROM remplissage
JOIN lignes ON remplissage.id_ligne = lignes.id;
