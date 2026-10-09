-- -----------------------------------------------------------------------------
-- Tour de France : exercices 1 à 67 (3-sql_tdf_exercices.pdf, V 3.7)
-- Base utilisée : ma base TOUR_* (base_tour.sql), pas la base prof.vt_*.
--   prof.vt_xxx  ->  tour_xxx   (mêmes colonnes)
-- Syntaxe Oracle. Sous chaque requête : nombre de lignes obtenues sur ma base.
-- -----------------------------------------------------------------------------


-- =============================================================================
-- La projection et la restriction
-- =============================================================================

/* 1) Établir la liste des étapes dont le n° est compris entre 5 et 10.
      Afficher le n° de l'étape, la ville départ, la ville arrivée et la distance. */
select n_etape, ville_d, ville_a, distance from tour_etape
where n_etape between 5 and 10
order by annee, n_etape;
-- 11 lignes

/* 2) Même requête que précédemment mais pour l'année 2025. */
select n_etape, ville_d, ville_a, distance from tour_etape
where n_etape between 5 and 10
and annee = 2025
order by n_etape;
-- 6 lignes

/* 3) Afficher la liste des étapes dont le n° est inférieur à 5 ou supérieur à 10
      pour l'année 2025 (2 solutions). */
-- solution 1 : or
select n_etape, ville_d, ville_a, distance from tour_etape
where (n_etape < 5 or n_etape > 10)
and annee = 2025
order by n_etape;
-- 15 lignes

-- solution 2 : not between
select n_etape, ville_d, ville_a, distance from tour_etape
where n_etape not between 5 and 10
and annee = 2025
order by n_etape;
-- 15 lignes

/* 4) Établir la liste des étapes "prologue". Afficher le code pays départ, le code pays
      arrivée, la ville départ, la ville arrivée, la distance, la vitesse moyenne, année et
      le type d'étape. La liste sera présentée par ordre croissant de la distance. */
select code_cio_d, code_cio_a, ville_d, ville_a, distance, moyenne, annee, cat_code from tour_etape
where cat_code = 'PRO'
order by distance;
-- 2 lignes

/* 5) Projeter les étapes répondant à l'une ou l'autre des restrictions suivantes
      (une seule requête) :
        - le premier caractère de la ville de départ est un 'B',
        - le dernier caractère de la ville de départ est un 'A',
        - la ville de départ contient un 'U'. */
select * from tour_etape
where ville_d like 'B%'
or ville_d like '%A'
or ville_d like '%U%'
order by annee, n_etape;
-- 21 lignes

/* 6) Projeter l'étape courue le 14 juillet 2025. */
select * from tour_etape
where date_etape = to_date('14/07/2025', 'DD/MM/YYYY');
-- 1 ligne

/* 7) Projeter le prénom, le nom et l'âge des coureurs ayant participé à leur premier
      tour en 2025. Trier par âge. */
select prenom, nom, annee_prem - annee_naissance as age from tour_coureur
where annee_prem = 2025
order by age;
-- 4 lignes

/* 8) Donner la liste des sponsors dont le nom abrégé est vide après 1990. */
select * from tour_sponsor
where na_sponsor is null
and annee_sponsor > 1990;
-- 8 lignes

/* 9) Projeter par ordre alphabétique croissant des prénoms et par nom des coureurs
      décroissant, la liste des coureurs dont le nom commence par un 'V'. */
select * from tour_coureur
where nom like 'V%'
order by prenom asc, nom desc;
-- 4 lignes

/* 10) Projeter la liste des nations des coureurs (app_nation) dont le pays d'origine a
       pour code : "SUI", "JAP" ou "POL". */
-- Dans ma base le Japon a son vrai code CIO : JPN.
select * from tour_app_nation
where code_cio in ('SUI', 'JPN', 'POL');
-- 5 lignes


-- =============================================================================
-- La jointure
-- =============================================================================

/* 11) Donner la liste des coureurs ayant participé au Tour 2025. Afficher le nom, le
       prénom, le numéro de dossard, le n° de l'équipe et le numéro de coureur.
       Utiliser au moins 2 méthodes pour effectuer la jointure. */
-- méthode 1 : SQL1 (jointure dans le where)
select cou.nom, cou.prenom, par.n_dossard, par.n_equipe, cou.n_coureur from tour_coureur cou, tour_parti_coureur par
where cou.n_coureur = par.n_coureur
and par.annee = 2025
order by par.n_dossard;
-- 24 lignes

-- méthode 2 : join ... on
select cou.nom, cou.prenom, par.n_dossard, par.n_equipe, cou.n_coureur from tour_coureur cou
join tour_parti_coureur par on par.n_coureur = cou.n_coureur
where par.annee = 2025
order by par.n_dossard;
-- 24 lignes

-- méthode 3 : join ... using
select nom, prenom, n_dossard, n_equipe, n_coureur from tour_coureur
join tour_parti_coureur using (n_coureur)
where annee = 2025
order by n_dossard;
-- 24 lignes

/* 11bis) Même requête que précédemment mais pour les dossards compris entre 1 et 9.
          Justifier le nombre de réponses. */
select cou.nom, cou.prenom, par.n_dossard, par.n_equipe, cou.n_coureur from tour_coureur cou
join tour_parti_coureur par on par.n_coureur = cou.n_coureur
where par.annee = 2025
and par.n_dossard between 1 and 9
order by par.n_dossard;
-- 4 lignes
-- Les dossards vont par dizaine : 1 à 4 pour la 1re équipe, 11 à 14 pour la 2e, etc.
-- (4 coureurs par équipe dans ma base). Entre 1 et 9 il n'y a donc que la 1re équipe.

