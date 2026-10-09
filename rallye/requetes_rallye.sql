-- =============================================================================
--  RALLYE DES SABLES : 67 exercices SQL (Oracle)
--  Base : base_rallye.sql (rallye-raid imaginaire, éditions 1988 à 2025)
--  Sous chaque requête : le nombre de lignes obtenues sur cette base.
-- =============================================================================


-- =============================================================================
--  1. Projection et restriction
-- =============================================================================

/* 1) Lister les étapes numérotées de 5 à 10, toutes éditions confondues.
      Afficher le n° d'étape, la ville de départ, la ville d'arrivée et les km. */
SELECT n_etape, ville_depart, ville_arrivee, km
FROM   ral_etape
WHERE  n_etape BETWEEN 5 AND 10
ORDER BY annee, n_etape;
-- 11 lignes

/* 2) Même liste, uniquement pour l'édition 2025. */
SELECT n_etape, ville_depart, ville_arrivee, km
FROM   ral_etape
WHERE  n_etape BETWEEN 5 AND 10
  AND  annee = 2025
ORDER BY n_etape;
-- 6 lignes

/* 3) Étapes de l'édition 2025 dont le numéro est inférieur à 5 ou supérieur à 10
      (deux solutions). */
-- Solution 1 : OR
SELECT n_etape, ville_depart, ville_arrivee, km
FROM   ral_etape
WHERE  (n_etape < 5 OR n_etape > 10)
  AND  annee = 2025
ORDER BY n_etape;
-- 15 lignes

-- Solution 2 : NOT BETWEEN
SELECT n_etape, ville_depart, ville_arrivee, km
FROM   ral_etape
WHERE  n_etape NOT BETWEEN 5 AND 10
  AND  annee = 2025
ORDER BY n_etape;
-- 15 lignes

/* 4) Lister tous les prologues (type 'PRL') : pays et villes de départ et d'arrivée,
      km, vitesse moyenne, année et type. Du plus court au plus long. */
SELECT pays_depart,
       pays_arrivee,
       ville_depart,
       ville_arrivee,
       km,
       vitesse_moy,
       annee,
       code_type
FROM   ral_etape
WHERE  code_type = 'PRL'
ORDER BY km;
-- 2 lignes

/* 5) En une seule requête, lister les étapes dont la ville de départ :
        - commence par 'M',
        - ou se termine par 'A',
        - ou contient 'OU'. */
SELECT *
FROM   ral_etape
WHERE  ville_depart LIKE 'M%'
   OR  ville_depart LIKE '%A'
   OR  ville_depart LIKE '%OU%'
ORDER BY annee, n_etape;
-- 26 lignes

/* 6) Quelle étape a été courue le 14 juillet 2025 ? */
SELECT *
FROM   ral_etape
WHERE  date_etape = TO_DATE('14/07/2025', 'DD/MM/YYYY');
-- 1 ligne

/* 7) Pilotes qui ont fait leurs débuts sur le rallye en 2025 : prénom, nom et âge à
      leurs débuts, du plus jeune au plus âgé. */
SELECT prenom,
       nom,
       annee_debut - annee_naissance AS age
FROM   ral_pilote
WHERE  annee_debut = 2025
ORDER BY age;
-- 4 lignes

/* 8) Sponsors apparus après 1990 qui n'ont pas de sigle. */
SELECT *
FROM   ral_sponsor
WHERE  sigle IS NULL
  AND  annee_sponsor > 1990;
-- 8 lignes

/* 9) Pilotes dont le nom commence par 'M', triés par prénom (A à Z) puis par nom
      (Z à A). */
SELECT *
FROM   ral_pilote
WHERE  nom LIKE 'M%'
ORDER BY prenom ASC, nom DESC;
-- 6 lignes

/* 10) Lignes de ral_nationalite pour les pays SUI, JPN et POL. */
SELECT *
FROM   ral_nationalite
WHERE  code_pays IN ('SUI', 'JPN', 'POL');
-- 5 lignes


-- =============================================================================
--  2. Jointures
-- =============================================================================

/* 11) Pilotes engagés en 2025 : nom, prénom, n° de voiture, n° d'écurie et n° de
       pilote. Écrire la jointure de trois façons. */
-- Méthode 1 : jointure dans le WHERE (SQL1)
SELECT p.nom, p.prenom, e.n_voiture, e.n_ecurie, p.n_pilote
FROM   ral_pilote p, ral_engagement e
WHERE  p.n_pilote = e.n_pilote
  AND  e.annee = 2025
ORDER BY e.n_voiture;
-- 24 lignes

-- Méthode 2 : JOIN ... ON
SELECT p.nom, p.prenom, e.n_voiture, e.n_ecurie, p.n_pilote
FROM   ral_pilote p
JOIN   ral_engagement e ON e.n_pilote = p.n_pilote
WHERE  e.annee = 2025
ORDER BY e.n_voiture;
-- 24 lignes

-- Méthode 3 : JOIN ... USING
SELECT nom, prenom, n_voiture, n_ecurie, n_pilote
FROM   ral_pilote
JOIN   ral_engagement USING (n_pilote)
WHERE  annee = 2025
ORDER BY n_voiture;
-- 24 lignes

/* 11bis) Même requête, limitée aux voitures n° 1 à 9. Expliquer le nombre de lignes. */
SELECT p.nom, p.prenom, e.n_voiture, e.n_ecurie, p.n_pilote
FROM   ral_pilote p
JOIN   ral_engagement e ON e.n_pilote = p.n_pilote
WHERE  e.annee = 2025
  AND  e.n_voiture BETWEEN 1 AND 9
ORDER BY e.n_voiture;
-- 4 lignes
-- Les numéros vont par dizaine : 1 à 4 pour la 1re écurie, 11 à 14 pour la 2e, etc.
-- Entre 1 et 9, on ne trouve donc que les 4 pilotes de la première écurie.

/* 11ter) Même requête, avec en plus le nom du sponsor. */
SELECT p.nom, p.prenom, e.n_voiture, e.n_ecurie, p.n_pilote, s.nom AS sponsor
FROM   ral_pilote p
JOIN   ral_engagement e ON e.n_pilote = p.n_pilote
JOIN   ral_sponsor s    ON s.n_ecurie = e.n_ecurie AND s.n_sponsor = e.n_sponsor
WHERE  e.annee = 2025
  AND  e.n_voiture BETWEEN 1 AND 9
