# Librairie : 44 exercices SQL

Une chaîne de librairies imaginaire : des clients commandent des livres dans des boutiques, et les commandes sont livrées en une ou plusieurs fois. Base : [`base_librairie.sql`](base_librairie.sql). Version brute des requêtes : [`requetes_librairie.sql`](requetes_librairie.sql).

| Table | Contenu |
|---|---|
| `lib_client`, `lib_boutique` | clients, boutiques et leurs gérants |
| `lib_editeur`, `lib_livre` | éditeurs et catalogue (pages, genre, stock, prix d'achat et de vente) |
| `lib_commande`, `lib_ligne_cde` | commandes et leurs lignes |
| `lib_livraison`, `lib_ligne_liv` | livraisons et leurs lignes |

## 1. Projection et restriction

### Question 1

Nom, prénom, ville et pays de tous les clients, triés par nom puis par prénom.

```sql
SELECT cl_nom, cl_prenom, cl_ville, cl_pays
FROM   lib_client
ORDER BY cl_nom, cl_prenom;
```

*Résultat : 10 lignes*

### Question 2

Les différents genres de livres, sans doublon.

```sql
SELECT DISTINCT li_genre
FROM   lib_livre
ORDER BY li_genre;
```

*Résultat : 9 lignes*

### Question 3

Livres vendus entre 10 et 25 euros, du plus cher au moins cher.

```sql
SELECT li_numero, li_titre, li_genre, li_prix_vente
FROM   lib_livre
WHERE  li_prix_vente BETWEEN 10 AND 25
ORDER BY li_prix_vente DESC;
```

*Résultat : 9 lignes*

### Question 4

Livres dont le genre n'est pas renseigné.

```sql
SELECT *
FROM   lib_livre
WHERE  li_genre IS NULL;
```

*Résultat : 2 lignes*

### Question 5

Pour chaque livre : marge unitaire (prix de vente

- prix d'achat) et taux de marge en %. Trier par marge décroissante

```sql
SELECT li_numero,
       li_titre,
       li_prix_achat,
       li_prix_vente,
       li_prix_vente - li_prix_achat                                AS marge,
       ROUND((li_prix_vente - li_prix_achat) * 100 / li_prix_achat, 1) AS taux_marge
FROM   lib_livre
ORDER BY marge DESC;
```

*Résultat : 20 lignes*

Quand le prix d'achat est null, la marge est null : tout calcul avec null donne null.

### Question 6

Clients professionnels (type 'E') situés à CAEN ou à CHERBOURG.

```sql
SELECT *
FROM   lib_client
WHERE  cl_ville IN ('CAEN', 'CHERBOURG')
  AND  cl_type = 'E';
```

*Résultat : 2 lignes*

### Question 7

Livres dont le titre commence par 'C' et contient 'IN'.

```sql
SELECT *
FROM   lib_livre
WHERE  li_titre LIKE 'C%'
  AND  li_titre LIKE '%IN%';
```

*Résultat : 5 lignes*

## 2. Jointures

### Question 8

Livres du genre BD : titre, numéro, nombre de pages et nom de l'éditeur (deux écritures de la jointure).

```sql
SELECT l.li_titre, l.li_numero, l.li_pages, e.ed_nom
FROM   lib_livre l
JOIN   lib_editeur e ON e.ed_numero = l.ed_numero
WHERE  l.li_genre = 'BD'
ORDER BY l.li_numero;
```

*Résultat : 3 lignes*

```sql
SELECT li_titre, li_numero, li_pages, ed_nom
FROM   lib_livre
JOIN   lib_editeur USING (ed_numero)
WHERE  li_genre = 'BD'
ORDER BY li_numero;
```

*Résultat : 3 lignes*

### Question 9

Clients qui ont passé au moins une commande (sous-requête, puis jointure).

```sql
SELECT *
FROM   lib_client
WHERE  cl_numero IN (SELECT cl_numero FROM lib_commande)
ORDER BY cl_numero;
```

*Résultat : 8 lignes*

Avec une jointure, le DISTINCT est obligatoire : un client peut avoir plusieurs commandes.

```sql
SELECT DISTINCT c.*
FROM   lib_client c
JOIN   lib_commande co ON co.cl_numero = c.cl_numero
ORDER BY c.cl_numero;
```

*Résultat : 8 lignes*

### Question 10

Livres commandés par des clients de CAEN : n° de commande, client, livre et quantité commandée.

```sql
SELECT co.co_numero,
       c.cl_nom,
       l.li_numero,
       l.li_titre,
       lc.qte_cmdee
FROM   lib_livre l
JOIN   lib_ligne_cde lc ON lc.li_numero = l.li_numero
JOIN   lib_commande co  ON co.co_numero = lc.co_numero
JOIN   lib_client c     ON c.cl_numero = co.cl_numero
WHERE  c.cl_ville = 'CAEN'
ORDER BY co.co_numero, l.li_numero;
```

*Résultat : 14 lignes*

### Question 11

Tous les clients avec leurs numéros de commande, y compris ceux qui n'ont jamais commandé.

```sql
SELECT c.cl_numero, c.cl_nom, co.co_numero
FROM   lib_client c
LEFT JOIN lib_commande co ON co.cl_numero = c.cl_numero
ORDER BY c.cl_numero, co.co_numero;
```

*Résultat : 14 lignes*

### Question 12

Chaque commande avec sa boutique (ville, gérant) et son client.

```sql
SELECT co.co_numero,
       co.co_date,
       b.bo_ville,
       b.bo_nom_gerant,
       c.cl_nom
FROM   lib_commande co
JOIN   lib_boutique b ON b.bo_numero = co.bo_numero
JOIN   lib_client c   ON c.cl_numero = co.cl_numero
ORDER BY co.co_date;
```

*Résultat : 12 lignes*

### Question 13

Tous les éditeurs avec leurs livres, y compris les éditeurs sans livre au catalogue.

```sql
SELECT e.ed_numero, e.ed_nom, l.li_numero, l.li_titre
FROM   lib_editeur e
LEFT JOIN lib_livre l ON l.ed_numero = e.ed_numero
ORDER BY e.ed_numero, l.li_numero;
```

*Résultat : 21 lignes*

### Question 14

Auto-jointure : couples de livres différents qui portent le même titre (chaque couple une seule fois).

```sql
SELECT l1.li_numero,
       l2.li_numero AS li_numero_bis,
       l1.li_titre
FROM   lib_livre l1
JOIN   lib_livre l2 ON l2.li_titre = l1.li_titre
WHERE  l1.li_numero < l2.li_numero
ORDER BY l1.li_titre;
```

*Résultat : 2 lignes*

"<" plutôt que "<>" : avec "<>", chaque couple sortirait deux fois (L01-L02 et L02-L01).

### Question 15

Auto-jointure : gérants de boutique qui ont un homonyme.

```sql
SELECT DISTINCT b1.bo_nom_gerant, b1.bo_prenom_gerant, b1.bo_ville
FROM   lib_boutique b1
JOIN   lib_boutique b2 ON b2.bo_nom_gerant = b1.bo_nom_gerant
WHERE  b1.bo_numero <> b2.bo_numero
ORDER BY b1.bo_nom_gerant;
```

*Résultat : 2 lignes*

## 3. Opérateurs ensemblistes

### Question 16

Commandes qui n'ont pas encore été livrées (sous-requête, puis MINUS).

```sql
SELECT *
FROM   lib_commande
WHERE  co_numero NOT IN (SELECT co_numero FROM lib_livraison)
ORDER BY co_numero;
```

*Résultat : 4 lignes*

```sql
SELECT co_numero FROM lib_commande
MINUS
SELECT co_numero FROM lib_livraison;
```

*Résultat : 4 lignes*

### Question 17

Villes où l'on trouve à la fois un client et une boutique.

```sql
SELECT cl_ville AS ville FROM lib_client
INTERSECT
SELECT bo_ville FROM lib_boutique;
```

*Résultat : 3 lignes*

### Question 18

Toutes les villes connues (clients et boutiques), sans doublon puis avec.

```sql
SELECT cl_ville AS ville FROM lib_client
UNION
SELECT bo_ville FROM lib_boutique;
```

*Résultat : 8 lignes*

```sql
SELECT cl_ville AS ville FROM lib_client
UNION ALL
SELECT bo_ville FROM lib_boutique;
```

*Résultat : 14 lignes*

## 4. Vues

### Question 19

Créer deux vues livres + éditeurs : v_livre_editeur1 prend ed_numero dans lib_livre (colonne modifiable), v_livre_editeur2 le prend dans lib_editeur (colonne non modifiable).

```sql
CREATE OR REPLACE VIEW v_livre_editeur1 AS
SELECT e.ed_nom, l.ed_numero, l.li_numero, l.li_titre, l.li_genre, l.li_stock, l.li_prix_vente
FROM   lib_livre l
JOIN   lib_editeur e ON e.ed_numero = l.ed_numero;

CREATE OR REPLACE VIEW v_livre_editeur2 AS
SELECT e.ed_nom, e.ed_numero, l.li_numero, l.li_titre, l.li_genre, l.li_stock, l.li_prix_vente
FROM   lib_livre l
JOIN   lib_editeur e ON e.ed_numero = l.ed_numero;

SELECT * FROM v_livre_editeur1 ORDER BY li_numero;
```

*Résultat : 20 lignes*

Colonnes modifiables de chaque vue (dictionnaire Oracle)

```sql
SELECT table_name, column_name, updatable, insertable, deletable
FROM   user_updatable_columns
WHERE  table_name LIKE 'V_LIVRE_EDITEUR%'
  AND  column_name LIKE '%NUMERO%';
```

ed_numero est modifiable dans la vue 1 (il vient de lib_livre, la table « préservée par clé ») et pas dans la vue 2 (il vient de lib_editeur).

### Question 20

Avec v_livre_editeur1 : les livres de l'éditeur ATLAS VOYAGES.

```sql
SELECT li_numero, li_titre, li_genre, li_prix_vente
FROM   v_livre_editeur1
WHERE  ed_nom = 'ATLAS VOYAGES'
ORDER BY li_numero;
```

*Résultat : 3 lignes*

## 5. Sous-requêtes

### Question 21

Livres achetés plus cher que le livre L04.

```sql
SELECT *
FROM   lib_livre
WHERE  li_prix_achat > (SELECT li_prix_achat FROM lib_livre WHERE li_numero = 'L04')
ORDER BY li_prix_achat;
```

*Résultat : 3 lignes*

### Question 22

Livres qui n'ont jamais été commandés.

```sql
SELECT *
FROM   lib_livre
WHERE  li_numero NOT IN (SELECT li_numero FROM lib_ligne_cde)
ORDER BY li_numero;
```

*Résultat : 2 lignes*

### Question 23

Livres qui ont moins de pages que le livre L07 (sous-requête, puis auto-jointure).

```sql
SELECT *
FROM   lib_livre
WHERE  li_pages < (SELECT li_pages FROM lib_livre WHERE li_numero = 'L07')
ORDER BY li_pages;
```

*Résultat : 1 ligne*

```sql
SELECT l1.*
FROM   lib_livre l1
JOIN   lib_livre l2 ON l1.li_pages < l2.li_pages
WHERE  l2.li_numero = 'L07'
ORDER BY l1.li_pages;
```

*Résultat : 1 ligne*

### Question 24

Livre(s) le(s) plus cher(s) à la vente, sans fonction d'agrégat.

```sql
SELECT *
FROM   lib_livre
WHERE  li_prix_vente >= ALL (SELECT li_prix_vente FROM lib_livre);
```

*Résultat : 1 ligne*

### Question 25

Clients qui ont commandé au moins un livre de l'éditeur BULLES ET CASES (sous-requêtes imbriquées, aucune jointure).

```sql
SELECT *
FROM   lib_client
WHERE  cl_numero IN (
         SELECT cl_numero
         FROM   lib_commande
         WHERE  co_numero IN (
                  SELECT co_numero
                  FROM   lib_ligne_cde
                  WHERE  li_numero IN (
                           SELECT li_numero
                           FROM   lib_livre
                           WHERE  ed_numero IN (
                                    SELECT ed_numero
                                    FROM   lib_editeur
                                    WHERE  ed_nom = 'BULLES ET CASES'
                                  )
                         )
                )
       )
ORDER BY cl_numero;
```

*Résultat : 4 lignes*

### Question 26

Requête synchronisée : clients qui n'ont passé aucune commande (NOT EXISTS).

```sql
SELECT *
FROM   lib_client c
WHERE  NOT EXISTS (
         SELECT *
         FROM   lib_commande co
         WHERE  co.cl_numero = c.cl_numero
       );
```

*Résultat : 2 lignes*

### Question 27

Requête synchronisée : pour chaque éditeur, son ou ses livres les plus épais.

```sql
SELECT ed_numero, li_numero, li_titre, li_pages
FROM   lib_livre l1
WHERE  li_pages = (
         SELECT MAX(li_pages)
         FROM   lib_livre l2
         WHERE  l2.ed_numero = l1.ed_numero
       )
ORDER BY ed_numero;
```

*Résultat : 6 lignes*

## 6. Expressions et fonctions

### Question 28

Livres avec leur genre en clair ('non classé' si vide, avec NVL) et une catégorie de prix (CASE) : moins de 5 euros 'petit prix', moins de 20 'moyen', sinon 'cher'.

```sql
SELECT li_numero,
       li_titre,
       NVL(li_genre, 'non classé') AS genre,
       CASE
         WHEN li_prix_vente < 5  THEN 'petit prix'
         WHEN li_prix_vente < 20 THEN 'moyen'
         ELSE 'cher'
       END AS categorie
FROM   lib_livre
ORDER BY li_numero;
```

*Résultat : 20 lignes*

### Question 29

Pour chaque commande : la date au format JJ/MM/AAAA, le nom du mois et le nombre de jours écoulés depuis.

```sql
SELECT co_numero,
       TO_CHAR(co_date, 'DD/MM/YYYY') AS date_commande,
       TO_CHAR(co_date, 'month')      AS mois,
       TRUNC(SYSDATE - co_date)       AS jours_ecoules
FROM   lib_commande
ORDER BY co_date;
```

*Résultat : 12 lignes*

### Question 30

Commandes du premier semestre 2025.

```sql
SELECT *
FROM   lib_commande
WHERE  co_date BETWEEN TO_DATE('01/01/2025', 'DD/MM/YYYY')
                   AND TO_DATE('30/06/2025', 'DD/MM/YYYY')
ORDER BY co_date;
```

*Résultat : 10 lignes*

### Question 31

Délai de livraison (en jours) de chaque commande livrée, du plus long au plus court.

```sql
SELECT co.co_numero,
       co.co_date,
       lv.date_liv,
       lv.date_liv - co.co_date AS delai_jours
FROM   lib_commande co
JOIN   lib_livraison lv ON lv.co_numero = co.co_numero
ORDER BY delai_jours DESC;
```

*Résultat : 8 lignes*

### Question 32

Nom complet des clients dans une seule colonne : prénom puis nom en majuscules.

```sql
SELECT cl_prenom || ' ' || UPPER(cl_nom) AS client
FROM   lib_client
ORDER BY cl_nom;
```

*Résultat : 10 lignes*

## 7. Regroupements et fonctions d'agrégat

### Question 33

Nombre de livres par genre, avec une ligne TOTAL (ROLLUP). Les livres sans genre ne sont pas comptés.

```sql
SELECT NVL(li_genre, 'TOTAL') AS genre,
       COUNT(*)               AS nb_livres
FROM   lib_livre
WHERE  li_genre IS NOT NULL
GROUP BY ROLLUP (li_genre);
```

*Résultat : 9 lignes*

### Question 34

Nombre de livres, prix de vente moyen, minimum et maximum.

```sql
SELECT COUNT(*)                   AS nb_livres,
       ROUND(AVG(li_prix_vente), 2) AS prix_moyen,
       MIN(li_prix_vente)         AS prix_mini,
       MAX(li_prix_vente)         AS prix_maxi
FROM   lib_livre;
```

*Résultat : 1 ligne*

### Question 35

Compter les livres, les livres dont le prix d'achat est connu, et les éditeurs distincts. D'où vient la différence ?

```sql
SELECT COUNT(*)                  AS nb_livres,
       COUNT(li_prix_achat)      AS nb_avec_prix_achat,
       COUNT(DISTINCT ed_numero) AS nb_editeurs
FROM   lib_livre;
```

*Résultat : 1 ligne*

COUNT(*) compte les lignes, COUNT(colonne) ignore les valeurs null.

### Question 36

Nombre de commandes de chaque client, y compris ceux qui n'en ont aucune.

```sql
SELECT c.cl_numero,
       c.cl_nom,
       COUNT(co.co_numero) AS nb_commandes
FROM   lib_client c
LEFT JOIN lib_commande co ON co.cl_numero = c.cl_numero
GROUP BY c.cl_numero, c.cl_nom
ORDER BY nb_commandes DESC, c.cl_numero;
```

*Résultat : 10 lignes*

COUNT(co.co_numero) et pas COUNT(*) : sinon un client sans commande compterait 1.

### Question 37

Montant de chaque commande (quantité commandée x prix unitaire).

```sql
SELECT co_numero,
       SUM(qte_cmdee * prix_unitaire) AS montant
FROM   lib_ligne_cde
GROUP BY co_numero
ORDER BY montant DESC;
```

*Résultat : 12 lignes*

### Question 38

Clients qui ont commandé pour plus de 200 euros au total.

```sql
SELECT c.cl_numero,
       c.cl_nom,
       SUM(lc.qte_cmdee * lc.prix_unitaire) AS total_commande
FROM   lib_client c
JOIN   lib_commande co   ON co.cl_numero = c.cl_numero
JOIN   lib_ligne_cde lc  ON lc.co_numero = co.co_numero
GROUP BY c.cl_numero, c.cl_nom
HAVING SUM(lc.qte_cmdee * lc.prix_unitaire) > 200
ORDER BY total_commande DESC;
```

*Résultat : 4 lignes*

### Question 39

Pour chaque boutique : nombre de commandes et chiffre d'affaires.

```sql
SELECT b.bo_numero,
       b.bo_ville,
       COUNT(DISTINCT co.co_numero)         AS nb_commandes,
       SUM(lc.qte_cmdee * lc.prix_unitaire) AS chiffre_affaires
FROM   lib_boutique b
JOIN   lib_commande co  ON co.bo_numero = b.bo_numero
JOIN   lib_ligne_cde lc ON lc.co_numero = co.co_numero
GROUP BY b.bo_numero, b.bo_ville
ORDER BY chiffre_affaires DESC;
```

*Résultat : 4 lignes*

### Question 40

Le ou les livres les plus commandés (en quantité totale).

```sql
SELECT l.li_numero,
       l.li_titre,
       SUM(lc.qte_cmdee) AS qte_totale
FROM   lib_livre l
JOIN   lib_ligne_cde lc ON lc.li_numero = l.li_numero
GROUP BY l.li_numero, l.li_titre
HAVING SUM(lc.qte_cmdee) = (
         SELECT MAX(SUM(qte_cmdee))
         FROM   lib_ligne_cde
         GROUP BY li_numero
       );
```

*Résultat : 1 ligne*

### Question 41

Lignes de commande pas entièrement livrées, avec le reste à livrer.

```sql
SELECT co_numero,
       li_numero,
       qte_cmdee,
       qte_livree,
       qte_cmdee - qte_livree AS reste_a_livrer
FROM   lib_ligne_cde
WHERE  qte_livree < qte_cmdee
ORDER BY co_numero, li_numero;
```

*Résultat : 8 lignes*

## 8. Mises à jour

### Question 42

Ajouter un livre avec toutes ses colonnes, puis un autre avec seulement les colonnes obligatoires, puis réinsérer le premier (erreur de clé primaire).

```sql
INSERT INTO lib_livre (li_numero, ed_numero, li_titre, li_pages, li_genre, li_stock, li_prix_achat, li_prix_vente)
VALUES ('L21', 'E02', 'LE VENT DU LARGE', 250, 'ROMAN', 10, 8.00, 17.50);

INSERT INTO lib_livre (li_numero, ed_numero, li_titre)
VALUES ('L22', 'E02', 'LE VENT DU LARGE');
```

Erreur attendue : ORA-00001, contrainte unique (PK_LIB_LIVRE) violée

```sql
INSERT INTO lib_livre (li_numero, ed_numero, li_titre, li_pages, li_genre, li_stock, li_prix_achat, li_prix_vente)
VALUES ('L21', 'E02', 'LE VENT DU LARGE', 250, 'ROMAN', 10, 8.00, 17.50);

SELECT *
FROM   lib_livre
WHERE  li_numero IN ('L21', 'L22');
```

*Résultat : 2 lignes*

### Question 43

Augmenter de 5 % le prix de vente des livres de l'éditeur E02.

```sql
UPDATE lib_livre
SET    li_prix_vente = ROUND(li_prix_vente * 1.05, 2)
WHERE  ed_numero = 'E02';
```

### Question 44

Supprimer les livres ajoutés en 42, puis annuler toutes les modifications depuis le dernier COMMIT.

```sql
DELETE FROM lib_livre
WHERE  li_numero IN ('L21', 'L22');

ROLLBACK;
```