/* 11ter) Même requête que précédemment mais en projetant en complément le nom du sponsor. */
select cou.nom, cou.prenom, par.n_dossard, par.n_equipe, cou.n_coureur, spo.nom as sponsor from tour_coureur cou
join tour_parti_coureur par on par.n_coureur = cou.n_coureur
join tour_sponsor spo on spo.n_equipe = par.n_equipe and spo.n_sponsor = par.n_sponsor
where par.annee = 2025
and par.n_dossard between 1 and 9
order by par.n_dossard;
-- 4 lignes
-- La jointure avec le sponsor se fait sur la clé complète (n_equipe, n_sponsor) :
-- avec n_equipe seul, on obtiendrait une ligne par sponsor qu'a connu l'équipe.

/* 12) Donner la liste des coureurs dont les numéros de dossard sont compris entre 28 et 49
       et dont le nom contient soit 'ZI', soit 'IZ'. Afficher le nom, le prénom, le n°
       d'équipe, le n° de sponsor et l'année du Tour de France. Le résultat sera classé
       sur l'année du Tour. */
select cou.nom, cou.prenom, par.n_equipe, par.n_sponsor, par.annee from tour_coureur cou
join tour_parti_coureur par on par.n_coureur = cou.n_coureur
where par.n_dossard between 28 and 49
and (cou.nom like '%ZI%' or cou.nom like '%IZ%')
order by par.annee;
-- 7 lignes

/* 13) Donner la liste des coureurs considérés comme jeunes pour le Tour 2025. Afficher le
       nom, le prénom, le numéro du sponsor et d'équipe, classés par ordre alphabétique
       sur le nom du coureur. */
select cou.nom, cou.prenom, par.n_sponsor, par.n_equipe from tour_coureur cou
join tour_parti_coureur par on par.n_coureur = cou.n_coureur
where par.annee = 2025
and par.jeune = 'o'
order by cou.nom;
-- 7 lignes

/* 13bis) Donner la liste des coureurs considérés comme jeunes pour le Tour 2025. Afficher
          le nom, le prénom et le nom du sponsor, classés par ordre alphabétique sur le nom
          du sponsor et sur le nom du coureur. */
select cou.nom, cou.prenom, spo.nom as sponsor from tour_coureur cou
join tour_parti_coureur par on par.n_coureur = cou.n_coureur
join tour_sponsor spo on spo.n_equipe = par.n_equipe and spo.n_sponsor = par.n_sponsor
where par.annee = 2025
and par.jeune = 'o'
order by spo.nom, cou.nom;
-- 7 lignes

/* 14) Donner la liste des coureurs (prénom et nom) ayant participé au tour 2025 et pour
       ceux ayant abandonné, le type d'abandon. Attention, les coureurs n'ayant pas
       abandonné doivent être également projetés. */
select cou.prenom, cou.nom, aba.c_typeaban, typ.libelle from tour_coureur cou
join tour_parti_coureur par on par.n_coureur = cou.n_coureur
left join tour_abandon aba on aba.n_coureur = par.n_coureur and aba.annee = par.annee
left join tour_typeaban typ on typ.c_typeaban = aba.c_typeaban
where par.annee = 2025
order by cou.nom, cou.prenom;
-- 24 lignes
-- La condition sur l'année doit porter sur par.annee : avec "aba.annee = 2025" dans le
-- where, les coureurs sans abandon (aba.annee null) disparaîtraient.

/* 15) Donner la liste alphabétique, classée sur le nom et le prénom, des coureurs ayant
       des homonymes (même nom). */
select distinct c1.nom, c1.prenom from tour_coureur c1
join tour_coureur c2 on c2.nom = c1.nom
where c1.n_coureur <> c2.n_coureur
order by c1.nom, c1.prenom;
-- 3 lignes

/* 16) Donner la liste des villes ayant été plusieurs fois ville d'arrivée (ville_a).
       Afficher le n° étape, le n° comp, la ville départ, la ville arrivée et l'année. */
select distinct e1.n_etape, e1.n_comp, e1.ville_d, e1.ville_a, e1.annee from tour_etape e1
join tour_etape e2 on e2.ville_a = e1.ville_a
where e1.n_etape <> e2.n_etape
or e1.n_comp <> e2.n_comp
or e1.annee <> e2.annee
order by e1.ville_a, e1.annee, e1.n_etape;
-- 9 lignes
-- Une étape est identifiée par (annee, n_etape, n_comp) : il faut que l'une des trois
-- colonnes soit différente pour être sûr de ne pas comparer l'étape avec elle-même.

/* 16bis) Même question mais sans afficher l'année. Pourquoi perd-on des lignes ? */
select distinct e1.n_etape, e1.n_comp, e1.ville_d, e1.ville_a from tour_etape e1
join tour_etape e2 on e2.ville_a = e1.ville_a
where e1.n_etape <> e2.n_etape
or e1.n_comp <> e2.n_comp
or e1.annee <> e2.annee
order by e1.ville_a, e1.n_etape;
-- 8 lignes
-- Sans l'année, deux étapes d'années différentes qui ont le même n°, le même départ et la
-- même arrivée donnent la même ligne : le distinct n'en garde qu'une.

/* 17) Donner la liste des différents types d'abandon, même les types pour lesquels il
       n'existe aucun abandon. Ne pas utiliser join using. Afficher type_aban de vt_abandon
       et de vt_typeaban ainsi que le libellé de vt_typeaban. */
select aba.c_typeaban as type_abandon, typ.c_typeaban as type_typeaban, typ.libelle from tour_abandon aba
right join tour_typeaban typ on typ.c_typeaban = aba.c_typeaban
order by typ.c_typeaban;
-- 19 lignes

/* 18) Donner la liste des coureurs des équipes "Astana", "Cofidis" et "Movistar" (vérifier
       les noms exacts) ayant abandonné dans le Tour 2025. Afficher le nom, le prénom, le
       type d'abandon et les directeurs d'équipe. */