ORDER BY e.n_voiture;
-- 4 lignes
-- La jointure avec le sponsor se fait sur toute sa clé (n_ecurie, n_sponsor).
-- Avec n_ecurie seul, on aurait une ligne par sponsor qu'a connu l'écurie.

/* 12) Pilotes dont la voiture porte un n° entre 28 et 49 et dont le nom contient
       'ZI' ou 'IZ' : nom, prénom, écurie, sponsor et année, triés par année. */
SELECT p.nom, p.prenom, e.n_ecurie, e.n_sponsor, e.annee
FROM   ral_pilote p
JOIN   ral_engagement e ON e.n_pilote = p.n_pilote
WHERE  e.n_voiture BETWEEN 28 AND 49
  AND  (p.nom LIKE '%ZI%' OR p.nom LIKE '%IZ%')
ORDER BY e.annee;
-- 7 lignes

/* 13) Pilotes « espoirs » (25 ans ou moins) de l'édition 2025 : nom, prénom, n° de
       sponsor et n° d'écurie, triés par nom. */
SELECT p.nom, p.prenom, e.n_sponsor, e.n_ecurie
FROM   ral_pilote p
JOIN   ral_engagement e ON e.n_pilote = p.n_pilote
WHERE  e.annee = 2025
  AND  e.espoir = 'o'
ORDER BY p.nom;
-- 7 lignes

/* 13bis) Mêmes pilotes avec le nom de leur sponsor, triés par sponsor puis par nom. */
SELECT p.nom, p.prenom, s.nom AS sponsor
FROM   ral_pilote p
JOIN   ral_engagement e ON e.n_pilote = p.n_pilote
JOIN   ral_sponsor s    ON s.n_ecurie = e.n_ecurie AND s.n_sponsor = e.n_sponsor
WHERE  e.annee = 2025
  AND  e.espoir = 'o'
ORDER BY s.nom, p.nom;
-- 7 lignes

/* 14) Tous les pilotes de 2025 (prénom, nom) avec, pour ceux qui ont abandonné, le
       motif de l'abandon. Les pilotes arrivés au bout doivent aussi apparaître. */
SELECT p.prenom, p.nom, a.code_abandon, t.libelle
FROM   ral_pilote p
JOIN   ral_engagement e        ON e.n_pilote = p.n_pilote
LEFT JOIN ral_abandon a        ON a.n_pilote = e.n_pilote AND a.annee = e.annee
LEFT JOIN ral_type_abandon t   ON t.code_abandon = a.code_abandon
WHERE  e.annee = 2025
ORDER BY p.nom, p.prenom;
-- 24 lignes
-- Le filtre sur l'année porte sur e.annee. Avec "a.annee = 2025" dans le WHERE, les
-- pilotes sans abandon (a.annee vaut null) disparaîtraient.

/* 15) Pilotes qui ont un homonyme (même nom de famille), triés par nom et prénom. */
SELECT DISTINCT p1.nom, p1.prenom
FROM   ral_pilote p1
JOIN   ral_pilote p2 ON p2.nom = p1.nom
WHERE  p1.n_pilote <> p2.n_pilote
ORDER BY p1.nom, p1.prenom;
-- 3 lignes

/* 16) Étapes arrivant dans une ville qui a accueilli plusieurs arrivées : n° d'étape,
       suffixe, ville de départ, ville d'arrivée et année. */
SELECT DISTINCT e1.n_etape, e1.suffixe, e1.ville_depart, e1.ville_arrivee, e1.annee
FROM   ral_etape e1
JOIN   ral_etape e2 ON e2.ville_arrivee = e1.ville_arrivee
WHERE  e1.annee   <> e2.annee
   OR  e1.n_etape <> e2.n_etape
   OR  e1.suffixe <> e2.suffixe
ORDER BY e1.ville_arrivee, e1.annee, e1.n_etape;
-- 29 lignes
-- Une étape est identifiée par (annee, n_etape, suffixe) : il suffit qu'une des trois
-- colonnes diffère pour ne pas comparer une étape avec elle-même.

/* 16bis) Même question sans afficher l'année. Pourquoi obtient-on moins de lignes ? */
SELECT DISTINCT e1.n_etape, e1.suffixe, e1.ville_depart, e1.ville_arrivee
FROM   ral_etape e1
JOIN   ral_etape e2 ON e2.ville_arrivee = e1.ville_arrivee
WHERE  e1.annee   <> e2.annee
   OR  e1.n_etape <> e2.n_etape
   OR  e1.suffixe <> e2.suffixe
ORDER BY e1.ville_arrivee, e1.n_etape;
-- 28 lignes
-- L'étape 5 ERFOUD -> MARRAKECH existe en 1998 et en 2017. Sans l'année, les deux
-- lignes deviennent identiques et le DISTINCT n'en garde qu'une.

/* 17) Tous les motifs d'abandon, y compris ceux qui n'ont jamais servi. Afficher le
       code venant de ral_abandon, celui venant de ral_type_abandon et le libellé.
       Ne pas utiliser USING. */
SELECT a.code_abandon AS code_abandon,
       t.code_abandon AS code_type,
       t.libelle
FROM   ral_abandon a
RIGHT JOIN ral_type_abandon t ON t.code_abandon = a.code_abandon
ORDER BY t.code_abandon;
-- 18 lignes

/* 18) Pilotes des écuries SAFRAN DUNES TEAM, ATLAS RALLY et SIERRA RALLY TEAM qui ont
       abandonné en 2025 : nom, prénom, motif, écurie et ses trois managers. */
SELECT p.nom        AS pilote,
       p.prenom,
       a.code_abandon,
       s.nom        AS ecurie,
       m1.nom       AS manager_1,
       m2.nom       AS manager_2,
       m3.nom       AS manager_3
FROM   ral_abandon a
JOIN   ral_pilote p             ON p.n_pilote = a.n_pilote
JOIN   ral_engagement e         ON e.n_pilote = a.n_pilote AND e.annee = a.annee
JOIN   ral_sponsor s            ON s.n_ecurie = e.n_ecurie AND s.n_sponsor = e.n_sponsor
JOIN   ral_engagement_ecurie ee ON ee.annee = e.annee AND ee.n_ecurie = e.n_ecurie AND ee.n_sponsor = e.n_sponsor
JOIN   ral_manager m1           ON m1.n_manager = ee.n_manager1
LEFT JOIN ral_manager m2        ON m2.n_manager = ee.n_manager2
LEFT JOIN ral_manager m3        ON m3.n_manager = ee.n_manager3
WHERE  a.annee = 2025
  AND  s.nom IN ('SAFRAN DUNES TEAM', 'ATLAS RALLY', 'SIERRA RALLY TEAM')
