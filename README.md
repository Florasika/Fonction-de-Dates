# 📅 Jour 7 / 10 — SQL : Fonctions de Dates

> **Série : 10 Days of SQL** · Jour 7/10  
> Concepts : strftime · julianday · date() avec modificateurs · calcul de délais

---

## 📁 Structure du projet

```
day-07-date-functions/
│
├── 01_setup.sql            ← CREATE TABLE commandes + 25 lignes (avec NULL volontaires)
├── 02_dates.sql             ← 11 requêtes commentées
├── commandes_dates.db       ← Base SQLite prête à l'emploi
└── README.md
```

---

## 🚀 Installation & Lancement

```bash
# Cloner le repo
git clone https://github.com/ton-pseudo/10-days-sql.git
cd 10-days-sql/day-07-date-functions

# Ouvrir la base directement (déjà créée)
sqlite3 commandes_dates.db

# OU recréer la base depuis zéro
sqlite3 commandes_dates.db < 01_setup.sql

# Exécuter toutes les requêtes
sqlite3 commandes_dates.db < 02_dates.sql
```

⚠️ Les fonctions de dates **diffèrent selon le SGBD** :
- **SQLite** : `strftime()`, `julianday()`, `date()` — celles utilisées ici
- **PostgreSQL** : `EXTRACT()`, `AGE()`, `date_trunc()`
- **MySQL** : `DATE_FORMAT()`, `DATEDIFF()`, `DATE_ADD()`

La logique reste la même, seule la syntaxe change.

---

## 📊 Le schéma — table `commandes`

| Colonne | Type | Description |
|---------|------|--------------|
| `id` | INTEGER | Clé primaire |
| `client` | TEXT | 9 entreprises clientes |
| `date_commande` | DATE | Format YYYY-MM-DD |
| `date_livraison` | DATE | **NULL** si pas encore livrée ou annulée |
| `montant` | INTEGER | Montant en euros |
| `statut` | TEXT | 'livree', 'en_cours', 'annulee' |

25 commandes sur 4 mois, avec des `date_livraison` volontairement `NULL` pour les commandes annulées ou en cours — indispensable pour pratiquer les calculs de délai sans erreur.

---

## 🔑 1. strftime() — extraire une partie de date

```sql
SELECT
    strftime('%Y', date_commande) AS annee,
    strftime('%m', date_commande) AS mois,
    strftime('%Y-%m', date_commande) AS annee_mois
FROM commandes;
```

| Code | Signification |
|------|---------------|
| `%Y` | Année (2024) |
| `%m` | Mois (01-12) |
| `%d` | Jour (01-31) |
| `%w` | Jour de semaine (0=dimanche … 6=samedi) |
| `%H:%M:%S` | Heure:Minute:Seconde |

### Grouper par mois
```sql
SELECT strftime('%Y-%m', date_commande) AS mois,
       SUM(montant) AS ca_mensuel
FROM commandes
GROUP BY mois;
```

---

## 🔑 2. julianday() — calculer un écart en jours

```sql
SELECT client, date_commande, date_livraison,
    julianday(date_livraison) - julianday(date_commande) AS delai_jours
FROM commandes
WHERE date_livraison IS NOT NULL;
```
`julianday()` convertit une date en nombre (jours écoulés depuis une référence astronomique). La **soustraction** de deux `julianday()` donne directement l'écart en jours.

⚠️ Toujours filtrer `WHERE date_livraison IS NOT NULL` avant de calculer, sinon le résultat est `NULL` pour les commandes non livrées.

---

## 🔑 3. date() avec modificateurs — ajouter/soustraire du temps

```sql
-- Date limite = commande + 7 jours
SELECT date_commande,
    date(date_commande, '+7 days') AS limite
FROM commandes;
```

| Modificateur | Effet |
|---|---|
| `'+N days'` / `'-N days'` | Ajoute/soustrait N jours |
| `'+N months'` | Ajoute N mois |
| `'start of month'` | Ramène au 1er jour du mois |
| `'start of year'` | Ramène au 1er janvier |

### Combiner plusieurs modificateurs — fin de mois
```sql
date(date_commande, 'start of month', '+1 month', '-1 day')
```
Logique : 1er jour du mois → +1 mois → -1 jour = dernier jour du mois actuel.

---

## 🔑 4. date('now') — calculs relatifs à aujourd'hui

```sql
SELECT client, date_commande,
    CAST(julianday('now') - julianday(date_commande) AS INTEGER) AS jours_ecoules
FROM commandes
WHERE statut = 'en_cours';
```
`'now'` peut être remplacé par n'importe quelle date pour simuler "aujourd'hui" dans un test (`julianday('2024-06-01')`).

---

## 🔑 5. Jour de la semaine en texte (CASE + strftime)

```sql
SELECT date_commande,
    CASE strftime('%w', date_commande)
        WHEN '0' THEN 'Dimanche'
        WHEN '1' THEN 'Lundi'
        -- ...
        WHEN '6' THEN 'Samedi'
    END AS jour_semaine
FROM commandes;
```
`%w` renvoie un chiffre — on le combine avec `CASE` (vu au Jour 6) pour un libellé lisible.

---

## 🔑 6. Indicateur métier complet — respect des délais

```sql
SELECT client, date_commande, date_livraison,
    CASE
        WHEN date_livraison IS NULL THEN 'Pas encore livrée'
        WHEN date_livraison <= date(date_commande, '+7 days')
            THEN '✓ Dans les temps'
        ELSE '✗ En retard'
    END AS respect_delai
FROM commandes;
```
Combine `date()`, `CASE` et `IS NULL` pour un indicateur métier complet en une seule requête.

---

## 🧠 Comparer des dates comme du texte

```sql
WHERE date_commande BETWEEN '2024-01-01' AND '2024-03-31'
```
Les dates au format ISO (`YYYY-MM-DD`) se comparent **directement comme du texte**, car ce format se trie naturellement dans le bon ordre chronologique. Pas besoin de fonction de conversion pour un simple filtre de période.

---

## 💡 Quand utiliser quoi ?

| Besoin | Fonction |
|---|---|
| Extraire année/mois/jour | `strftime('%Y'/'%m'/'%d', date)` |
| Calculer un écart en jours | `julianday(date2) - julianday(date1)` |
| Ajouter/soustraire du temps | `date(date, '+N days')` |
| Filtrer une période | `WHERE date BETWEEN '...' AND '...'` |
| Comparer à aujourd'hui | `date('now')` ou `julianday('now')` |
| Grouper par mois | `strftime('%Y-%m', date)` |

---

---

⭐ **Si ce projet t'aide, mets une étoile !**