-- noms exacts en 2025 dans ma base : XDS ASTANA TEAM, COFIDIS, MOVISTAR TEAM
select cou.nom as nom_coureur, cou.prenom, aba.c_typeaban, spo.nom as equipe, dir1.nom as directeur_1, dir2.nom as directeur_2, dir3.nom as directeur_3 from tour_abandon aba
join tour_coureur cou on cou.n_coureur = aba.n_coureur
join tour_parti_coureur par on par.n_coureur = aba.n_coureur and par.annee = aba.annee
join tour_sponsor spo on spo.n_equipe = par.n_equipe and spo.n_sponsor = par.n_sponsor
join tour_parti_equipe peq on peq.annee = par.annee and peq.n_equipe = par.n_equipe and peq.n_sponsor = par.n_sponsor
join tour_directeur dir1 on dir1.n_directeur = peq.n_pre_directeur
left join tour_directeur dir2 on dir2.n_directeur = peq.n_sec_directeur
left join tour_directeur dir3 on dir3.n_directeur = peq.n_troi_directeur
where aba.annee = 2025
and spo.nom in ('XDS ASTANA TEAM', 'COFIDIS', 'MOVISTAR TEAM')
order by spo.nom, cou.nom;
-- 3 lignes
-- Jointures externes pour les directeurs 2 et 3 : ils peuvent être absents (null).


-- =============================================================================
-- Les opérateurs ensemblistes
-- =============================================================================

/* 19) Projeter le type d'abandon n'ayant aucun abandon correspondant. */
select c_typeaban from tour_typeaban
minus
select c_typeaban from tour_abandon;
-- 5 lignes

/* 19bis) Même question mais en affichant également le libellé. */
select c_typeaban, libelle from tour_typeaban
minus
select aba.c_typeaban, typ.libelle from tour_abandon aba
join tour_typeaban typ on typ.c_typeaban = aba.c_typeaban;
-- 5 lignes

/* 20) Projeter les villes ayant été ville de départ et d'arrivée. */
select ville_d as ville from tour_etape
intersect
select ville_a from tour_etape;
-- 9 lignes

/* 21) Projeter le n° des coureurs ayant terminé le Tour 2025. */
select n_coureur from tour_parti_coureur
where annee = 2025
minus
select n_coureur from tour_abandon
where annee = 2025;
-- 18 lignes

/* 22) Projeter le n° de coureur pour les coureurs ayant participé à tous les "Tour de
       France" depuis 10 ans. */
-- "depuis 10 ans" = les 10 derniers Tours : 2016 à 2025.
-- solution ensembliste (division) : on retire ceux à qui il manque au moins une année
select n_coureur from tour_parti_coureur
where annee > 2015
minus
select n_coureur from
(
  select cou.n_coureur, ann.annee from tour_parti_coureur cou, tour_annee ann
  where cou.annee > 2015
  and ann.annee > 2015
  minus
  select n_coureur, annee from tour_parti_coureur
);
-- 6 lignes

-- solution avec regroupement (chapitre 1.8)
select n_coureur from tour_parti_coureur
where annee > 2015
group by n_coureur
having count(*) = (select count(*) from tour_annee where annee > 2015);
-- 6 lignes

/* 23) Afficher le n° d'équipe et le n° de sponsor des sponsors classés dans les 10
       premiers mais n'ayant jamais participé au tour (1) ainsi que les sponsors classés
       au-delà des 20 premiers et qui ont participé au tour (2). (utiliser vt_ordrequi) */
(
  select n_equipe, n_sponsor from tour_ordrequi
  where numero_ordre <= 10
  minus
  select n_equipe, n_sponsor from tour_parti_equipe
)
union
(
  select n_equipe, n_sponsor from tour_ordrequi
  where numero_ordre > 20
  intersect
  select n_equipe, n_sponsor from tour_parti_equipe
);
-- 8 lignes

/* 24) Donner la liste des étapes 8 à 12 du Tour 2025 en affichant dans la même colonne la
       distance et la moyenne (sur deux lignes différentes). Afficher le n° de l'étape, la
       ville départ, la ville arrivée, les chaînes "distance" et "moyenne" dans une colonne
       nommée "libellé" et les valeurs dans une colonne nommée "résultat". */
select n_etape, ville_d, ville_a, 'distance' as "libellé", distance as "résultat" from tour_etape
where annee = 2025
and n_etape between 8 and 12
union
select n_etape, ville_d, ville_a, 'moyenne', moyenne from tour_etape
where annee = 2025
and n_etape between 8 and 12
order by 1, 4;
-- 10 lignes


-- =============================================================================
-- Les vues
-- =============================================================================

/* 25) Tester une vue "v_aban_25" permettant d'afficher la liste des jeunes coureurs
       (année, n° équipe, n° de sponsor, n° de coureur et n° de dossard) ayant abandonné
       quelle que soit l'année. */
create or replace view v_aban_25 as
select par.annee, par.n_equipe, par.n_sponsor, par.n_coureur, par.n_dossard from tour_parti_coureur par
join tour_abandon aba on aba.n_coureur = par.n_coureur and aba.annee = par.annee
where par.jeune = 'o';

/* 26) Tester et commenter les requêtes suivantes. */
-- a. structure de la vue (commande SQL Developer / SQL*Plus)
desc v_aban_25;

-- b. exécuter la vue en classant les coureurs sur le n° de coureur
select * from v_aban_25
order by n_coureur;
-- 9 lignes

-- même chose avec le n° de colonne (n_coureur est la 4e colonne)
select * from v_aban_25
order by 4;
-- 9 lignes

-- rownum est numéroté AVANT le tri : on garde 4 lignes quelconques, puis on les trie
select * from v_aban_25
where rownum < 5
order by n_coureur;
-- 4 lignes

-- c. dictionnaire de données : mes vues, les vues visibles, les utilisateurs
select * from user_views;
select * from all_views
where owner like 'ETU1%';
select * from all_users;

-- d. objets de mon schéma
select * from user_catalog;
select distinct table_type from user_catalog;
select * from user_objects;
select distinct object_type from user_objects;
purge recyclebin;

