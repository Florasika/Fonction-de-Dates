-- ============================================================
--  JOUR 7 / 10 DAYS OF SQL — Fonctions de Dates
--  Concepts : strftime · julianday · date() · calcul de durée
--             extraction année/mois/jour · DATE arithmétique
-- ============================================================

-- ── 1. Extraire des parties d'une date avec strftime ────────
SELECT
    client,
    date_commande,
    strftime('%Y', date_commande) AS annee,
    strftime('%m', date_commande) AS mois,
    strftime('%d', date_commande) AS jour,
    strftime('%w', date_commande) AS jour_semaine_numero  -- 0=dimanche, 6=samedi
FROM commandes
LIMIT 5;

-- Codes strftime utiles :
-- %Y = année (2024)   %m = mois (01-12)   %d = jour (01-31)
-- %w = jour de semaine (0-6)   %H:%M:%S = heure


-- ── 2. Regrouper par année-mois (format YYYY-MM) ────────────
SELECT
    strftime('%Y-%m', date_commande) AS mois,
    COUNT(*) AS nb_commandes,
    SUM(montant) AS ca_mensuel
FROM commandes
GROUP BY mois
ORDER BY mois;


-- ── 3. julianday() : calculer un écart en jours ─────────────
-- Délai de livraison en jours pour chaque commande
SELECT
    client,
    date_commande,
    date_livraison,
    julianday(date_livraison) - julianday(date_commande) AS delai_jours
FROM commandes
WHERE date_livraison IS NOT NULL
ORDER BY delai_jours DESC;

-- julianday() convertit une date en nombre de jours depuis une référence
-- la SOUSTRACTION de deux julianday() donne directement l'écart en jours


-- ── 4. Délai moyen de livraison par client ───────────────────
SELECT
    client,
    COUNT(*) AS nb_livraisons,
    ROUND(AVG(julianday(date_livraison) - julianday(date_commande)), 1) AS delai_moyen_jours
FROM commandes
WHERE date_livraison IS NOT NULL
GROUP BY client
ORDER BY delai_moyen_jours DESC;


-- ── 5. Filtrer sur une période avec comparaison de dates ────
-- Commandes du premier trimestre 2024
SELECT client, date_commande, montant
FROM commandes
WHERE date_commande BETWEEN '2024-01-01' AND '2024-03-31'
ORDER BY date_commande;

-- Les dates au format 'YYYY-MM-DD' se comparent comme du texte
-- (fonctionne car le format ISO est trié naturellement)


-- ── 6. date('now') et calculs relatifs à aujourd'hui ────────
-- Commandes vieilles de plus de 30 jours et toujours en cours
SELECT
    client,
    date_commande,
    statut,
    CAST(julianday('now') - julianday(date_commande) AS INTEGER) AS jours_depuis_commande
FROM commandes
WHERE statut = 'en_cours';

-- date('now') = date du jour. 'now' peut être remplacé par
-- n'importe quelle date pour simuler "aujourd'hui" dans un test


-- ── 7. date() avec modificateurs : ajouter/soustraire du temps ─
-- Date limite de livraison = date de commande + 7 jours
SELECT
    client,
    date_commande,
    date(date_commande, '+7 days') AS date_limite_livraison,
    date_livraison,
    CASE
        WHEN date_livraison IS NULL THEN 'Pas encore livrée'
        WHEN date_livraison <= date(date_commande, '+7 days') THEN '✓ Dans les temps'
        ELSE '✗ En retard'
    END AS respect_delai
FROM commandes;

-- Modificateurs courants : '+N days', '-N days', '+N months',
-- 'start of month', 'start of year', 'weekday 0' (prochain dimanche)


-- ── 8. Extraire le jour de la semaine en texte ───────────────
SELECT
    client,
    date_commande,
    CASE strftime('%w', date_commande)
        WHEN '0' THEN 'Dimanche'
        WHEN '1' THEN 'Lundi'
        WHEN '2' THEN 'Mardi'
        WHEN '3' THEN 'Mercredi'
        WHEN '4' THEN 'Jeudi'
        WHEN '5' THEN 'Vendredi'
        WHEN '6' THEN 'Samedi'
    END AS jour_semaine
FROM commandes
ORDER BY date_commande
LIMIT 10;


-- ── 9. Nombre de commandes par jour de la semaine ───────────
-- Quel jour de la semaine reçoit le plus de commandes ?
SELECT
    CASE strftime('%w', date_commande)
        WHEN '0' THEN 'Dimanche' WHEN '1' THEN 'Lundi'
        WHEN '2' THEN 'Mardi'    WHEN '3' THEN 'Mercredi'
        WHEN '4' THEN 'Jeudi'    WHEN '5' THEN 'Vendredi'
        WHEN '6' THEN 'Samedi'
    END AS jour_semaine,
    COUNT(*) AS nb_commandes,
    SUM(montant) AS ca_total
FROM commandes
GROUP BY strftime('%w', date_commande)
ORDER BY nb_commandes DESC;


-- ── 10. Début et fin de mois avec 'start of' ─────────────────
SELECT
    client,
    date_commande,
    date(date_commande, 'start of month')            AS debut_mois,
    date(date_commande, 'start of month', '+1 month', '-1 day') AS fin_mois
FROM commandes
LIMIT 5;


-- ── 11. REQUÊTE COMPLÈTE — Rapport de performance livraison ──
WITH delais AS (
    SELECT
        client,
        date_commande,
        date_livraison,
        statut,
        CASE
            WHEN date_livraison IS NOT NULL
            THEN julianday(date_livraison) - julianday(date_commande)
            ELSE NULL
        END AS delai_jours
    FROM commandes
)
SELECT
    strftime('%Y-%m', date_commande) AS mois,
    COUNT(*) AS nb_commandes,
    SUM(CASE WHEN statut = 'livree' THEN 1 ELSE 0 END) AS nb_livrees,
    ROUND(AVG(delai_jours), 1) AS delai_moyen_jours,
    ROUND(
        100.0 * SUM(CASE WHEN delai_jours <= 7 THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN delai_jours IS NOT NULL THEN 1 ELSE 0 END), 0)
    , 1) AS pct_livraisons_dans_les_temps
FROM delais
GROUP BY mois
ORDER BY mois;