ORDER BY s.nom, p.nom;
-- 3 lignes
-- Jointures externes pour les managers 2 et 3 : une écurie peut ne pas en avoir.


-- =============================================================================
--  3. Opérateurs ensemblistes
-- =============================================================================

/* 19) Motifs d'abandon qui n'ont jamais été utilisés. */
SELECT code_abandon FROM ral_type_abandon
MINUS
SELECT code_abandon FROM ral_abandon;
-- 4 lignes

/* 19bis) Même question en affichant aussi le libellé. */
SELECT code_abandon, libelle
FROM   ral_type_abandon
MINUS
SELECT a.code_abandon, t.libelle
FROM   ral_abandon a
JOIN   ral_type_abandon t ON t.code_abandon = a.code_abandon;
-- 4 lignes

/* 20) Villes qui ont été à la fois ville de départ et ville d'arrivée. */
SELECT ville_depart AS ville FROM ral_etape
INTERSECT
SELECT ville_arrivee FROM ral_etape;
-- 24 lignes

/* 21) Numéros des pilotes qui ont terminé l'édition 2025. */
SELECT n_pilote FROM ral_engagement WHERE annee = 2025
MINUS
SELECT n_pilote FROM ral_abandon WHERE annee = 2025;
-- 18 lignes

/* 22) Numéros des pilotes engagés à toutes les éditions depuis 2016 (les dix
       dernières). */
-- Solution ensembliste : on retire les pilotes à qui il manque au moins une édition.
SELECT n_pilote
FROM   ral_engagement
WHERE  annee > 2015
MINUS
SELECT n_pilote
FROM   (
         SELECT e.n_pilote, ed.annee
         FROM   ral_engagement e, ral_edition ed
         WHERE  e.annee  > 2015
           AND  ed.annee > 2015
         MINUS
         SELECT n_pilote, annee
         FROM   ral_engagement
       );
-- 6 lignes

-- Solution avec regroupement (partie 6)
SELECT n_pilote
FROM   ral_engagement
WHERE  annee > 2015
GROUP BY n_pilote
HAVING COUNT(*) = (SELECT COUNT(*) FROM ral_edition WHERE annee > 2015);
-- 6 lignes

/* 23) Écuries (n° d'écurie et de sponsor) classées dans le top 10 mondial mais jamais
       engagées sur le rallye, plus celles classées au-delà de la 20e place qui y ont
       été engagées. Utiliser ral_classement_mondial. */
(
  SELECT n_ecurie, n_sponsor FROM ral_classement_mondial WHERE rang_mondial <= 10
  MINUS
  SELECT n_ecurie, n_sponsor FROM ral_engagement_ecurie
)
UNION
(
  SELECT n_ecurie, n_sponsor FROM ral_classement_mondial WHERE rang_mondial > 20
  INTERSECT
  SELECT n_ecurie, n_sponsor FROM ral_engagement_ecurie
);
-- 8 lignes

/* 24) Étapes 8 à 12 de l'édition 2025 : afficher les km et la vitesse moyenne dans la
       même colonne, sur deux lignes. Colonnes : n° d'étape, départ, arrivée, "mesure"
       ('km' ou 'vitesse') et "valeur". */
SELECT n_etape, ville_depart, ville_arrivee, 'km' AS mesure, km AS valeur
FROM   ral_etape
WHERE  annee = 2025
  AND  n_etape BETWEEN 8 AND 12
UNION
SELECT n_etape, ville_depart, ville_arrivee, 'vitesse', vitesse_moy
FROM   ral_etape
WHERE  annee = 2025
  AND  n_etape BETWEEN 8 AND 12
ORDER BY 1, 4;
-- 10 lignes


-- =============================================================================
--  4. Vues
-- =============================================================================

/* 25) Créer la vue v_abandon_espoir : les pilotes espoirs qui ont abandonné, toutes
       éditions confondues (année, écurie, sponsor, pilote, n° de voiture). */
CREATE OR REPLACE VIEW v_abandon_espoir AS
SELECT e.annee, e.n_ecurie, e.n_sponsor, e.n_pilote, e.n_voiture
FROM   ral_engagement e
JOIN   ral_abandon a ON a.n_pilote = e.n_pilote AND a.annee = e.annee
WHERE  e.espoir = 'o';

/* 26) Explorer la vue et le dictionnaire de données. */
-- a. Structure de la vue
DESC v_abandon_espoir;

-- b. Contenu trié par n° de pilote, puis par n° de colonne (4e colonne = n_pilote)
SELECT * FROM v_abandon_espoir ORDER BY n_pilote;
-- 9 lignes

SELECT * FROM v_abandon_espoir ORDER BY 4;
-- 9 lignes

-- ROWNUM est attribué avant le tri : on garde 4 lignes quelconques, puis on les trie.
SELECT *
FROM   v_abandon_espoir
WHERE  ROWNUM < 5
ORDER BY n_pilote;
-- 4 lignes

-- c. Mes vues, et tous les objets de mon schéma
SELECT * FROM user_views;
SELECT DISTINCT object_type FROM user_objects;

-- d. Renommer la vue
RENAME v_abandon_espoir TO v_espoir_abandon;

SELECT * FROM v_espoir_abandon;
-- 9 lignes

/* 27) Avec cette vue, lister les espoirs qui ont abandonné en 2025 : nom, prénom,
       n° de voiture et sponsor. */
SELECT p.nom, p.prenom, v.n_voiture, s.nom AS sponsor
FROM   v_espoir_abandon v
JOIN   ral_pilote p  ON p.n_pilote = v.n_pilote
JOIN   ral_sponsor s ON s.n_ecurie = v.n_ecurie AND s.n_sponsor = v.n_sponsor
WHERE  v.annee = 2025
ORDER BY p.nom;
-- 4 lignes

