/*nombre de dossiers incomplets*/
SELECT COUNT (*) AS nb_dossiers_incomplets
FROM dossiers_client
WHERE status ='incomplet';

/*stations desservies par chaque ligne*/

SELECT l.nom AS ligne,
        STRING_AGG(s.nom,', ' ORDER BY s.nom) AS stations 
FROM lignes AS l
JOIN arrets AS a ON l.id = a.id_ligne
JOIN stations AS s ON a.id_station = s.id
GROUP BY l.nom;

/*nombre de stations par moyen de transport*/
SELECT moyen_transport,
        COUNT(*) AS nb_stations
FROM stations
GROUP BY moyen_transport
GROUP BY nb_stations DESC;


/*abonnements qui expirent à la fin de janvier 2025*/



/*dossiers en validation*/