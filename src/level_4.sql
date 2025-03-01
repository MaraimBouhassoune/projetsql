/*parts des passagers ayant un abonnement, contre ceux voyageant avec des tickets (supports)*/
SELECT
    ROUND(100.0 * SUM(CASE WHEN type = 'abonnement' THEN 1 ELSE 0 END) / COUNT(*), 2) AS part_abonnement,
    ROUND(100.0 * SUM(CASE WHEN type = 'ticket' THEN 1 ELSE 0 END) / COUNT(*), 2) AS part_ticket
FROM supports;

/*nombre de nouveaux abonnements par mois en 2024*/
WITH premier_abo AS (
    SELECT a.*,
           MIN(a.date_debut) OVER (PARTITION BY a.id_support) AS premier_date_debut
    FROM abonnements a
)
SELECT 
    TO_CHAR(date_debut, 'Month') AS mois,
    COUNT(*) AS nb_nvx_abo
FROM premier_abo
WHERE date_debut BETWEEN '2024-01-01' AND '2024-12-31'
  AND date_debut = premier_date_debut
GROUP BY TO_CHAR(date_debut, 'Month'), DATE_TRUNC('month', date_debut)
ORDER BY DATE_TRUNC('month', date_debut);



/*montant total économisé par les usagers ayant un abonnement s'ils avaient dû acheter un ticket*/


WITH validations_abos AS (
    -- Compter le nombre de validations réalisées par chaque abonnement
    SELECT id_abonnement, COUNT(*) AS nb_validations
    FROM validations
    WHERE id_abonnement IS NOT NULL
    GROUP BY id_abonnement
),
abo_cout AS (
    -- Pour chaque abonnement, on récupère le coût mensuel depuis tarifications et on estime un coût par validation.
    -- Ici, on suppose 30 validations par mois.
    SELECT a.id,
           t.prix_mensuel,
           t.prix_mensuel / 30.0 AS cout_par_validation
    FROM abonnements a
    JOIN tarifications t ON a.id_tarification = t.id
)
SELECT 
    SUM( GREATEST(2.00 - ac.cout_par_validation, 0) * va.nb_validations ) AS montant_economise_euros
FROM validations_abos va
JOIN abo_cout ac ON va.id_abonnement = ac.id;



/*heure la plus affluante par station*/

CREATE OR REPLACE VIEW heure_affluante AS
WITH validations_par_heure AS (
    SELECT s.nom AS nom_station,
           EXTRACT(HOUR FROM v.date_heure_validation) AS heure,
           COUNT(*) AS nb_validations
    FROM validations v
    JOIN stations s ON v.id_station = s.id
    GROUP BY s.nom, EXTRACT(HOUR FROM v.date_heure_validation)
),
max_validations AS (
    SELECT nom_station, MAX(nb_validations) AS max_validations
    FROM validations_par_heure
    GROUP BY nom_station
)
SELECT vph.nom_station,
       vph.heure AS heure_affluante
FROM validations_par_heure vph
JOIN max_validations mv ON vph.nom_station = mv.nom_station
   AND vph.nb_validations = mv.max_validations
ORDER BY mv.max_validations DESC;




/*nombre d'abonnements actifs par tranche de zone*/

-- Remarque : Cette requête suppose que la table dossiers_client contient une colonne "zone".
-- Et que chaque abonnement est lié à un dossier_client via une colonne id_dossier (à adapter selon votre schéma).

CREATE OR REPLACE VIEW heure_affluante AS
WITH validations_par_heure AS (
    SELECT s.nom AS nom_station,
           EXTRACT(HOUR FROM v.date_heure_validation) AS heure,
           COUNT(*) AS nb_validations
    FROM validations v
    JOIN stations s ON v.id_station = s.id
    GROUP BY s.nom, EXTRACT(HOUR FROM v.date_heure_validation)
),
max_validations AS (
    SELECT nom_station, MAX(nb_validations) AS max_validations
    FROM validations_par_heure
    GROUP BY nom_station
)
SELECT vph.nom_station,
       vph.heure AS heure_affluante
FROM validations_par_heure vph
JOIN max_validations mv ON vph.nom_station = mv.nom_station
   AND vph.nb_validations = mv.max_validations
ORDER BY mv.max_validations DESC;