/* 28) Enregistrer les requêtes 13 et 14 sous forme de vues v_q13 et v_q14. */
CREATE OR REPLACE VIEW v_q13 AS
SELECT p.nom, p.prenom, e.n_sponsor, e.n_ecurie
FROM   ral_pilote p
JOIN   ral_engagement e ON e.n_pilote = p.n_pilote
WHERE  e.annee = 2025
  AND  e.espoir = 'o';

CREATE OR REPLACE VIEW v_q14 AS
SELECT p.prenom, p.nom, a.code_abandon, t.libelle
FROM   ral_pilote p
JOIN   ral_engagement e      ON e.n_pilote = p.n_pilote
LEFT JOIN ral_abandon a      ON a.n_pilote = e.n_pilote AND a.annee = e.annee
LEFT JOIN ral_type_abandon t ON t.code_abandon = a.code_abandon
WHERE  e.annee = 2025;

/* 29) Retrouver les résultats des requêtes 13 et 14 à partir de ces vues. */
SELECT * FROM v_q13 ORDER BY nom;
-- 7 lignes

SELECT * FROM v_q14 ORDER BY nom, prenom;
-- 24 lignes

/* 30) Toutes les colonnes de v_q13 plus le nom du sponsor, triées par sponsor puis
       par nom. */
SELECT v.*, s.nom AS sponsor
FROM   v_q13 v
JOIN   ral_sponsor s ON s.n_ecurie = v.n_ecurie AND s.n_sponsor = v.n_sponsor
ORDER BY s.nom, v.nom;
-- 7 lignes


-- =============================================================================
--  5. Sous-requêtes
-- =============================================================================

/* 31) Pilotes qui ont abandonné en 2025, triés par année de naissance. */
SELECT *
FROM   ral_pilote
WHERE  n_pilote IN (SELECT n_pilote FROM ral_abandon WHERE annee = 2025)
ORDER BY annee_naissance;
-- 6 lignes

/* 32) Pilotes qui n'ont participé à aucune édition depuis 2001. */
SELECT *
FROM   ral_pilote
WHERE  n_pilote NOT IN (SELECT n_pilote FROM ral_engagement WHERE annee >= 2001)
ORDER BY nom, prenom;
-- 15 lignes

/* 33) Nom et prénom des pilotes qui ont couru sous les couleurs de GRANIT-NRT OFFROAD. */
SELECT nom, prenom
FROM   ral_pilote
WHERE  n_pilote IN (
         SELECT n_pilote
         FROM   ral_engagement
         WHERE  (n_ecurie, n_sponsor) IN (
                  SELECT n_ecurie, n_sponsor
                  FROM   ral_sponsor
                  WHERE  nom = 'GRANIT-NRT OFFROAD'
                )
       )
ORDER BY nom;
-- 4 lignes

/* 34) Même question avec la nationalité (code pays) de chaque pilote. */
SELECT p.nom, p.prenom, n.code_pays
FROM   ral_pilote p
JOIN   ral_nationalite n ON n.n_pilote = p.n_pilote
WHERE  p.n_pilote IN (
         SELECT n_pilote
         FROM   ral_engagement
         WHERE  (n_ecurie, n_sponsor) IN (
                  SELECT n_ecurie, n_sponsor
                  FROM   ral_sponsor
                  WHERE  nom = 'GRANIT-NRT OFFROAD'
                )
       )
ORDER BY p.nom;
-- 4 lignes

/* 35) Pilotes engagés en 2025 qui n'ont pas abandonné. */
SELECT *
FROM   ral_pilote
WHERE  n_pilote IN     (SELECT n_pilote FROM ral_engagement WHERE annee = 2025)
  AND  n_pilote NOT IN (SELECT n_pilote FROM ral_abandon    WHERE annee = 2025)
ORDER BY nom;
-- 18 lignes

/* 36) Pilotes (toutes les colonnes) qui étaient inscrits à une édition mais n'ont
       jamais pris le départ : un abandon est enregistré, mais aucun chrono. */
SELECT *
FROM   ral_pilote
WHERE  n_pilote IN (
         SELECT n_pilote
         FROM   ral_abandon
         WHERE  (n_pilote, annee) NOT IN (SELECT n_pilote, annee FROM ral_chrono)
       );
-- 1 ligne

/* 37) Pilotes classés entre la 1re et la 20e place de l'étape 1 de 2025, par ordre
       alphabétique. */
SELECT *
FROM   ral_pilote
WHERE  n_pilote IN (
         SELECT n_pilote
         FROM   ral_chrono
         WHERE  annee = 2025
           AND  n_etape = 1
           AND  rang BETWEEN 1 AND 20
       )
ORDER BY nom;
-- 20 lignes

/* 38) Pilotes (nom, prénom) qui ont gagné au moins une étape en 2005, avec leur sponsor. */
SELECT p.nom, p.prenom, s.nom AS sponsor
FROM   ral_pilote p
JOIN   ral_engagement e ON e.n_pilote = p.n_pilote
JOIN   ral_sponsor s    ON s.n_ecurie = e.n_ecurie AND s.n_sponsor = e.n_sponsor
WHERE  e.annee = 2005
  AND  p.n_pilote IN (SELECT n_pilote FROM ral_chrono WHERE annee = 2005 AND rang = 1)
ORDER BY p.nom;
-- 4 lignes

/* 38bis) Uniquement le nom des sponsors concernés. On n'affiche qu'une table, donc pas
          de jointure : seulement des sous-requêtes. */
SELECT nom
FROM   ral_sponsor
WHERE  (n_ecurie, n_sponsor) IN (
         SELECT n_ecurie, n_sponsor
         FROM   ral_engagement
         WHERE  annee = 2005
           AND  n_pilote IN (SELECT n_pilote FROM ral_chrono WHERE annee = 2005 AND rang = 1)
       );
-- 3 lignes

/* 39) Sponsors dont le pilote a gagné une étape partie de FES (trois sous-requêtes
       imbriquées). */
SELECT *
FROM   ral_sponsor
WHERE  (n_ecurie, n_sponsor) IN (
         SELECT n_ecurie, n_sponsor
         FROM   ral_engagement
         WHERE  (n_pilote, annee) IN (
                  SELECT n_pilote, annee
                  FROM   ral_chrono
                  WHERE  rang = 1
                    AND  (annee, n_etape, suffixe) IN (
                           SELECT annee, n_etape, suffixe
                           FROM   ral_etape
                           WHERE  ville_depart = 'FES'
                         )
                )
       );
