-- Rallye des Sables : mes requêtes SQL (Oracle)
-- Base : base_rallye.sql
-- Sous chaque requête j'ai noté le nombre de lignes que j'obtiens.


-- =============================================================================
--  1. Projection et restriction
-- =============================================================================

/* 1) Les étapes numérotées de 5 à 10, toutes années confondues, avec le numéro,
      la ville de départ, la ville d'arrivée et les km. */
select n_etape, ville_depart, ville_arrivee, km
from ral_etape
where n_etape between 5 and 10
order by annee, n_etape;
-- 11 lignes

/* 2) Pareil mais seulement pour 2025. */
select n_etape, ville_depart, ville_arrivee, km
from ral_etape
where n_etape between 5 and 10
and annee = 2025
order by n_etape;
-- 6 lignes

/* 3) Les étapes de 2025 avant la 5 ou après la 10 (je l'ai fait de deux façons). */
-- avec un or (attention aux parenthèses, sinon le and ne s'applique qu'à la 2e condition)
select n_etape, ville_depart, ville_arrivee, km
from ral_etape
where (n_etape < 5 or n_etape > 10)
and annee = 2025
order by n_etape;
-- 15 lignes

-- avec not between
select n_etape, ville_depart, ville_arrivee, km
from ral_etape
where n_etape not between 5 and 10
and annee = 2025
order by n_etape;
-- 15 lignes

/* 4) Tous les prologues (type PRL) avec les pays et villes de départ/arrivée, les km,
      la vitesse moyenne, l'année et le type. Du plus court au plus long. */
select pays_depart, pays_arrivee, ville_depart, ville_arrivee,
       km, vitesse_moy, annee, code_type
from ral_etape
where code_type = 'PRL'
order by km;
-- 2 lignes

/* 5) En une seule requête, les étapes dont la ville de départ :
      - commence par M
      - ou finit par A
      - ou contient OU */
select *
from ral_etape
where ville_depart like 'M%'
or ville_depart like '%A'
or ville_depart like '%OU%'
order by annee, n_etape;
-- 26 lignes

/* 6) L'étape qui a eu lieu le 14 juillet 2025. */
select *
from ral_etape
where date_etape = to_date('14/07/2025', 'DD/MM/YYYY');
-- 1 ligne

/* 7) Les pilotes qui ont débuté en 2025 : prénom, nom et l'âge qu'ils avaient,
      du plus jeune au plus vieux. */
select prenom, nom, annee_debut - annee_naissance as age
from ral_pilote
where annee_debut = 2025
order by age;
-- 4 lignes

/* 8) Les sponsors arrivés après 1990 qui n'ont pas de sigle. */
select *
from ral_sponsor
where sigle is null
and annee_sponsor > 1990;
-- 8 lignes

/* 9) Les pilotes dont le nom commence par M, triés par prénom (A -> Z) puis par
      nom (Z -> A). */
select *
from ral_pilote
where nom like 'M%'
order by prenom asc, nom desc;
-- 6 lignes

/* 10) Dans ral_nationalite, les lignes des pays SUI, JPN et POL. */
select *
from ral_nationalite
where code_pays in ('SUI', 'JPN', 'POL');
-- 5 lignes


-- =============================================================================
--  2. Jointures
-- =============================================================================

/* 11) Les pilotes engagés en 2025 : nom, prénom, n° de voiture, n° d'écurie et
       n° de pilote. J'écris la jointure de 3 manières. */
-- 1re manière : l'ancienne écriture, la jointure dans le where
select p.nom, p.prenom, e.n_voiture, e.n_ecurie, p.n_pilote
from ral_pilote p, ral_engagement e
where p.n_pilote = e.n_pilote
and e.annee = 2025
order by e.n_voiture;
-- 24 lignes

-- 2e manière : join ... on
select p.nom, p.prenom, e.n_voiture, e.n_ecurie, p.n_pilote
from ral_pilote p
join ral_engagement e on e.n_pilote = p.n_pilote
where e.annee = 2025
order by e.n_voiture;
-- 24 lignes

