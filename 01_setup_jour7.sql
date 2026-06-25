-- ============================================================
--  JOUR 7 / 10 DAYS OF SQL — Setup : Fonctions de Dates
--  Table : commandes (avec dates de commande ET de livraison)
-- ============================================================

DROP TABLE IF EXISTS commandes;

CREATE TABLE commandes (
    id              INTEGER PRIMARY KEY,
    client          TEXT NOT NULL,
    date_commande   DATE NOT NULL,
    date_livraison  DATE,              -- peut être NULL si pas encore livrée
    montant         INTEGER NOT NULL,
    statut          TEXT NOT NULL
);

INSERT INTO commandes (id, client, date_commande, date_livraison, montant, statut) VALUES
(1,  'Dupont SA',      '2024-01-05', '2024-01-09',  3600, 'livree'),
(2,  'Martin Co',      '2024-01-07', '2024-01-12',   850, 'livree'),
(3,  'TechStart',      '2024-01-10', NULL,           120, 'annulee'),
(4,  'Innovation Lab', '2024-01-12', '2024-01-14',  7200, 'livree'),
(5,  'DataCorp',       '2024-01-15', NULL,           2400, 'en_cours'),
(6,  'NovaTech',       '2024-01-18', '2024-01-25',    45, 'livree'),
(7,  'Digital Hub',    '2024-01-20', '2024-01-23',  5800, 'livree'),
(8,  'SmartSol',       '2024-02-02', NULL,           1900, 'annulee'),
(9,  'WebAgency',      '2024-02-05', '2024-02-08',   320, 'livree'),
(10, 'Dupont SA',      '2024-02-08', '2024-02-19', 12000, 'livree'),
(11, 'Martin Co',      '2024-02-10', NULL,           680, 'en_cours'),
(12, 'TechStart',      '2024-02-13', '2024-02-16',  3200, 'livree'),
(13, 'Innovation Lab', '2024-02-15', '2024-02-17',    95, 'livree'),
(14, 'DataCorp',       '2024-02-20', '2024-02-22',  4500, 'livree'),
(15, 'NovaTech',       '2024-03-01', '2024-03-12',  8900, 'livree'),
(16, 'Digital Hub',    '2024-03-04', NULL,            210, 'annulee'),
(17, 'SmartSol',       '2024-03-07', NULL,           1500, 'en_cours'),
(18, 'WebAgency',      '2024-03-12', '2024-03-14',  6700, 'livree'),
(19, 'Dupont SA',      '2024-03-15', '2024-03-17',   380, 'livree'),
(20, 'Martin Co',      '2024-03-18', '2024-03-25',  2100, 'livree'),
(21, 'TechStart',      '2024-04-02', '2024-04-05',  9500, 'livree'),
(22, 'Innovation Lab', '2024-04-05', NULL,            150, 'annulee'),
(23, 'DataCorp',       '2024-04-10', '2024-04-13',  3300, 'livree'),
(24, 'NovaTech',       '2024-04-15', NULL,            720, 'en_cours'),
(25, 'Digital Hub',    '2024-04-18', '2024-04-30', 15000, 'livree');