-- e. renommer la vue en "v_aban_jeune"
drop view v_aban_jeune;
rename v_aban_25 to v_aban_jeune;
select * from v_aban_jeune;
-- 9 lignes

/* 27) En utilisant la vue créée précédemment, donner la liste des jeunes coureurs ayant
       abandonné le Tour en 2025. Afficher le nom, le prénom, le n° de dossard et le nom
       de l'équipe (sponsor). */
select cou.nom, cou.prenom, vue.n_dossard, spo.nom as equipe from v_aban_jeune vue
join tour_coureur cou on cou.n_coureur = vue.n_coureur
join tour_sponsor spo on spo.n_equipe = vue.n_equipe and spo.n_sponsor = vue.n_sponsor
where vue.annee = 2025
order by cou.nom;
-- 4 lignes

/* 28) Sauvegarder les requêtes 13 et 14 sous forme de vues "v_req13" et "v_req14". */
create or replace view v_req13 as
select cou.nom, cou.prenom, par.n_sponsor, par.n_equipe from tour_coureur cou
join tour_parti_coureur par on par.n_coureur = cou.n_coureur
where par.annee = 2025
and par.jeune = 'o';

create or replace view v_req14 as
select cou.prenom, cou.nom, aba.c_typeaban, typ.libelle from tour_coureur cou
join tour_parti_coureur par on par.n_coureur = cou.n_coureur
left join tour_abandon aba on aba.n_coureur = par.n_coureur and aba.annee = par.annee
left join tour_typeaban typ on typ.c_typeaban = aba.c_typeaban
where par.annee = 2025;

/* 29) Ré-exécuter les requêtes 13 et 14, indépendamment, en utilisant les vues. */
select * from v_req13
order by nom;
-- 7 lignes

select * from v_req14
order by nom, prenom;
-- 24 lignes

/* 30) Afficher toutes les colonnes de la vue v_req13 en complétant la projection par le
       nom du sponsor. Le résultat sera classé sur le nom de l'équipe (sponsor) et le nom
       du coureur. */
select vue.*, spo.nom as sponsor from v_req13 vue
join tour_sponsor spo on spo.n_equipe = vue.n_equipe and spo.n_sponsor = vue.n_sponsor
order by spo.nom, vue.nom;
-- 7 lignes


-- =============================================================================
-- Les requêtes complexes (sous-requêtes)
-- =============================================================================

/* 31) Afficher les coureurs ayant abandonné en 2025 classés par année de naissance. */
select * from tour_coureur
where n_coureur in
(
  select n_coureur from tour_abandon
  where annee = 2025
)
order by annee_naissance;
-- 6 lignes

/* 32) Afficher les coureurs n'ayant pas participé à un tour de France au 21e siècle. */
-- le 21e siècle commence en 2001
select * from tour_coureur
where n_coureur not in
(
  select n_coureur from tour_parti_coureur
  where annee >= 2001
)
order by nom, prenom;
-- 15 lignes

/* 33) Afficher le nom et prénom des coureurs ayant appartenu à l'équipe
       DECATHLON-AG2R LA MONDIALE. */
select nom, prenom from tour_coureur
where n_coureur in
(
  select n_coureur from tour_parti_coureur
  where (n_equipe, n_sponsor) in
  (
    select n_equipe, n_sponsor from tour_sponsor
    where nom = 'DECATHLON-AG2R LA MONDIALE'
  )
)
order by nom;
-- 4 lignes

/* 34) Même question en projetant en plus la nationalité (code_cio) du coureur. */
select cou.nom, cou.prenom, app.code_cio from tour_coureur cou
join tour_app_nation app on app.n_coureur = cou.n_coureur
where cou.n_coureur in
(
  select n_coureur from tour_parti_coureur
  where (n_equipe, n_sponsor) in
  (
    select n_equipe, n_sponsor from tour_sponsor
    where nom = 'DECATHLON-AG2R LA MONDIALE'
  )
)
order by cou.nom;
-- 4 lignes

/* 35) Afficher les coureurs n'ayant pas abandonné en 2025. */
-- uniquement les coureurs qui étaient au départ du Tour 2025
select * from tour_coureur
where n_coureur in
(
  select n_coureur from tour_parti_coureur
  where annee = 2025
)
and n_coureur not in
(
  select n_coureur from tour_abandon
  where annee = 2025
)
order by nom;
-- 18 lignes

/* 36) Afficher la liste des coureurs (tous les champs) n'ayant pas pris le départ d'un
       Tour de France (l'absence au départ du Tour est considérée comme un abandon). */
-- inscrit, noté en abandon, mais aucun temps enregistré cette année-là
select * from tour_coureur
where n_coureur in
(
  select n_coureur from tour_abandon
  where (n_coureur, annee) not in
  (
    select n_coureur, annee from tour_temps
  )
);
-- 1 ligne

/* 37) Projeter par ordre alphabétique des noms, les coureurs arrivés entre la 1ère et la
       20e places dans l'étape 1 du Tour 2025. */
select * from tour_coureur
where n_coureur in
(
  select n_coureur from tour_temps
  where annee = 2025
  and n_etape = 1
  and rang_arrivee between 1 and 20
)
order by nom;
-- 20 lignes

/* 38) Projeter la liste des coureurs (nom, prénom) ainsi que le nom du sponsor ayant
       gagné une ou plusieurs étapes du tour 2005. */
select cou.nom, cou.prenom, spo.nom as sponsor from tour_coureur cou
join tour_parti_coureur par on par.n_coureur = cou.n_coureur
join tour_sponsor spo on spo.n_equipe = par.n_equipe and spo.n_sponsor = par.n_sponsor
where par.annee = 2005
and cou.n_coureur in
(
  select n_coureur from tour_temps
  where annee = 2005
  and rang_arrivee = 1
)
order by cou.nom;
-- 5 lignes

/* 38bis) Même question mais on demande de projeter le nom des sponsors uniquement.
          Bien respecter les règles d'or ! */