-- 2 lignes

/* 40) Plus longue(s) étape(s) de 2025, sans fonction d'agrégat. */
SELECT *
FROM   ral_etape
WHERE  annee = 2025
  AND  km >= ALL (SELECT km FROM ral_etape WHERE annee = 2025);
-- 2 lignes

/* 41) Étape(s) de 2025 à la vitesse moyenne la plus faible (parmi les vitesses
       renseignées), sans fonction d'agrégat. */
SELECT *
FROM   ral_etape
WHERE  annee = 2025
  AND  vitesse_moy <= ALL (
         SELECT vitesse_moy
         FROM   ral_etape
         WHERE  annee = 2025
           AND  vitesse_moy IS NOT NULL
       );
-- 1 ligne
-- Sans "vitesse_moy IS NOT NULL", la comparaison avec la valeur null vaut "inconnu"
-- et "<= ALL" ne renvoie plus aucune ligne.

/* 42) Nombre de jours entre la première et la dernière étape de l'édition 2025. */
SELECT (SELECT date_etape FROM ral_etape WHERE annee = 2025 AND n_etape = 21)
     - (SELECT date_etape FROM ral_etape WHERE annee = 2025 AND n_etape = 1) AS nb_jours
FROM   dual;
-- 1 ligne

/* 42bis) Nombre de jours de course de l'édition 2025. */
SELECT COUNT(DISTINCT date_etape) AS jours_de_course
FROM   ral_etape
WHERE  annee = 2025;
-- 1 ligne

/* 43) Vainqueurs d'étape de 2017 dont la nationalité est celle du pays de départ de
       l'étape gagnée. Afficher les colonnes de ral_pilote. Une requête principale et
       trois sous-requêtes imbriquées. Pourquoi faut-il synchroniser ? */
-- Solution 1 : pilote -> nationalité -> étape -> chrono
SELECT *
FROM   ral_pilote p
WHERE  n_pilote IN (
         SELECT n_pilote
         FROM   ral_nationalite n
         WHERE  2017 BETWEEN annee_debut AND NVL(annee_fin, 3000)
           AND  code_pays IN (
                  SELECT pays_depart
                  FROM   ral_etape
                  WHERE  (annee, n_etape, suffixe) IN (
                           SELECT annee, n_etape, suffixe
                           FROM   ral_chrono c
                           WHERE  c.annee = 2017
                             AND  c.rang = 1
                             AND  c.n_pilote = n.n_pilote
                         )
                )
       );
-- 3 lignes

-- Solution 2 : pilote -> chrono -> étape -> nationalité
SELECT *
FROM   ral_pilote p
WHERE  n_pilote IN (
         SELECT n_pilote
         FROM   ral_chrono c
         WHERE  c.annee = 2017
           AND  c.rang = 1
           AND  (annee, n_etape, suffixe) IN (
                  SELECT annee, n_etape, suffixe
                  FROM   ral_etape
                  WHERE  pays_depart IN (
                           SELECT code_pays
                           FROM   ral_nationalite n
                           WHERE  n.n_pilote = c.n_pilote
                             AND  2017 BETWEEN annee_debut AND NVL(annee_fin, 3000)
                         )
                )
       );
-- 3 lignes
-- Sans la condition "c.n_pilote = n.n_pilote", on garderait tout pilote dont le pays
-- a vu partir une étape gagnée par n'importe qui. La synchronisation relie le
-- vainqueur de l'étape au pilote dont on teste la nationalité.

/* 44) Pilotes qui ont gagné au moins une étape en 2025, avec une requête synchronisée
       (EXISTS). */
SELECT *
FROM   ral_pilote p
WHERE  EXISTS (
         SELECT *
         FROM   ral_chrono c
         WHERE  c.n_pilote = p.n_pilote
           AND  c.annee = 2025
           AND  c.rang = 1
       )
ORDER BY nom;
-- 13 lignes

/* 45) Les 5 premiers pilotes dans l'ordre alphabétique inverse des noms. */
-- On trie dans une sous-requête, puis on garde les 5 premières lignes.
SELECT *
FROM   (SELECT * FROM ral_pilote ORDER BY nom DESC)
WHERE  ROWNUM <= 5;
-- 5 lignes


-- =============================================================================
--  6. Expressions et fonctions
-- =============================================================================

/* 46) Étapes de 1988 : numéro, km et type écrit en toutes lettres (PRL = Prologue,
       SPE = Spéciale chronométrée, MAR = Étape marathon, LIG = Étape de liaison).
       Utiliser DECODE, puis CASE. */
SELECT n_etape,
       km,
       DECODE(code_type, 'PRL', 'Prologue',
                         'SPE', 'Spéciale chronométrée',
                         'MAR', 'Étape marathon',
                         'LIG', 'Étape de liaison') AS type_etape
FROM   ral_etape
WHERE  annee = 1988
ORDER BY n_etape;
-- 6 lignes

SELECT n_etape,
       km,
       CASE code_type
         WHEN 'PRL' THEN 'Prologue'
         WHEN 'SPE' THEN 'Spéciale chronométrée'
         WHEN 'MAR' THEN 'Étape marathon'
         WHEN 'LIG' THEN 'Étape de liaison'
       END AS type_etape
FROM   ral_etape
WHERE  annee = 1988
ORDER BY n_etape;
-- 6 lignes

/* 47) Prénoms contenant 'é', 'î', 'ù' ou 'ô', affichés normalement et en
       hexadécimal (DUMP). */
SELECT prenom,
       DUMP(prenom, 16) AS prenom_hexa
FROM   ral_pilote
WHERE  prenom LIKE '%é%'
   OR  prenom LIKE '%î%'
   OR  prenom LIKE '%ù%'
   OR  prenom LIKE '%ô%'
ORDER BY prenom;
-- 11 lignes

/* 48) Étapes courues en dehors du mois de juillet. */
SELECT *
FROM   ral_etape
WHERE  TO_CHAR(date_etape, 'MM') <> '07';
-- 1 ligne


-- =============================================================================
--  7. Regroupements et fonctions d'agrégat
-- =============================================================================

/* 49a) Nombre total de pilotes dans la base. */
SELECT COUNT(*) AS nb_pilotes
FROM   ral_pilote;
-- 1 ligne

