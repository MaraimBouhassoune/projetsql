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




/*heure la plus affluante par station*/




/*nombre d'abonnements actifs par tranche de zone*/