-- on ne projette que tour_sponsor : pas de jointure, uniquement des sous-requêtes
select nom from tour_sponsor
where (n_equipe, n_sponsor) in
(
  select n_equipe, n_sponsor from tour_parti_coureur
  where annee = 2005
  and n_coureur in
  (
    select n_coureur from tour_temps
    where annee = 2005
    and rang_arrivee = 1
  )
);
-- 3 lignes

/* 39) Projeter le sponsor dont le coureur a remporté l'étape dont la ville de départ est
       {BORDEAUX | GAP | CAEN}. La requête devra contenir 3 sous-requêtes imbriquées. */
-- ville choisie : CAEN
select * from tour_sponsor
where (n_equipe, n_sponsor) in
(
  select n_equipe, n_sponsor from tour_parti_coureur
  where (n_coureur, annee) in
  (
    select n_coureur, annee from tour_temps
    where rang_arrivee = 1
    and (annee, n_etape, n_comp) in
    (
      select annee, n_etape, n_comp from tour_etape
      where ville_d = 'CAEN'
    )
  )
);
-- 1 ligne

/* 40) Projeter les étapes du Tour 2025 dont la distance est la plus longue
       (pas de fonction d'agrégat). */
select * from tour_etape
where annee = 2025
and distance >= all
(
  select distance from tour_etape
  where annee = 2025
);
-- 1 ligne

/* 41) Projeter les étapes de plus faible moyenne non vide en 2025
       (pas de fonction d'agrégat). */
select * from tour_etape
where annee = 2025
and moyenne <= all
(
  select moyenne from tour_etape
  where annee = 2025
  and moyenne is not null
);
-- 1 ligne
-- Sans "moyenne is not null" dans la sous-requête, la comparaison avec null vaut
-- "inconnu" et "<= all" ne renvoie plus aucune ligne.

/* 42) Calculer la durée en jours du Tour de France 2025 en prenant en compte la date de la
       première étape et la date de la dernière étape du Tour 2025. */
select
(
  (select date_etape from tour_etape where annee = 2025 and n_etape = 21)
  -
  (select date_etape from tour_etape where annee = 2025 and n_etape = 1)
) as nb_jours from dual;
-- 1 ligne

/* 42bis) Projeter le nombre de jours courus dans le Tour 2025. */
select count(distinct date_etape) as jours_courus from tour_etape
where annee = 2025;
-- 1 ligne

/* 43) Donner la liste des coureurs arrivés premiers à une étape en 2017. Le pays d'origine
       du coureur doit être le même que celui de la ville de départ de l'étape où le coureur
       a gagné. Afficher les caractéristiques de "coureur". Requête principale et 3
       sous-requêtes imbriquées. Expliquer pourquoi la synchronisation est obligatoire. */
-- solution 1 : coureur -> app_nation -> etape -> temps
select * from tour_coureur cou
where n_coureur in
(
  select n_coureur from tour_app_nation app
  where 2017 between annee_debut and nvl(annee_fin, 3000)
  and code_cio in
  (
    select code_cio_d from tour_etape
    where (annee, n_etape, n_comp) in
    (
      select annee, n_etape, n_comp from tour_temps tem
      where tem.annee = 2017
      and tem.rang_arrivee = 1
      and tem.n_coureur = app.n_coureur
    )
  )
);
-- 2 lignes

-- solution 2 : coureur -> temps -> etape -> app_nation
select * from tour_coureur cou
where n_coureur in
(
  select n_coureur from tour_temps tem
  where tem.annee = 2017
  and tem.rang_arrivee = 1
  and (annee, n_etape, n_comp) in
  (
    select annee, n_etape, n_comp from tour_etape
    where code_cio_d in
    (
      select code_cio from tour_app_nation app
      where app.n_coureur = tem.n_coureur
      and 2017 between annee_debut and nvl(annee_fin, 3000)
    )
  )
);
-- 2 lignes
-- Synchronisation obligatoire : sans "tem.n_coureur = app.n_coureur", on garderait tout
-- coureur dont le pays a vu partir une étape gagnée par N'IMPORTE QUEL coureur. Il faut
-- relier le vainqueur de l'étape au coureur dont on teste la nationalité.

/* 44) Donner la liste des coureurs ayant gagné au moins une étape en 2025. Utiliser une
       requête synchronisée avec exists. */
select * from tour_coureur cou
where exists
(
  select * from tour_temps tem
  where tem.n_coureur = cou.n_coureur
  and tem.annee = 2025
  and tem.rang_arrivee = 1
)
order by nom;
-- 12 lignes

/* 45) Projeter les 5 premiers coureurs par liste alphabétique inversée des noms. */
-- on trie d'abord dans une sous-requête, puis on garde les 5 premières lignes
select * from
(
  select * from tour_coureur
  order by nom desc
)
where rownum <= 5;
-- 5 lignes


-- =============================================================================
-- Les expressions et fonctions
-- =============================================================================

/* 46) Pour chaque étape de 1988, projeter le numéro, la distance et le type d'étape en
       clair (PRO = Prologue, CMI = Contre la montre individuel, CME = Contre la montre
       par équipe, ETA = Etape en ligne). Utiliser decode (ou case ... when). */
select n_etape, distance, decode(cat_code, 'PRO', 'Prologue', 'CMI', 'Contre la montre individuel', 'CME', 'Contre la montre par équipe', 'ETA', 'Etape en ligne') as type_etape from tour_etape
where annee = 1988
order by n_etape;
-- 6 lignes

-- même chose avec case ... when
select n_etape, distance,
case cat_code
  when 'PRO' then 'Prologue'
  when 'CMI' then 'Contre la montre individuel'
  when 'CME' then 'Contre la montre par équipe'
  when 'ETA' then 'Etape en ligne'
end as type_etape from tour_etape
where annee = 1988
order by n_etape;
-- 6 lignes