/* 49b) Même résultat, mais en partant de ral_engagement. */
SELECT COUNT(DISTINCT n_pilote) AS nb_pilotes
FROM   ral_engagement;
-- 1 ligne

/* 50) Nom et prénom du pilote qui a le nom le plus long. */
SELECT nom, prenom
FROM   ral_pilote
WHERE  LENGTH(nom) = (SELECT MAX(LENGTH(nom)) FROM ral_pilote);
-- 1 ligne

/* 51) Nombre de pilotes qui ont terminé l'édition 2025. */
SELECT COUNT(*) AS nb_arrivees
FROM   ral_engagement
WHERE  annee = 2025
  AND  n_pilote NOT IN (SELECT n_pilote FROM ral_abandon WHERE annee = 2025);
-- 1 ligne

/* 52) Chrono le plus long, le plus court et chrono moyen (arrondi) de l'étape 1 de 2025. */
SELECT MAX(total_secondes)          AS maxi,
       MIN(total_secondes)          AS mini,
       ROUND(AVG(total_secondes))   AS moyenne
FROM   ral_chrono
WHERE  annee = 2025
  AND  n_etape = 1;
-- 1 ligne

/* 53) Pour chaque édition : année, dernier jour, premier jour, nombre de jours entre
       les deux, nombre d'étapes et nombre de jours de repos. */
SELECT e.annee,
       MAX(e.date_etape)                     AS dernier_jour,
       MIN(e.date_etape)                     AS premier_jour,
       MAX(e.date_etape) - MIN(e.date_etape) AS nb_jours,
       COUNT(*)                              AS nb_etapes,
       ed.jours_repos
FROM   ral_etape e
JOIN   ral_edition ed ON ed.annee = e.annee
GROUP BY e.annee, ed.jours_repos
ORDER BY e.annee;
-- 5 lignes

/* 54) Le chrono le plus long et le plus court réalisés sur une étape de 2025,
       exprimés en heures et minutes. */
SELECT TRUNC(MAX(total_secondes) / 3600) || ' h '
       || LPAD(TRUNC(MOD(MAX(total_secondes), 3600) / 60), 2, '0') || ' min' AS plus_long,
       TRUNC(MIN(total_secondes) / 3600) || ' h '
       || LPAD(TRUNC(MOD(MIN(total_secondes), 3600) / 60), 2, '0') || ' min' AS plus_court
FROM   ral_chrono
WHERE  annee = 2025;
-- 1 ligne

/* 55) Nombre de motifs d'abandon différents réellement utilisés. */
SELECT COUNT(DISTINCT code_abandon) AS nb_motifs
FROM   ral_abandon;
-- 1 ligne

/* 56) Abandons de 2025 : année, n° d'étape, motif et nombre d'abandons, triés par
       n° d'étape. */
SELECT annee, n_etape, code_abandon, COUNT(*) AS nb_abandons
FROM   ral_abandon
WHERE  annee = 2025
GROUP BY annee, n_etape, code_abandon
ORDER BY n_etape;
-- 6 lignes

/* 57a) Pour 2025 : chaque motif d'abandon, le nombre d'abandons pour ce motif et le
        nombre total d'abandons. Donner toutes les solutions. */
-- Solution 1 : deux vues, puis produit cartésien entre les vues
CREATE OR REPLACE VIEW v_total_abandons AS
SELECT COUNT(*) AS total_abandons
FROM   ral_abandon
WHERE  annee = 2025;

CREATE OR REPLACE VIEW v_abandons_par_motif AS
SELECT code_abandon, COUNT(*) AS nb_par_motif
FROM   ral_abandon
WHERE  annee = 2025
GROUP BY code_abandon;

SELECT code_abandon, nb_par_motif, total_abandons
FROM   v_abandons_par_motif, v_total_abandons
ORDER BY code_abandon;
-- 4 lignes

-- Solution 2 : la requête de la vue v_abandons_par_motif écrite directement
SELECT code_abandon, COUNT(*) AS nb_par_motif, total_abandons
FROM   ral_abandon, v_total_abandons
WHERE  annee = 2025
GROUP BY code_abandon, total_abandons
ORDER BY code_abandon;
-- 4 lignes

-- Solution 3 : sous-requête dans le FROM à la place de v_total_abandons
SELECT code_abandon, COUNT(*) AS nb_par_motif, total_abandons
FROM   ral_abandon,
       (SELECT COUNT(*) AS total_abandons FROM ral_abandon WHERE annee = 2025)
WHERE  annee = 2025
GROUP BY code_abandon, total_abandons
ORDER BY code_abandon;
-- 4 lignes

-- Solution 4 : sous-requête dans le SELECT
SELECT code_abandon,
       COUNT(*) AS nb_par_motif,
       (SELECT COUNT(*) FROM ral_abandon WHERE annee = 2025) AS total_abandons
FROM   ral_abandon
WHERE  annee = 2025
GROUP BY code_abandon
ORDER BY code_abandon;
-- 4 lignes

-- Solution 5 : fonctions analytiques
SELECT DISTINCT code_abandon,
       COUNT(*) OVER (PARTITION BY code_abandon) AS nb_par_motif,
       COUNT(*) OVER ()                          AS total_abandons
FROM   ral_abandon
WHERE  annee = 2025
ORDER BY code_abandon;
-- 4 lignes

-- Solution 6a : le total sur une dernière ligne, avec UNION
SELECT code_abandon, COUNT(*) AS nb
FROM   ral_abandon
WHERE  annee = 2025
GROUP BY code_abandon
UNION
SELECT 'TOTAL', COUNT(*)
FROM   ral_abandon
WHERE  annee = 2025
ORDER BY nb, code_abandon;
-- 5 lignes

-- Solution 6b : le total sur une dernière ligne, avec ROLLUP
SELECT NVL(code_abandon, 'TOTAL') AS code_abandon, COUNT(*) AS nb
FROM   ral_abandon
WHERE  annee = 2025
GROUP BY ROLLUP (code_abandon);
-- 5 lignes

/* 57b) Reprendre une des solutions et ajouter le pourcentage de chaque motif. */
SELECT code_abandon,
       nb_par_motif,
       total_abandons,
       ROUND(nb_par_motif * 100 / total_abandons, 1) AS pourcentage
FROM   v_abandons_par_motif, v_total_abandons
ORDER BY code_abandon;
-- 4 lignes

