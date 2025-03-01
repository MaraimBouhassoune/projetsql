/*parts des passagers ayant un abonnement, contre ceux voyageant avec des tickets (supports)*/
SELECT 
    ROUND(100.0 * SUM(CASE WHEN has_abonnement = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS part_abonnement,
    ROUND(100.0 * SUM(CASE WHEN has_ticket = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS part_ticket
FROM (
  SELECT s.id,
         CASE WHEN ab.id_support IS NOT NULL THEN 1 ELSE 0 END AS has_abonnement,
         CASE WHEN tk.id_support IS NOT NULL THEN 1 ELSE 0 END AS has_ticket
  FROM supports s
  LEFT JOIN (SELECT DISTINCT id_support FROM abonnements) ab ON s.id = ab.id_support
  LEFT JOIN (SELECT DISTINCT id_support FROM tickets) tk ON s.id = tk.id_support
  WHERE ab.id_support IS NOT NULL OR tk.id_support IS NOT NULL
) AS derived;


/*nombre de nouveaux abonnements par mois en 2024*/
SELECT mois, COUNT(*) AS nb_nvx_abo
FROM (
  SELECT id_support,
         MIN(date_debut) AS first_date,
         date_trunc('month', MIN(date_debut)) AS mois
  FROM abonnements
  WHERE date_debut >= '2024-01-01' AND date_debut < '2025-01-01'
  GROUP BY id_support
) AS sub
GROUP BY mois
ORDER BY mois;



/*montant total économisé par les usagers ayant un abonnement s'ils avaient dû acheter un ticket*/
SELECT 
  ROUND(
    SUM(
      GREATEST(COALESCE(vc.nb_validations, 0) * tkt.avg_ticket - t.prix_centimes, 0)
    ) / 100.0, 2
  ) AS montant_economise_euros
FROM abonnements a
JOIN tarifications t ON a.id_tarification = t.id
CROSS JOIN (
    SELECT AVG(prix_unitaire_centimes)::numeric AS avg_ticket
    FROM tickets
) tkt
LEFT JOIN (
    SELECT a_sub.id,
           COUNT(v.id) AS nb_validations
    FROM abonnements a_sub
    LEFT JOIN validations v 
      ON v.id_support = a_sub.id_support 
     AND v.date_heure_validation BETWEEN a_sub.date_debut AND a_sub.date_fin
    GROUP BY a_sub.id
) vc ON a.id = vc.id;



/*heure la plus affluante par station*/
CREATE OR REPLACE VIEW vue_heure_affluante_complete AS
SELECT nom_station, heure_affluante, nb_validations
FROM (
  SELECT nom_station, heure, nb_validations,
         ROW_NUMBER() OVER (PARTITION BY nom_station ORDER BY nb_validations DESC) AS rn,
         heure AS heure_affluante
  FROM (
    SELECT s.nom AS nom_station,
           date_trunc('hour', v.date_heure_validation) AS heure,
           COUNT(*) AS nb_validations
    FROM validations v
    JOIN stations s ON v.id_station = s.id
    GROUP BY s.nom, date_trunc('hour', v.date_heure_validation)
  ) AS inner_validations
) AS ranked
WHERE rn = 1;

SELECT nom_station, heure_affluante
FROM vue_heure_affluante_complete
ORDER BY nb_validations DESC;




/*nombre d'abonnements actifs par tranche de zone*/
CREATE OR REPLACE VIEW vue_abonnements_actifs_par_zone AS
SELECT t.zone_min, t.zone_max, COUNT(*) AS nb_abonnements
FROM abonnements a
JOIN tarifications t ON a.id_tarification = t.id
WHERE a.date_fin > CURRENT_TIMESTAMP
GROUP BY t.zone_min, t.zone_max
ORDER BY nb_abonnements DESC, t.zone_min, t.zone_max;

SELECT * FROM vue_abonnements_actifs_par_zone;