/* 47) Projeter les prénoms des coureurs contenant des caractères comme 'é' ou 'î' ou 'ù'
       ou 'ô'. Afficher le prénom sous forme de texte et sous forme hexadécimale (dump). */
select prenom, dump(prenom, 16) as prenom_hexa from tour_coureur
where prenom like '%é%'
or prenom like '%î%'
or prenom like '%ù%'
or prenom like '%ô%'
order by prenom;
-- 11 lignes

/* 48) Projeter les étapes disputées en dehors de juillet. */
select * from tour_etape
where to_char(date_etape, 'MM') <> '07';
-- 1 ligne


-- =============================================================================
-- Le groupement des données et les fonctions d'agrégat
-- =============================================================================

/* 49 a) Nombre total de coureurs dans la base de données. */
select count(*) as nb_coureurs from tour_coureur;
-- 1 ligne

/* 49 b) On veut le même nombre de réponses que précédemment mais à partir de l'objet
         "parti_coureur". */
select count(distinct n_coureur) as nb_coureurs from tour_parti_coureur;
-- 1 ligne

/* 50) Donner le nom et prénom du coureur ayant le nom le plus long (fonction length). */
select nom, prenom from tour_coureur
where length(nom) =
(
  select max(length(nom)) from tour_coureur
);
-- 1 ligne

/* 51) Afficher le nombre de coureurs ayant terminé le Tour 2025. */
select count(*) as nb_arrivees from tour_parti_coureur
where annee = 2025
and n_coureur not in
(
  select n_coureur from tour_abandon
  where annee = 2025
);
-- 1 ligne

/* 52) Donner le temps maximum, le temps minimum et le temps moyen de la première étape
       de 2025. Arrondir pour la moyenne. */
select max(total_seconde) as maxi, min(total_seconde) as mini, round(avg(total_seconde)) as moyenne from tour_temps
where annee = 2025
and n_etape = 1;
-- 1 ligne

/* 53) Afficher pour chacun des Tours : l'année, le dernier jour, le 1er jour, le nombre de
       jours entre le dernier jour et le 1er jour, le nombre d'étapes, le nombre de jours
       de repos. */
select eta.annee, max(eta.date_etape) as dernier_jour, min(eta.date_etape) as premier_jour, max(eta.date_etape) - min(eta.date_etape) as nb_jours, count(*) as nb_etapes, ann.jour_repos from tour_etape eta
join tour_annee ann on ann.annee = eta.annee
group by eta.annee, ann.jour_repos
order by eta.annee;
-- 5 lignes

/* 54) Projeter en heures, le temps maximum et le temps minimum passé sur un vélo dans une
       étape du Tour 2025. */
select trunc(max(total_seconde) / 3600) || ' h ' || lpad(trunc(mod(max(total_seconde), 3600) / 60), 2, '0') || ' min' as temps_maxi, trunc(min(total_seconde) / 3600) || ' h ' || lpad(trunc(mod(min(total_seconde), 3600) / 60), 2, '0') || ' min' as temps_mini, round(max(total_seconde) / 3600, 2) as maxi_heures, round(min(total_seconde) / 3600, 2) as mini_heures from tour_temps
where annee = 2025;
-- 1 ligne

/* 55) Afficher le nombre de types distincts d'abandons constatés. */
select count(distinct c_typeaban) as nb_types from tour_abandon;
-- 1 ligne

/* 56) Afficher l'année, le n° d'étape, le type d'abandon et le nombre d'abandons par type
       pour l'année 2025, classé par ordre croissant sur le numéro d'étape. */
select annee, n_etape, c_typeaban, count(*) as nb_abandons from tour_abandon
where annee = 2025
group by annee, n_etape, c_typeaban
order by n_etape;
-- 6 lignes

/* 57 a) Afficher les types d'abandon, le nombre d'abandons par type, le total des abandons
         pour l'année 2025. Toutes les solutions sont demandées. */
-- solution 1 : deux vues puis produit cartésien entre les vues
create or replace view vt_nb_aban_total as
select count(*) as total_abandon from tour_abandon
where annee = 2025;

create or replace view vt_nb_aban as
select c_typeaban, count(*) as nb_par_type from tour_abandon
where annee = 2025
group by c_typeaban;

select c_typeaban, nb_par_type, total_abandon from vt_nb_aban, vt_nb_aban_total
order by c_typeaban;
-- 3 lignes

-- solution 2 : la requête à la place de la vue vt_nb_aban
select c_typeaban, count(*) as nb_par_type, total_abandon from tour_abandon, vt_nb_aban_total
where annee = 2025
group by c_typeaban, total_abandon
order by c_typeaban;
-- 3 lignes

-- solution 3 : la requête à la place de la vue vt_nb_aban_total
select c_typeaban, count(*) as nb_par_type, total_abandon from tour_abandon,
(
  select count(*) as total_abandon from tour_abandon
  where annee = 2025
)
where annee = 2025
group by c_typeaban, total_abandon
order by c_typeaban;
-- 3 lignes

-- solution 4 : la requête à la place de la colonne total_abandon
select c_typeaban, count(*) as nb_par_type,
(
  select count(*) from tour_abandon
  where annee = 2025
) as total_abandon from tour_abandon
where annee = 2025
group by c_typeaban
order by c_typeaban;
-- 3 lignes

-- solution 5 : fonctions analytiques
select distinct c_typeaban, count(*) over (partition by c_typeaban) as nb_par_type, count(*) over () as total_abandon from tour_abandon
where annee = 2025
order by c_typeaban;
-- 3 lignes

-- solution 6a : total en bas avec union
select c_typeaban, count(*) as nb from tour_abandon
where annee = 2025
group by c_typeaban
union
select 'TOTAL', count(*) from tour_abandon
where annee = 2025
order by nb, c_typeaban;
-- 4 lignes

-- solution 6b : total en bas avec rollup
select nvl(c_typeaban, 'TOTAL') as c_typeaban, count(*) as nb from tour_abandon
where annee = 2025
group by rollup (c_typeaban);
-- 4 lignes