/* 58) Pilotes qui ont participé à plus de 10 éditions, avec leur nombre de
       participations, du plus grand au plus petit. */
SELECT p.nom, p.prenom, COUNT(*) AS nb_participations
FROM   ral_pilote p
JOIN   ral_engagement e ON e.n_pilote = p.n_pilote
GROUP BY p.n_pilote, p.nom, p.prenom
HAVING COUNT(*) > 10
ORDER BY nb_participations DESC;
-- 3 lignes

/* 59) Pilote(s) détenant le record de victoires d'étape, avec ce nombre de victoires. */
SELECT p.nom, p.prenom, COUNT(*) AS nb_victoires
FROM   ral_pilote p
JOIN   ral_chrono c ON c.n_pilote = p.n_pilote
WHERE  c.rang = 1
GROUP BY p.n_pilote, p.nom, p.prenom
HAVING COUNT(*) = (
         SELECT MAX(COUNT(*))
         FROM   ral_chrono
         WHERE  rang = 1
         GROUP BY n_pilote
       );
-- 1 ligne

/* 60) Pilotes plus rapides que la moyenne sur l'avant-dernière étape de 2025 : un
       numéro de ligne (ROWNUM), toutes les colonnes de ral_pilote et le chrono,
       du plus rapide au plus lent. */
SELECT ROWNUM, r.*
FROM   (
         SELECT p.*, c.total_secondes
         FROM   ral_pilote p
         JOIN   ral_chrono c ON c.n_pilote = p.n_pilote
         WHERE  c.annee = 2025
           AND  c.n_etape = (SELECT MAX(n_etape) - 1 FROM ral_etape WHERE annee = 2025)
           AND  c.total_secondes < (
                  SELECT AVG(total_secondes)
                  FROM   ral_chrono
                  WHERE  annee = 2025
                    AND  n_etape = (SELECT MAX(n_etape) - 1 FROM ral_etape WHERE annee = 2025)
                )
         ORDER BY c.total_secondes
       ) r;
-- 9 lignes
-- ROWNUM est dans la requête externe : il numérote des lignes déjà triées.

/* 61a) Pour l'édition 1998 : chaque sponsor engagé (écurie, sponsor, nom) et son
        nombre de pilotes au départ. En faire la vue v61_depart. */
CREATE OR REPLACE VIEW v61_depart AS
SELECT s.n_ecurie, s.n_sponsor, s.nom, COUNT(*) AS nb_depart
FROM   ral_engagement e
JOIN   ral_sponsor s ON s.n_ecurie = e.n_ecurie AND s.n_sponsor = e.n_sponsor
WHERE  e.annee = 1998
GROUP BY s.n_ecurie, s.n_sponsor, s.nom;

SELECT * FROM v61_depart;
-- 4 lignes

/* 61b) Même chose pour les pilotes arrivés au bout : vue v61_arrivee. */
CREATE OR REPLACE VIEW v61_arrivee AS
SELECT s.n_ecurie, s.n_sponsor, s.nom, COUNT(*) AS nb_arrivee
FROM   ral_engagement e
JOIN   ral_sponsor s ON s.n_ecurie = e.n_ecurie AND s.n_sponsor = e.n_sponsor
WHERE  e.annee = 1998
  AND  e.n_pilote NOT IN (SELECT n_pilote FROM ral_abandon WHERE annee = 1998)
GROUP BY s.n_ecurie, s.n_sponsor, s.nom;

SELECT * FROM v61_arrivee;
-- 3 lignes

/* 61c) Même chose pour les pilotes qui ont abandonné : vue v61_abandon. */
CREATE OR REPLACE VIEW v61_abandon AS
SELECT s.n_ecurie, s.n_sponsor, s.nom, COUNT(*) AS nb_abandon
FROM   ral_engagement e
JOIN   ral_sponsor s ON s.n_ecurie = e.n_ecurie AND s.n_sponsor = e.n_sponsor
WHERE  e.annee = 1998
  AND  e.n_pilote IN (SELECT n_pilote FROM ral_abandon WHERE annee = 1998)
GROUP BY s.n_ecurie, s.n_sponsor, s.nom;

SELECT * FROM v61_abandon;
-- 2 lignes

/* 61d) Avec les trois vues : une ligne par sponsor avec ses départs, ses arrivées et
        ses abandons. */
SELECT d.n_ecurie,
       d.n_sponsor,
       d.nom,
       d.nb_depart,
       NVL(ar.nb_arrivee, 0) AS nb_arrivee,
       NVL(ab.nb_abandon, 0) AS nb_abandon
FROM   v61_depart d
LEFT JOIN v61_arrivee ar ON ar.n_ecurie = d.n_ecurie AND ar.n_sponsor = d.n_sponsor
LEFT JOIN v61_abandon ab ON ab.n_ecurie = d.n_ecurie AND ab.n_sponsor = d.n_sponsor
ORDER BY d.nom;
-- 4 lignes
-- Jointures externes : un sponsor peut n'avoir aucune arrivée, ou aucun abandon.

/* 61e) Même information présentée verticalement : une ligne par sponsor et par
        catégorie (départ, arrivée, abandon). */
SELECT nom, 'départ'  AS categorie, nb_depart  AS nombre FROM v61_depart
UNION
SELECT nom, 'arrivée',              nb_arrivee           FROM v61_arrivee
UNION
SELECT nom, 'abandon',              nb_abandon           FROM v61_abandon
ORDER BY 1, 2 DESC;
-- 9 lignes

/* 61f) Le ou les sponsors qui avaient le plus de pilotes à l'arrivée en 1998. */
SELECT *
FROM   v61_arrivee
WHERE  nb_arrivee = (SELECT MAX(nb_arrivee) FROM v61_arrivee);
-- 1 ligne

/* 62a) Pilotes de 2025 qui n'ont pas abandonné : n° de pilote, nom, prénom, total de
        leurs chronos (en secondes) et pénalité éventuelle (ral_penalite). Trier par
        total. */
SELECT p.n_pilote,
       p.nom,
       p.prenom,
       SUM(c.total_secondes) AS total_secondes,
       pe.secondes           AS penalite
FROM   ral_pilote p
JOIN   ral_chrono c        ON c.n_pilote = p.n_pilote
LEFT JOIN ral_penalite pe  ON pe.n_pilote = c.n_pilote AND pe.annee = c.annee
WHERE  c.annee = 2025
  AND  p.n_pilote NOT IN (SELECT n_pilote FROM ral_abandon WHERE annee = 2025)
