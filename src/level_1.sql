/*------------------------------------------------
1) Nombre de dossiers incomplets
   Renvoie le nombre de dossiers dont le status est 'incomplet'
   dans une colonne nommée nb_dossiers_incomplets.
------------------------------------------------*/
SELECT COUNT(*) AS nb_dossiers_incomplets
FROM dossiers_client
WHERE status = 'incomplet';


/*------------------------------------------------
2) Stations desservies par chaque ligne
   Affiche, pour chaque ligne (colonne "ligne"), la liste des stations qu'elle dessert (colonne "stations"),
   triées par ordre alphabétique.
------------------------------------------------*/
SELECT l.nom AS ligne,
       STRING_AGG(s.nom, ', ' ORDER BY s.nom) AS stations
FROM lignes AS l
JOIN arrets AS a ON l.id = a.id_ligne
JOIN stations AS s ON a.id_station = s.id
GROUP BY l.nom;


/*------------------------------------------------
3) Nombre de stations par moyen de transport
   Renvoie, pour chaque moyen de transport (stocké dans la colonne "type" de la table lignes),
   le nombre distinct de stations desservies (nb_stations).
   Les résultats sont triés du plus grand nombre au plus petit.
------------------------------------------------*/
SELECT l.type AS moyen_transport,
       COUNT(DISTINCT s.id) AS nb_stations
FROM lignes AS l
JOIN arrets AS a ON l.id = a.id_ligne
JOIN stations AS s ON a.id_station = s.id
GROUP BY l.type
ORDER BY nb_stations DESC;


/*------------------------------------------------
4) Abonnements qui expirent à la fin de janvier 2025
   Pour chaque tarification, compte le nombre d'abonnements dont la date de fin est comprise entre
   le 1er et le 31 janvier 2025.
   Le résultat comporte 2 colonnes : nom_tarification et nb_abonnements,
   trié du moins d'abonnements au plus.
------------------------------------------------*/
SELECT t.nom AS nom_tarification,
       COUNT(*) AS nb_abonnements
FROM abonnements AS a
JOIN tarifications AS t ON a.id_tarification = t.id
WHERE a.date_fin BETWEEN '2025-01-01' AND '2025-01-31'
GROUP BY t.nom
ORDER BY nb_abonnements ASC;


/*------------------------------------------------
5) Vue dossiers_en_validation
   Crée une vue qui renvoie toutes les informations des dossiers en validation (status = 'validation'),
   triés par date_creation du plus ancien au plus récent.
------------------------------------------------*/
CREATE OR REPLACE VIEW dossiers_en_validation AS
SELECT *
FROM dossiers_client
WHERE status = 'validation'
ORDER BY date_creation;