/* 57 b) Réutiliser une des solutions précédentes pour afficher en plus le pourcentage
         d'abandons par type. */
select c_typeaban, nb_par_type, total_abandon, round(nb_par_type * 100 / total_abandon, 2) as pourcentage from vt_nb_aban, vt_nb_aban_total
order by c_typeaban;
-- 3 lignes

/* 58) Afficher les noms et prénoms des coureurs avec leur nombre de participations pour
       ceux ayant participé plus de 10 fois au tour. Trier par ordre décroissant. */
select cou.nom, cou.prenom, count(*) as nb_participations from tour_coureur cou
join tour_parti_coureur par on par.n_coureur = cou.n_coureur
group by cou.n_coureur, cou.nom, cou.prenom
having count(*) > 10
order by nb_participations desc;
-- 3 lignes

/* 59) Afficher les noms et prénoms des coureurs (avec le nombre de victoires) possédant le
       record du nombre de victoires d'étapes au tour de France. */
select cou.nom, cou.prenom, count(*) as nb_victoires from tour_coureur cou
join tour_temps tem on tem.n_coureur = cou.n_coureur
where tem.rang_arrivee = 1
group by cou.n_coureur, cou.nom, cou.prenom
having count(*) =
(
  select max(count(*)) from tour_temps
  where rang_arrivee = 1
  group by n_coureur
);
-- 1 ligne

/* 60) Donner la liste des coureurs ayant réalisé pour l'avant-dernière étape du Tour 2025
       un temps inférieur à la moyenne des temps de cette étape. Afficher le n° de ligne
       (rownum), toutes les caractéristiques de "coureur" et le temps réalisé. Trier en
       ordre croissant sur le temps d'arrivée. */
select rownum, res.* from
(
  select cou.*, tem.total_seconde from tour_coureur cou
  join tour_temps tem on tem.n_coureur = cou.n_coureur
  where tem.annee = 2025
  and tem.n_etape = (select max(n_etape) - 1 from tour_etape where annee = 2025)
  and tem.total_seconde <
  (
    select avg(total_seconde) from tour_temps
    where annee = 2025
    and n_etape = (select max(n_etape) - 1 from tour_etape where annee = 2025)
  )
  order by tem.total_seconde
) res;
-- 12 lignes
-- rownum est placé dans la requête externe : il numérote les lignes déjà triées.

/* 61a) Donner la liste des sponsors (n_equipe, n_sponsor et nom) et le nombre de coureurs
        par équipe ayant participé au Tour 1998. En faire une vue nommée v61_depart. */
create or replace view v61_depart as
select spo.n_equipe, spo.n_sponsor, spo.nom, count(*) as nb_depart from tour_parti_coureur par
join tour_sponsor spo on spo.n_equipe = par.n_equipe and spo.n_sponsor = par.n_sponsor
where par.annee = 1998
group by spo.n_equipe, spo.n_sponsor, spo.nom;

select * from v61_depart;
-- 4 lignes

/* 61b) Même chose pour les coureurs ayant terminé le Tour 1998 : vue v61_arrivee. */
create or replace view v61_arrivee as
select spo.n_equipe, spo.n_sponsor, spo.nom, count(*) as nb_arrivee from tour_parti_coureur par
join tour_sponsor spo on spo.n_equipe = par.n_equipe and spo.n_sponsor = par.n_sponsor
where par.annee = 1998
and par.n_coureur not in
(
  select n_coureur from tour_abandon
  where annee = 1998
)
group by spo.n_equipe, spo.n_sponsor, spo.nom;

select * from v61_arrivee;
-- 3 lignes

/* 61c) Même requête pour les coureurs n'ayant pas terminé le Tour 1998 : vue v61_abandon. */
create or replace view v61_abandon as
select spo.n_equipe, spo.n_sponsor, spo.nom, count(*) as nb_abandon from tour_parti_coureur par
join tour_sponsor spo on spo.n_equipe = par.n_equipe and spo.n_sponsor = par.n_sponsor
where par.annee = 1998
and par.n_coureur in
(
  select n_coureur from tour_abandon
  where annee = 1998
)
group by spo.n_equipe, spo.n_sponsor, spo.nom;

select * from v61_abandon;
-- 2 lignes

/* 61d) Utiliser les 3 vues pour obtenir le résultat suivant. Bien distinguer les départs,
        les arrivées et les abandons. */
-- jointures externes : une équipe peut n'avoir aucune arrivée ou aucun abandon
select dep.n_equipe, dep.n_sponsor, dep.nom, dep.nb_depart, nvl(arr.nb_arrivee, 0) as nb_arrivee, nvl(aba.nb_abandon, 0) as nb_abandon from v61_depart dep
left join v61_arrivee arr on arr.n_equipe = dep.n_equipe and arr.n_sponsor = dep.n_sponsor
left join v61_abandon aba on aba.n_equipe = dep.n_equipe and aba.n_sponsor = dep.n_sponsor
order by dep.nom;
-- 4 lignes

/* 61e) Même question mais avec l'affichage suivant : (une ligne par équipe et par
        catégorie : départ, arrivée, abandon). */
select nom, 'départ' as categorie, nb_depart as nombre from v61_depart
union
select nom, 'arrivée', nb_arrivee from v61_arrivee
union
select nom, 'abandon', nb_abandon from v61_abandon
order by 1, 2 desc;
-- 9 lignes

/* 61f) Quelle(s) sont la ou les équipes comportant le plus de coureurs à la fin du Tour
        1998 ? Il est possible de réutiliser la vue v61_arrivee. */
select * from v61_arrivee
where nb_arrivee =
(
  select max(nb_arrivee) from v61_arrivee
);
-- 1 ligne

/* 62a) Afficher le n° du coureur, le nom, le prénom, la somme des "total_seconde" et la
        différence (vt_temps_difference : bonifications et pénalités) pour les coureurs
        n'ayant pas abandonné en 2025. Classer par total_seconde. */