-- 3e manière : join ... using (pas d'alias devant n_pilote du coup)
select nom, prenom, n_voiture, n_ecurie, n_pilote
from ral_pilote
join ral_engagement using (n_pilote)
where annee = 2025
order by n_voiture;
-- 24 lignes

/* 11bis) Même chose mais seulement pour les voitures 1 à 9. Pourquoi ce nombre de
          lignes ? */
select p.nom, p.prenom, e.n_voiture, e.n_ecurie, p.n_pilote
from ral_pilote p
join ral_engagement e on e.n_pilote = p.n_pilote
where e.annee = 2025
and e.n_voiture between 1 and 9
order by e.n_voiture;
-- 4 lignes
-- Les numéros de voiture vont par dizaine (1 à 4 pour la 1re écurie, 11 à 14 pour la
-- 2e...). Entre 1 et 9 il n'y a donc que les 4 pilotes de la première écurie.

/* 11ter) Pareil avec le nom du sponsor en plus. */
select p.nom, p.prenom, e.n_voiture, e.n_ecurie, p.n_pilote, s.nom as sponsor
from ral_pilote p
join ral_engagement e on e.n_pilote = p.n_pilote
join ral_sponsor s on s.n_ecurie = e.n_ecurie and s.n_sponsor = e.n_sponsor
where e.annee = 2025
and e.n_voiture between 1 and 9
order by e.n_voiture;
-- 4 lignes
-- Il faut joindre sur n_ecurie ET n_sponsor. Avec seulement n_ecurie, j'avais une ligne
-- pour chaque sponsor que l'écurie a eu dans son histoire.

/* 12) Les pilotes qui ont eu une voiture entre 28 et 49 et dont le nom contient ZI
       ou IZ : nom, prénom, écurie, sponsor et année, trié par année. */
select p.nom, p.prenom, e.n_ecurie, e.n_sponsor, e.annee
from ral_pilote p
join ral_engagement e on e.n_pilote = p.n_pilote
where e.n_voiture between 28 and 49
and (p.nom like '%ZI%' or p.nom like '%IZ%')
order by e.annee;
-- 7 lignes

/* 13) Les espoirs (25 ans ou moins) de 2025 : nom, prénom, n° de sponsor et
       d'écurie, triés par nom. */
select p.nom, p.prenom, e.n_sponsor, e.n_ecurie
from ral_pilote p
join ral_engagement e on e.n_pilote = p.n_pilote
where e.annee = 2025
and e.espoir = 'o'
order by p.nom;
-- 7 lignes

/* 13bis) Les mêmes avec le nom de leur sponsor, triés par sponsor puis par nom. */
select p.nom, p.prenom, s.nom as sponsor
from ral_pilote p
join ral_engagement e on e.n_pilote = p.n_pilote
join ral_sponsor s on s.n_ecurie = e.n_ecurie and s.n_sponsor = e.n_sponsor
where e.annee = 2025
and e.espoir = 'o'
order by s.nom, p.nom;
-- 7 lignes

/* 14) Tous les pilotes de 2025 et, pour ceux qui ont abandonné, la raison. Ceux qui
       sont allés au bout doivent apparaître aussi. */
select p.prenom, p.nom, a.code_abandon, t.libelle
from ral_pilote p
join ral_engagement e on e.n_pilote = p.n_pilote
left join ral_abandon a on a.n_pilote = e.n_pilote and a.annee = e.annee
left join ral_type_abandon t on t.code_abandon = a.code_abandon
where e.annee = 2025
order by p.nom, p.prenom;
-- 24 lignes
-- Je filtre sur e.annee et pas sur a.annee : avec a.annee = 2025 dans le where, les
-- pilotes sans abandon (a.annee est null pour eux) disparaissent.

/* 15) Les pilotes qui ont un homonyme (même nom de famille). */
select distinct p1.nom, p1.prenom
from ral_pilote p1
join ral_pilote p2 on p2.nom = p1.nom
where p1.n_pilote <> p2.n_pilote
order by p1.nom, p1.prenom;
-- 3 lignes

/* 16) Les étapes qui arrivent dans une ville où il y a eu plusieurs arrivées :
       n° d'étape, suffixe, départ, arrivée et année. */
select distinct e1.n_etape, e1.suffixe, e1.ville_depart, e1.ville_arrivee, e1.annee
from ral_etape e1
join ral_etape e2 on e2.ville_arrivee = e1.ville_arrivee
where e1.annee <> e2.annee
or e1.n_etape <> e2.n_etape
or e1.suffixe <> e2.suffixe
order by e1.ville_arrivee, e1.annee, e1.n_etape;
-- 29 lignes
-- Une étape c'est (annee, n_etape, suffixe). Il suffit qu'une des 3 colonnes change
-- pour être sûr que je ne compare pas l'étape avec elle-même.

/* 16bis) Même chose sans l'année. Pourquoi j'ai une ligne en moins ? */
select distinct e1.n_etape, e1.suffixe, e1.ville_depart, e1.ville_arrivee
from ral_etape e1
join ral_etape e2 on e2.ville_arrivee = e1.ville_arrivee
where e1.annee <> e2.annee
or e1.n_etape <> e2.n_etape
or e1.suffixe <> e2.suffixe
order by e1.ville_arrivee, e1.n_etape;
-- 28 lignes
-- L'étape 5 ERFOUD -> MARRAKECH existe en 1998 et en 2017. Sans l'année les deux
-- lignes sont identiques, donc le distinct en enlève une.

/* 17) Tous les motifs d'abandon, même ceux qui n'ont jamais servi. J'affiche le code
       de ral_abandon, celui de ral_type_abandon et le libellé (sans using). */
select a.code_abandon as code_abandon, t.code_abandon as code_type, t.libelle
from ral_abandon a
right join ral_type_abandon t on t.code_abandon = a.code_abandon
order by t.code_abandon;
-- 18 lignes

/* 18) Les pilotes de SAFRAN DUNES TEAM, ATLAS RALLY et SIERRA RALLY TEAM qui ont
       abandonné en 2025, avec la raison, l'écurie et ses managers. */
select p.nom as pilote, p.prenom, a.code_abandon, s.nom as ecurie,
       m1.nom as manager_1, m2.nom as manager_2, m3.nom as manager_3
from ral_abandon a
join ral_pilote p on p.n_pilote = a.n_pilote
join ral_engagement e on e.n_pilote = a.n_pilote and e.annee = a.annee
join ral_sponsor s on s.n_ecurie = e.n_ecurie and s.n_sponsor = e.n_sponsor
join ral_engagement_ecurie ee on ee.annee = e.annee and ee.n_ecurie = e.n_ecurie and ee.n_sponsor = e.n_sponsor
join ral_manager m1 on m1.n_manager = ee.n_manager1
left join ral_manager m2 on m2.n_manager = ee.n_manager2
left join ral_manager m3 on m3.n_manager = ee.n_manager3
where a.annee = 2025
and s.nom in ('SAFRAN DUNES TEAM', 'ATLAS RALLY', 'SIERRA RALLY TEAM')
order by s.nom, p.nom;
-- 3 lignes
-- left join pour les managers 2 et 3 parce que certaines écuries n'en ont qu'un.


-- =============================================================================
--  3. Opérateurs ensemblistes
-- =============================================================================

/* 19) Les motifs d'abandon qui n'ont jamais été utilisés. */
select code_abandon from ral_type_abandon
minus
select code_abandon from ral_abandon;
-- 4 lignes

/* 19bis) Pareil avec le libellé. */
select code_abandon, libelle
from ral_type_abandon
minus
select a.code_abandon, t.libelle
from ral_abandon a
join ral_type_abandon t on t.code_abandon = a.code_abandon;
-- 4 lignes

/* 20) Les villes qui ont été à la fois ville de départ et ville d'arrivée. */
select ville_depart as ville from ral_etape
intersect
select ville_arrivee from ral_etape;
-- 24 lignes

/* 21) Les numéros des pilotes qui ont fini l'édition 2025. */
select n_pilote from ral_engagement where annee = 2025
minus
select n_pilote from ral_abandon where annee = 2025;
-- 18 lignes

/* 22) Les pilotes qui ont participé à toutes les éditions depuis 2016 (les 10
       dernières). */
-- version avec les ensembles : je prends tous les pilotes et j'enlève ceux à qui il
-- manque au moins une année
select n_pilote
from ral_engagement
where annee > 2015
minus
select n_pilote
from
(
  select e.n_pilote, ed.annee
  from ral_engagement e, ral_edition ed
  where e.annee > 2015
  and ed.annee > 2015
  minus
  select n_pilote, annee
  from ral_engagement
);
-- 6 lignes

-- version avec group by (plus simple quand on a vu la partie 7)
select n_pilote
from ral_engagement
where annee > 2015
group by n_pilote
having count(*) = (select count(*) from ral_edition where annee > 2015);
-- 6 lignes

/* 23) Les écuries (n° écurie + n° sponsor) qui sont dans le top 10 mondial mais qui
       n'ont jamais couru le rallye, et celles classées après la 20e place qui l'ont
       couru. */
-- je fais les deux morceaux séparément puis je les colle avec un union
(
  select n_ecurie, n_sponsor from ral_classement_mondial where rang_mondial <= 10
  minus
  select n_ecurie, n_sponsor from ral_engagement_ecurie
)
union
(
  select n_ecurie, n_sponsor from ral_classement_mondial where rang_mondial > 20
  intersect
  select n_ecurie, n_sponsor from ral_engagement_ecurie
);
-- 8 lignes

/* 24) Les étapes 8 à 12 de 2025 avec les km et la vitesse moyenne dans la même
       colonne (une ligne pour chaque). Colonnes : n° d'étape, départ, arrivée,
       "mesure" et "valeur". */
select n_etape, ville_depart, ville_arrivee, 'km' as mesure, km as valeur
from ral_etape
where annee = 2025
and n_etape between 8 and 12
union
select n_etape, ville_depart, ville_arrivee, 'vitesse', vitesse_moy
from ral_etape
where annee = 2025
and n_etape between 8 and 12
order by 1, 4;
-- 10 lignes


-- =============================================================================
--  4. Vues
-- =============================================================================

/* 25) Une vue v_abandon_espoir avec les espoirs qui ont abandonné, toutes années
       confondues (année, écurie, sponsor, pilote, n° de voiture). */
create or replace view v_abandon_espoir as
select e.annee, e.n_ecurie, e.n_sponsor, e.n_pilote, e.n_voiture
from ral_engagement e
join ral_abandon a on a.n_pilote = e.n_pilote and a.annee = e.annee
where e.espoir = 'o';

/* 26) Quelques tests sur la vue et sur le dictionnaire Oracle. */
-- la structure de la vue
desc v_abandon_espoir;

-- trier par n° de pilote, puis par n° de colonne (la 4e c'est n_pilote)
select * from v_abandon_espoir order by n_pilote;
-- 9 lignes

select * from v_abandon_espoir order by 4;
-- 9 lignes

-- piège : rownum est donné AVANT le tri, donc je récupère 4 lignes au hasard puis je les trie
select *
from v_abandon_espoir
where rownum < 5
order by n_pilote;
-- 4 lignes

-- mes vues et les types d'objets de mon schéma
select * from user_views;
select distinct object_type from user_objects;

-- renommer la vue
rename v_abandon_espoir to v_espoir_abandon;

select * from v_espoir_abandon;
-- 9 lignes

/* 27) Avec la vue, les espoirs qui ont abandonné en 2025 : nom, prénom, n° de voiture
       et sponsor. */
select p.nom, p.prenom, v.n_voiture, s.nom as sponsor
from v_espoir_abandon v
join ral_pilote p on p.n_pilote = v.n_pilote
join ral_sponsor s on s.n_ecurie = v.n_ecurie and s.n_sponsor = v.n_sponsor
where v.annee = 2025
order by p.nom;
-- 4 lignes

/* 28) Je garde les requêtes 13 et 14 dans deux vues, v_q13 et v_q14. */
create or replace view v_q13 as
select p.nom, p.prenom, e.n_sponsor, e.n_ecurie
from ral_pilote p
join ral_engagement e on e.n_pilote = p.n_pilote
where e.annee = 2025
and e.espoir = 'o';

create or replace view v_q14 as
select p.prenom, p.nom, a.code_abandon, t.libelle
from ral_pilote p
join ral_engagement e on e.n_pilote = p.n_pilote
left join ral_abandon a on a.n_pilote = e.n_pilote and a.annee = e.annee
left join ral_type_abandon t on t.code_abandon = a.code_abandon
where e.annee = 2025;

/* 29) Je retrouve les résultats de la 13 et de la 14 avec les vues. */
select * from v_q13 order by nom;
-- 7 lignes

select * from v_q14 order by nom, prenom;
-- 24 lignes

/* 30) Tout v_q13 plus le nom du sponsor, trié par sponsor puis par nom. */
select v.*, s.nom as sponsor
from v_q13 v
join ral_sponsor s on s.n_ecurie = v.n_ecurie and s.n_sponsor = v.n_sponsor
order by s.nom, v.nom;
-- 7 lignes


-- =============================================================================
--  5. Sous-requêtes
-- =============================================================================

/* 31) Les pilotes qui ont abandonné en 2025, triés par année de naissance. */
select *
from ral_pilote
where n_pilote in
(
  select n_pilote from ral_abandon where annee = 2025
)
order by annee_naissance;
-- 6 lignes

/* 32) Les pilotes qui n'ont couru aucune édition depuis 2001. */
select *
from ral_pilote
where n_pilote not in
(
  select n_pilote from ral_engagement where annee >= 2001
)
order by nom, prenom;
-- 15 lignes

/* 33) Les pilotes qui ont couru pour GRANIT-NRT OFFROAD (nom et prénom). */
select nom, prenom
from ral_pilote
where n_pilote in
(
  select n_pilote
  from ral_engagement
  where (n_ecurie, n_sponsor) in
  (
    select n_ecurie, n_sponsor
    from ral_sponsor
    where nom = 'GRANIT-NRT OFFROAD'
  )
)
order by nom;
-- 4 lignes

/* 34) Pareil avec leur nationalité. */
select p.nom, p.prenom, n.code_pays
from ral_pilote p
join ral_nationalite n on n.n_pilote = p.n_pilote
where p.n_pilote in
(
  select n_pilote
  from ral_engagement
  where (n_ecurie, n_sponsor) in
  (
    select n_ecurie, n_sponsor
    from ral_sponsor
    where nom = 'GRANIT-NRT OFFROAD'
  )
)
order by p.nom;
-- 4 lignes

/* 35) Les pilotes de 2025 qui n'ont pas abandonné. */
select *
from ral_pilote
where n_pilote in (select n_pilote from ral_engagement where annee = 2025)
and n_pilote not in (select n_pilote from ral_abandon where annee = 2025)
order by nom;
-- 18 lignes

/* 36) Les pilotes inscrits qui n'ont jamais pris le départ : ils ont un abandon
       mais aucun chrono cette année-là. */
select *
from ral_pilote
where n_pilote in
(
  select n_pilote
  from ral_abandon
  where (n_pilote, annee) not in (select n_pilote, annee from ral_chrono)
);
-- 1 ligne

/* 37) Les pilotes classés de la 1re à la 20e place sur l'étape 1 de 2025, par ordre
       alphabétique. */
select *
from ral_pilote
where n_pilote in
(
  select n_pilote
  from ral_chrono
  where annee = 2025
  and n_etape = 1
  and rang between 1 and 20
)
order by nom;
-- 20 lignes

/* 38) Les pilotes qui ont gagné au moins une étape en 2005, avec leur sponsor. */
select p.nom, p.prenom, s.nom as sponsor
from ral_pilote p
join ral_engagement e on e.n_pilote = p.n_pilote
join ral_sponsor s on s.n_ecurie = e.n_ecurie and s.n_sponsor = e.n_sponsor
where e.annee = 2005
and p.n_pilote in (select n_pilote from ral_chrono where annee = 2005 and rang = 1)
order by p.nom;
-- 4 lignes

/* 38bis) Seulement le nom des sponsors. Comme j'affiche une seule table, pas de
          jointure : que des sous-requêtes. */
select nom
from ral_sponsor
where (n_ecurie, n_sponsor) in
(
  select n_ecurie, n_sponsor
  from ral_engagement
  where annee = 2005
  and n_pilote in (select n_pilote from ral_chrono where annee = 2005 and rang = 1)
);
-- 3 lignes

/* 39) Le sponsor du pilote qui a gagné une étape partie de FES, avec 3 sous-requêtes
       imbriquées. */
select *
from ral_sponsor
where (n_ecurie, n_sponsor) in
(
  select n_ecurie, n_sponsor
  from ral_engagement
  where (n_pilote, annee) in
  (
    select n_pilote, annee
    from ral_chrono
    where rang = 1
    and (annee, n_etape, suffixe) in
    (
      select annee, n_etape, suffixe
      from ral_etape
      where ville_depart = 'FES'
    )
  )
);
-- 2 lignes

/* 40) La ou les plus longues étapes de 2025, sans max(). */
select *
from ral_etape
where annee = 2025
and km >= all (select km from ral_etape where annee = 2025);
-- 2 lignes

/* 41) L'étape de 2025 avec la vitesse moyenne la plus basse (parmi celles qui sont
       renseignées), toujours sans fonction d'agrégat. */
select *
from ral_etape
where annee = 2025
and vitesse_moy <= all
(
  select vitesse_moy
  from ral_etape
  where annee = 2025
  and vitesse_moy is not null
);
-- 1 ligne
-- Sans le "is not null", la comparaison avec la valeur null donne "inconnu" et le
-- <= all ne renvoie plus rien du tout.

/* 42) Le nombre de jours entre la première et la dernière étape de 2025. */
select (select date_etape from ral_etape where annee = 2025 and n_etape = 21)
     - (select date_etape from ral_etape where annee = 2025 and n_etape = 1) as nb_jours
from dual;
-- 1 ligne

/* 42bis) Le nombre de jours de course en 2025. */
select count(distinct date_etape) as jours_de_course
from ral_etape
where annee = 2025;
-- 1 ligne

/* 43) Les vainqueurs d'étape de 2017 qui ont la nationalité du pays d'où partait
       l'étape gagnée. Une requête principale + 3 sous-requêtes imbriquées. Pourquoi
       il faut synchroniser ? */
-- 1re solution : pilote -> nationalité -> étape -> chrono
select *
from ral_pilote p
where n_pilote in
(
  select n_pilote
  from ral_nationalite n
  where 2017 between annee_debut and nvl(annee_fin, 3000)
  and code_pays in
  (
    select pays_depart
    from ral_etape
    where (annee, n_etape, suffixe) in
    (
      select annee, n_etape, suffixe
      from ral_chrono c
      where c.annee = 2017
      and c.rang = 1
      and c.n_pilote = n.n_pilote
    )
  )
);
-- 3 lignes

-- 2e solution : pilote -> chrono -> étape -> nationalité
select *
from ral_pilote p
where n_pilote in
(
  select n_pilote
  from ral_chrono c
  where c.annee = 2017
  and c.rang = 1
  and (annee, n_etape, suffixe) in
  (
    select annee, n_etape, suffixe
    from ral_etape
    where pays_depart in
    (
      select code_pays
      from ral_nationalite n
      where n.n_pilote = c.n_pilote
      and 2017 between annee_debut and nvl(annee_fin, 3000)
    )
  )
);
-- 3 lignes
-- Sans "c.n_pilote = n.n_pilote", je garderais n'importe quel pilote dont le pays a vu
-- partir une étape gagnée par quelqu'un d'autre. La synchro sert à vérifier que c'est
-- bien LE vainqueur de l'étape qui a la bonne nationalité.

/* 44) Les pilotes qui ont gagné au moins une étape en 2025, avec exists. */
select *
from ral_pilote p
where exists
(
  select *
  from ral_chrono c
  where c.n_pilote = p.n_pilote
  and c.annee = 2025
  and c.rang = 1
)
order by nom;
-- 13 lignes

/* 45) Les 5 premiers pilotes dans l'ordre alphabétique inversé. */
-- je trie d'abord dans la sous-requête, sinon rownum prend 5 lignes au hasard
select *
from (select * from ral_pilote order by nom desc)
where rownum <= 5;
-- 5 lignes


-- =============================================================================
--  6. Expressions et fonctions
-- =============================================================================

/* 46) Les étapes de 1988 avec le numéro, les km et le type écrit en entier
       (PRL = Prologue, SPE = Spéciale chronométrée, MAR = Étape marathon,
       LIG = Étape de liaison). D'abord avec decode, puis avec case. */
select n_etape, km,
       decode(code_type, 'PRL', 'Prologue',
                         'SPE', 'Spéciale chronométrée',
                         'MAR', 'Étape marathon',
                         'LIG', 'Étape de liaison') as type_etape
from ral_etape
where annee = 1988
order by n_etape;
-- 6 lignes

select n_etape, km,
       case code_type
         when 'PRL' then 'Prologue'
         when 'SPE' then 'Spéciale chronométrée'
         when 'MAR' then 'Étape marathon'
         when 'LIG' then 'Étape de liaison'
       end as type_etape
from ral_etape
where annee = 1988
order by n_etape;
-- 6 lignes

/* 47) Les prénoms qui ont un é, î, ù ou ô, en texte normal et en hexadécimal
       (avec dump). */
select prenom, dump(prenom, 16) as prenom_hexa
from ral_pilote
where prenom like '%é%'
or prenom like '%î%'
or prenom like '%ù%'
or prenom like '%ô%'
order by prenom;
-- 11 lignes

/* 48) Les étapes qui ne se sont pas courues en juillet. */
select *
from ral_etape
where to_char(date_etape, 'MM') <> '07';
-- 1 ligne


-- =============================================================================
--  7. Group by et fonctions d'agrégat
-- =============================================================================

/* 49a) Combien il y a de pilotes dans la base. */
select count(*) as nb_pilotes
from ral_pilote;
-- 1 ligne

/* 49b) Le même nombre, mais en partant de ral_engagement. */
select count(distinct n_pilote) as nb_pilotes
from ral_engagement;
-- 1 ligne

/* 50) Le pilote qui a le nom le plus long. */
select nom, prenom
from ral_pilote
where length(nom) = (select max(length(nom)) from ral_pilote);
-- 1 ligne

/* 51) Combien de pilotes ont fini l'édition 2025. */
select count(*) as nb_arrivees
from ral_engagement
where annee = 2025
and n_pilote not in (select n_pilote from ral_abandon where annee = 2025);
-- 1 ligne

/* 52) Le chrono le plus long, le plus court et le chrono moyen (arrondi) de l'étape 1
       de 2025. */
select max(total_secondes) as maxi, min(total_secondes) as mini,
       round(avg(total_secondes)) as moyenne
from ral_chrono
where annee = 2025
and n_etape = 1;
-- 1 ligne

/* 53) Pour chaque édition : l'année, le dernier jour, le premier jour, le nombre de
       jours entre les deux, le nombre d'étapes et les jours de repos. */
select e.annee, max(e.date_etape) as dernier_jour, min(e.date_etape) as premier_jour,
       max(e.date_etape) - min(e.date_etape) as nb_jours,
       count(*) as nb_etapes, ed.jours_repos
from ral_etape e
join ral_edition ed on ed.annee = e.annee
group by e.annee, ed.jours_repos
order by e.annee;
-- 5 lignes

/* 54) Le plus long et le plus court chrono sur une étape de 2025, en heures et
       minutes. */
select trunc(max(total_secondes) / 3600) || ' h '
       || lpad(trunc(mod(max(total_secondes), 3600) / 60), 2, '0') || ' min' as plus_long,
       trunc(min(total_secondes) / 3600) || ' h '
       || lpad(trunc(mod(min(total_secondes), 3600) / 60), 2, '0') || ' min' as plus_court
from ral_chrono
where annee = 2025;
-- 1 ligne

/* 55) Combien de motifs d'abandon différents ont vraiment servi. */
select count(distinct code_abandon) as nb_motifs
from ral_abandon;
-- 1 ligne

/* 56) Les abandons de 2025 par étape et par motif, triés par étape. */
select annee, n_etape, code_abandon, count(*) as nb_abandons
from ral_abandon
where annee = 2025
group by annee, n_etape, code_abandon
order by n_etape;
-- 6 lignes

/* 57a) Pour 2025 : chaque motif, le nombre d'abandons pour ce motif et le total des
        abandons. Toutes les solutions possibles. */
-- solution 1 : je fais deux vues puis un produit cartésien entre les deux
create or replace view v_total_abandons as
select count(*) as total_abandons
from ral_abandon
where annee = 2025;

create or replace view v_abandons_par_motif as
select code_abandon, count(*) as nb_par_motif
from ral_abandon
where annee = 2025
group by code_abandon;

select code_abandon, nb_par_motif, total_abandons
from v_abandons_par_motif, v_total_abandons
order by code_abandon;
-- 4 lignes

-- solution 2 : je remplace la vue v_abandons_par_motif par sa requête
select code_abandon, count(*) as nb_par_motif, total_abandons
from ral_abandon, v_total_abandons
where annee = 2025
group by code_abandon, total_abandons
order by code_abandon;
-- 4 lignes

-- solution 3 : la vue v_total_abandons remplacée par une sous-requête dans le from
select code_abandon, count(*) as nb_par_motif, total_abandons
from ral_abandon,
     (select count(*) as total_abandons from ral_abandon where annee = 2025)
where annee = 2025
group by code_abandon, total_abandons
order by code_abandon;
-- 4 lignes

-- solution 4 : la sous-requête directement dans le select
select code_abandon, count(*) as nb_par_motif,
       (select count(*) from ral_abandon where annee = 2025) as total_abandons
from ral_abandon
where annee = 2025
group by code_abandon
order by code_abandon;
-- 4 lignes

-- solution 5 : fonctions analytiques (over)
select distinct code_abandon,
       count(*) over (partition by code_abandon) as nb_par_motif,
       count(*) over () as total_abandons
from ral_abandon
where annee = 2025
order by code_abandon;
-- 4 lignes

-- solution 6a : le total sur une ligne à part en bas, avec union
select code_abandon, count(*) as nb
from ral_abandon
where annee = 2025
group by code_abandon
union
select 'TOTAL', count(*)
from ral_abandon
where annee = 2025
order by nb, code_abandon;
-- 5 lignes

-- solution 6b : pareil avec rollup
select nvl(code_abandon, 'TOTAL') as code_abandon, count(*) as nb
from ral_abandon
where annee = 2025
group by rollup (code_abandon);
-- 5 lignes

/* 57b) Je reprends une des solutions et j'ajoute le pourcentage de chaque motif. */
select code_abandon, nb_par_motif, total_abandons,
       round(nb_par_motif * 100 / total_abandons, 1) as pourcentage
from v_abandons_par_motif, v_total_abandons
order by code_abandon;
-- 4 lignes

/* 58) Les pilotes qui ont plus de 10 participations, du plus fidèle au moins fidèle. */
select p.nom, p.prenom, count(*) as nb_participations
from ral_pilote p
join ral_engagement e on e.n_pilote = p.n_pilote
group by p.n_pilote, p.nom, p.prenom
having count(*) > 10
order by nb_participations desc;
-- 3 lignes

/* 59) Le ou les pilotes qui ont le record de victoires d'étape, avec ce nombre. */
select p.nom, p.prenom, count(*) as nb_victoires
from ral_pilote p
join ral_chrono c on c.n_pilote = p.n_pilote
where c.rang = 1
group by p.n_pilote, p.nom, p.prenom
having count(*) =
(
  select max(count(*))
  from ral_chrono
  where rang = 1
  group by n_pilote
);
-- 1 ligne

/* 60) Les pilotes plus rapides que la moyenne sur l'avant-dernière étape de 2025 :
       un numéro de ligne (rownum), toutes les infos du pilote et son chrono, du plus
       rapide au plus lent. */
select rownum, r.*
from
(
  select p.*, c.total_secondes
  from ral_pilote p
  join ral_chrono c on c.n_pilote = p.n_pilote
  where c.annee = 2025
  and c.n_etape = (select max(n_etape) - 1 from ral_etape where annee = 2025)
  and c.total_secondes <
  (
    select avg(total_secondes)
    from ral_chrono
    where annee = 2025
    and n_etape = (select max(n_etape) - 1 from ral_etape where annee = 2025)
  )
  order by c.total_secondes
) r;
-- 9 lignes
-- Je mets le rownum dans la requête du dessus pour qu'il numérote des lignes déjà triées.

/* 61a) Pour 1998 : chaque sponsor engagé (écurie, sponsor, nom) et combien de pilotes
        il avait au départ. Je le mets dans une vue v61_depart. */
create or replace view v61_depart as
select s.n_ecurie, s.n_sponsor, s.nom, count(*) as nb_depart
from ral_engagement e
join ral_sponsor s on s.n_ecurie = e.n_ecurie and s.n_sponsor = e.n_sponsor
where e.annee = 1998
group by s.n_ecurie, s.n_sponsor, s.nom;

select * from v61_depart;
-- 4 lignes

/* 61b) Pareil pour ceux qui sont arrivés au bout : vue v61_arrivee. */
create or replace view v61_arrivee as
select s.n_ecurie, s.n_sponsor, s.nom, count(*) as nb_arrivee
from ral_engagement e
join ral_sponsor s on s.n_ecurie = e.n_ecurie and s.n_sponsor = e.n_sponsor
where e.annee = 1998
and e.n_pilote not in (select n_pilote from ral_abandon where annee = 1998)
group by s.n_ecurie, s.n_sponsor, s.nom;

select * from v61_arrivee;
-- 3 lignes

/* 61c) Pareil pour ceux qui ont abandonné : vue v61_abandon. */
create or replace view v61_abandon as
select s.n_ecurie, s.n_sponsor, s.nom, count(*) as nb_abandon
from ral_engagement e
join ral_sponsor s on s.n_ecurie = e.n_ecurie and s.n_sponsor = e.n_sponsor
where e.annee = 1998
and e.n_pilote in (select n_pilote from ral_abandon where annee = 1998)
group by s.n_ecurie, s.n_sponsor, s.nom;

select * from v61_abandon;
-- 2 lignes

/* 61d) Avec les 3 vues : une ligne par sponsor avec les départs, les arrivées et les
        abandons. */
select d.n_ecurie, d.n_sponsor, d.nom, d.nb_depart,
       nvl(ar.nb_arrivee, 0) as nb_arrivee,
       nvl(ab.nb_abandon, 0) as nb_abandon
from v61_depart d
left join v61_arrivee ar on ar.n_ecurie = d.n_ecurie and ar.n_sponsor = d.n_sponsor
left join v61_abandon ab on ab.n_ecurie = d.n_ecurie and ab.n_sponsor = d.n_sponsor
order by d.nom;
-- 4 lignes
-- left join parce qu'un sponsor peut n'avoir aucune arrivée (ou aucun abandon), et
-- nvl pour afficher 0 au lieu de rien.

/* 61e) Les mêmes chiffres mais à la verticale : une ligne par sponsor et par
        catégorie (départ, arrivée, abandon). */
select nom, 'départ' as categorie, nb_depart as nombre from v61_depart
union
select nom, 'arrivée', nb_arrivee from v61_arrivee
union
select nom, 'abandon', nb_abandon from v61_abandon
order by 1, 2 desc;
-- 9 lignes

/* 61f) Le ou les sponsors qui avaient le plus de pilotes à l'arrivée en 1998. */
select *
from v61_arrivee
where nb_arrivee = (select max(nb_arrivee) from v61_arrivee);
-- 1 ligne

/* 62a) Les pilotes de 2025 qui n'ont pas abandonné : n°, nom, prénom, total de leurs
        chronos en secondes et leur pénalité s'ils en ont une. Trié par total. */
select p.n_pilote, p.nom, p.prenom, sum(c.total_secondes) as total_secondes,
       pe.secondes as penalite
from ral_pilote p
join ral_chrono c on c.n_pilote = p.n_pilote
left join ral_penalite pe on pe.n_pilote = c.n_pilote and pe.annee = c.annee
where c.annee = 2025
and p.n_pilote not in (select n_pilote from ral_abandon where annee = 2025)
group by p.n_pilote, p.nom, p.prenom, pe.secondes
order by 4;
-- 18 lignes

/* 62b) Le classement final de 2005 (sans les abandons) : n°, nom, prénom et le
        "temps final" = total des chronos + pénalité. */
select p.n_pilote, p.nom, p.prenom,
       sum(c.total_secondes) + nvl(pe.secondes, 0) as "temps final"
from ral_pilote p
join ral_chrono c on c.n_pilote = p.n_pilote
left join ral_penalite pe on pe.n_pilote = c.n_pilote and pe.annee = c.annee
where c.annee = 2005
and p.n_pilote not in (select n_pilote from ral_abandon where annee = 2005)
group by p.n_pilote, p.nom, p.prenom, pe.secondes
order by 4;
-- 12 lignes

-- en bonus : je cache les pilotes disqualifiés après coup (valide = 'N') avec des tirets
select decode(e.valide, 'N', '------', to_char(p.n_pilote)) as n_pilote,
       decode(e.valide, 'N', substr(p.nom, 1, 2) || '----', p.nom) as nom,
       p.prenom,
       sum(c.total_secondes) + nvl(pe.secondes, 0) as "temps final"
from ral_pilote p
join ral_engagement e on e.n_pilote = p.n_pilote
join ral_chrono c on c.n_pilote = e.n_pilote and c.annee = e.annee
left join ral_penalite pe on pe.n_pilote = c.n_pilote and pe.annee = c.annee
where e.annee = 2005
and p.n_pilote not in (select n_pilote from ral_abandon where annee = 2005)
group by e.valide, p.n_pilote, p.nom, p.prenom, pe.secondes
order by 4;
-- 12 lignes


-- =============================================================================
--  8. Pour aller plus loin
-- =============================================================================

/* 63) Le sponsor actuel de chaque écurie qui existe encore. */
select *
from ral_sponsor
where (n_ecurie, n_sponsor) in (select n_ecurie, max(n_sponsor) from ral_sponsor group by n_ecurie)
and n_ecurie in (select n_ecurie from ral_ecurie where annee_disparition is null)
order by n_ecurie;
-- 22 lignes

/* 64) Pour les écuries qui ont eu plus de 6 sponsors : les infos du dernier sponsor
       et le nombre de noms qu'elles ont portés. (max et count c'est pas pareil !) */
-- je passe par une vue avec le nombre de sponsors et le dernier de chaque écurie
create or replace view v_nb_sponsors as
select n_ecurie, count(*) as nb_sponsors, max(n_sponsor) as dernier_sponsor
from ral_sponsor
group by n_ecurie;

select s.*, v.nb_sponsors
from ral_sponsor s
join v_nb_sponsors v on v.n_ecurie = s.n_ecurie and v.dernier_sponsor = s.n_sponsor
where v.nb_sponsors > 6;
-- 1 ligne

/* 65) Le premier et le dernier sponsor de chaque écurie encore active. */
select ec.n_ecurie, pr.nom as premier_sponsor, pr.annee_sponsor as depuis,
       de.nom as dernier_sponsor, de.annee_sponsor as depuis_dernier
from ral_ecurie ec
join ral_sponsor pr on pr.n_ecurie = ec.n_ecurie
join ral_sponsor de on de.n_ecurie = ec.n_ecurie
where ec.annee_disparition is null
and pr.n_sponsor = (select min(n_sponsor) from ral_sponsor where n_ecurie = ec.n_ecurie)
and de.n_sponsor = (select max(n_sponsor) from ral_sponsor where n_ecurie = ec.n_ecurie)
order by ec.n_ecurie;
-- 22 lignes

/* 66) L'arbre des écuries qui ont pris la suite de l'écurie 14 (requête
       hiérarchique). */
select level, lpad(' ', 4 * (level - 1)) || n_ecurie_successeur as arborescence,
       n_ecurie as predecesseur
from ral_ecurie_succede
start with n_ecurie = 14
connect by prior n_ecurie_successeur = n_ecurie;
-- 4 lignes

/* 67) Ici c'est l'inverse : on a la requête et il faut retrouver la question. */
/* 67a) Ma réponse : pour l'édition 2025, combien de pilotes représentaient chaque
        pays, en comptant aussi les pays qui n'avaient personne (0) ? Classé du plus
        grand nombre au plus petit. */
select pa.code_pays, count(*) as nb
from ral_pays pa
join ral_nationalite n on n.code_pays = pa.code_pays
join ral_engagement e on e.n_pilote = n.n_pilote
where e.annee = 2025
and e.annee between n.annee_debut and nvl(n.annee_fin, 3000)
group by pa.code_pays
union
select code_pays, 0
from ral_pays
where code_pays not in
(
  select n.code_pays
  from ral_nationalite n
  join ral_engagement e on e.n_pilote = n.n_pilote
  where e.annee = 2025
  and e.annee between n.annee_debut and nvl(n.annee_fin, 3000)
)
order by nb desc;
-- 21 lignes

/* 67b) Ma réponse : pour chaque édition, combien de pilotes y faisaient leur tout
        premier rallye ? De la plus récente à la plus ancienne. */
select annee, count(*) as nb
from ral_engagement
join ral_pilote using (n_pilote)
where annee_debut = annee
group by annee
order by annee desc;
-- 13 lignes