GROUP BY p.n_pilote, p.nom, p.prenom, pe.secondes
ORDER BY 4;
-- 18 lignes

/* 62b) Classement final de 2005 (pilotes n'ayant pas abandonné) : n° de pilote, nom,
        prénom et "temps final" = total des chronos + pénalité. */
SELECT p.n_pilote,
       p.nom,
       p.prenom,
       SUM(c.total_secondes) + NVL(pe.secondes, 0) AS "temps final"
FROM   ral_pilote p
JOIN   ral_chrono c        ON c.n_pilote = p.n_pilote
LEFT JOIN ral_penalite pe  ON pe.n_pilote = c.n_pilote AND pe.annee = c.annee
WHERE  c.annee = 2005
  AND  p.n_pilote NOT IN (SELECT n_pilote FROM ral_abandon WHERE annee = 2005)
GROUP BY p.n_pilote, p.nom, p.prenom, pe.secondes
ORDER BY 4;
-- 12 lignes

-- Variante : les pilotes disqualifiés après coup (valide = 'N') sont masqués par des tirets.
SELECT DECODE(e.valide, 'N', '------', TO_CHAR(p.n_pilote))            AS n_pilote,
       DECODE(e.valide, 'N', SUBSTR(p.nom, 1, 2) || '----', p.nom)      AS nom,
       p.prenom,
       SUM(c.total_secondes) + NVL(pe.secondes, 0)                       AS "temps final"
FROM   ral_pilote p
JOIN   ral_engagement e    ON e.n_pilote = p.n_pilote
JOIN   ral_chrono c        ON c.n_pilote = e.n_pilote AND c.annee = e.annee
LEFT JOIN ral_penalite pe  ON pe.n_pilote = c.n_pilote AND pe.annee = c.annee
WHERE  e.annee = 2005
  AND  p.n_pilote NOT IN (SELECT n_pilote FROM ral_abandon WHERE annee = 2005)
GROUP BY e.valide, p.n_pilote, p.nom, p.prenom, pe.secondes
ORDER BY 4;
-- 12 lignes


-- =============================================================================
--  8. Requêtes avancées
-- =============================================================================

/* 63) Sponsor actuel de chaque écurie encore en activité. */
SELECT *
FROM   ral_sponsor
WHERE  (n_ecurie, n_sponsor) IN (SELECT n_ecurie, MAX(n_sponsor) FROM ral_sponsor GROUP BY n_ecurie)
  AND  n_ecurie IN (SELECT n_ecurie FROM ral_ecurie WHERE annee_disparition IS NULL)
ORDER BY n_ecurie;
-- 22 lignes

/* 64) Pour les écuries qui ont connu plus de 6 sponsors : les informations du dernier
       sponsor et le nombre de noms portés. (Attention : MAX n'est pas COUNT.) */
CREATE OR REPLACE VIEW v_nb_sponsors AS
SELECT n_ecurie,
       COUNT(*)       AS nb_sponsors,
       MAX(n_sponsor) AS dernier_sponsor
FROM   ral_sponsor
GROUP BY n_ecurie;

SELECT s.*, v.nb_sponsors
FROM   ral_sponsor s
JOIN   v_nb_sponsors v ON v.n_ecurie = s.n_ecurie AND v.dernier_sponsor = s.n_sponsor
WHERE  v.nb_sponsors > 6;
-- 1 ligne

/* 65) Premier et dernier sponsor de chaque écurie encore en activité. */
SELECT ec.n_ecurie,
       pr.nom           AS premier_sponsor,
       pr.annee_sponsor AS depuis,
       de.nom           AS dernier_sponsor,
       de.annee_sponsor AS depuis_dernier
FROM   ral_ecurie ec
JOIN   ral_sponsor pr ON pr.n_ecurie = ec.n_ecurie
JOIN   ral_sponsor de ON de.n_ecurie = ec.n_ecurie
WHERE  ec.annee_disparition IS NULL
  AND  pr.n_sponsor = (SELECT MIN(n_sponsor) FROM ral_sponsor WHERE n_ecurie = ec.n_ecurie)
  AND  de.n_sponsor = (SELECT MAX(n_sponsor) FROM ral_sponsor WHERE n_ecurie = ec.n_ecurie)
ORDER BY ec.n_ecurie;
-- 22 lignes

/* 66) Arbre des écuries qui ont succédé à l'écurie 14 (requête hiérarchique). */
SELECT LEVEL,
       LPAD(' ', 4 * (LEVEL - 1)) || n_ecurie_successeur AS arborescence,
       n_ecurie                                          AS predecesseur
FROM   ral_ecurie_succede
START WITH n_ecurie = 14
CONNECT BY PRIOR n_ecurie_successeur = n_ecurie;
-- 4 lignes

/* 67) Retrouver la question à partir de la requête. */
/* 67a) Question : pour l'édition 2025, combien de pilotes représentaient chaque pays,
        y compris les pays sans aucun pilote (0) ? Du plus grand nombre au plus petit. */
SELECT pa.code_pays, COUNT(*) AS nb
FROM   ral_pays pa
JOIN   ral_nationalite n  ON n.code_pays = pa.code_pays
JOIN   ral_engagement e   ON e.n_pilote = n.n_pilote
WHERE  e.annee = 2025
  AND  e.annee BETWEEN n.annee_debut AND NVL(n.annee_fin, 3000)
GROUP BY pa.code_pays
UNION
SELECT code_pays, 0
FROM   ral_pays
WHERE  code_pays NOT IN (
         SELECT n.code_pays
         FROM   ral_nationalite n
         JOIN   ral_engagement e ON e.n_pilote = n.n_pilote
         WHERE  e.annee = 2025
           AND  e.annee BETWEEN n.annee_debut AND NVL(n.annee_fin, 3000)
       )
ORDER BY nb DESC;
-- 21 lignes

/* 67b) Question : pour chaque édition, combien de pilotes y faisaient leurs débuts ?
        De la plus récente à la plus ancienne. */
SELECT annee, COUNT(*) AS nb
FROM   ral_engagement
JOIN   ral_pilote USING (n_pilote)
WHERE  annee_debut = annee
GROUP BY annee
ORDER BY annee DESC;
-- 13 lignes