select cou.n_coureur, cou.nom, cou.prenom, sum(tem.total_seconde) as total_seconde, dif.difference from tour_coureur cou
join tour_temps tem on tem.n_coureur = cou.n_coureur
left join tour_temps_difference dif on dif.n_coureur = tem.n_coureur and dif.annee = tem.annee
where tem.annee = 2025
and cou.n_coureur not in
(
  select n_coureur from tour_abandon
  where annee = 2025
)
group by cou.n_coureur, cou.nom, cou.prenom, dif.difference
order by 4;
-- 18 lignes

/* 62b) Donner le temps total réalisé par les coureurs du Tour 2005 n'ayant pas abandonné.
        Afficher le n° du coureur, le nom, le prénom et le temps total réalisé en secondes
        (total_seconde + différence), colonne renommée "temps total". */
select cou.n_coureur, cou.nom, cou.prenom, sum(tem.total_seconde) + nvl(dif.difference, 0) as "temps total" from tour_coureur cou
join tour_temps tem on tem.n_coureur = cou.n_coureur
left join tour_temps_difference dif on dif.n_coureur = tem.n_coureur and dif.annee = tem.annee
where tem.annee = 2005
and cou.n_coureur not in
(
  select n_coureur from tour_abandon
  where annee = 2005
)
group by cou.n_coureur, cou.nom, cou.prenom, dif.difference
order by 4;
-- 12 lignes

-- option : les tricheurs (participation non valide, valide = 'R') sont remplacés par des tirets
select decode(par.valide, 'R', '------', to_char(cou.n_coureur)) as n_coureur, decode(par.valide, 'R', substr(cou.nom, 1, 2) || '----', cou.nom) as nom, cou.prenom, sum(tem.total_seconde) + nvl(dif.difference, 0) as "temps total" from tour_coureur cou
join tour_parti_coureur par on par.n_coureur = cou.n_coureur
join tour_temps tem on tem.n_coureur = par.n_coureur and tem.annee = par.annee
left join tour_temps_difference dif on dif.n_coureur = tem.n_coureur and dif.annee = tem.annee
where par.annee = 2005
and cou.n_coureur not in
(
  select n_coureur from tour_abandon
  where annee = 2005
)
group by par.valide, cou.n_coureur, cou.nom, cou.prenom, dif.difference
order by 4;
-- 12 lignes

/* 63) Afficher la liste des sponsors actuels des équipes encore existantes. */
select * from tour_sponsor
where (n_equipe, n_sponsor) in
(
  select n_equipe, max(n_sponsor) from tour_sponsor
  group by n_equipe
)
and n_equipe in
(
  select n_equipe from tour_equipe
  where annee_disparition is null
)
order by n_equipe;
-- 22 lignes

/* 64) Afficher les propriétés du dernier sponsor pour les équipes ayant eu plus de 6
       sponsors. Afficher également le nombre de dénominations que cette équipe a connues.
       Rappel : max <> count. Conseil : vue max_nb_sponsors. */
create or replace view max_nb_sponsors as
select n_equipe, count(*) as nb_sponsors, max(n_sponsor) as dernier_sponsor from tour_sponsor
group by n_equipe;

select spo.*, mns.nb_sponsors from tour_sponsor spo
join max_nb_sponsors mns on mns.n_equipe = spo.n_equipe and mns.dernier_sponsor = spo.n_sponsor
where mns.nb_sponsors > 6;
-- 1 ligne

/* 65) Afficher le premier sponsor et le dernier sponsor (actuel) des équipes encore
       existantes. */
select equ.n_equipe, pre.nom as premier_sponsor, pre.annee_sponsor as depuis, der.nom as dernier_sponsor, der.annee_sponsor as depuis_dernier from tour_equipe equ
join tour_sponsor pre on pre.n_equipe = equ.n_equipe
join tour_sponsor der on der.n_equipe = equ.n_equipe
where equ.annee_disparition is null
and pre.n_sponsor = (select min(n_sponsor) from tour_sponsor where n_equipe = equ.n_equipe)
and der.n_sponsor = (select max(n_sponsor) from tour_sponsor where n_equipe = equ.n_equipe)
order by equ.n_equipe;
-- 22 lignes

/* 66) Afficher les équipes ayant succédé à l'équipe 14 en respectant l'arborescence
       (requêtes hiérarchiques). */
select level, lpad(' ', 4 * (level - 1)) || n_eq_successeur as arborescence, n_equipe as predecesseur from tour_equ_succede
start with n_equipe = 14
connect by prior n_eq_successeur = n_equipe;
-- 4 lignes

/* 67) Méta questions */
/* a) Poser la question dont la réponse est la requête ci-dessous.
      Question : Pour le Tour 2025, afficher chaque nation (code CIO) avec le nombre de
      coureurs qui la représentaient, y compris les nations sans aucun coureur (0), classées
      du plus grand nombre de coureurs au plus petit. */
select nat.code_cio, count(*) as nb from tour_nation nat
join tour_app_nation app on app.code_cio = nat.code_cio
join tour_parti_coureur cou on cou.n_coureur = app.n_coureur
where annee = 2025
and annee between annee_debut and nvl(annee_fin, 3000)
group by nat.code_cio
union
select code_cio, 0 from tour_nation
where code_cio not in
(
  select code_cio from tour_app_nation
  join tour_parti_coureur using (n_coureur)
  where annee = 2025
  and annee between annee_debut and nvl(annee_fin, 3000)
)
order by nb desc;
-- 20 lignes

/* b) Poser la question dont la réponse est la requête ci-dessous.
      Question : Pour chaque année, afficher le nombre de coureurs qui disputaient leur
      premier Tour de France, de l'année la plus récente à la plus ancienne. */
select annee, count(*) as nb from tour_parti_coureur
join tour_coureur using (n_coureur)
where annee_prem = annee
group by annee
order by annee desc;
-- 13 lignes
