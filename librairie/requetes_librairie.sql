-- Librairie : mes requêtes SQL (Oracle)
-- Base : base_librairie.sql
-- Sous chaque requête j'ai noté le nombre de lignes que j'obtiens.


-- =============================================================================
--  1. Projection et restriction
-- =============================================================================

/* 1) Tous les clients (nom, prénom, ville, pays), triés par nom puis par prénom. */
select cl_nom, cl_prenom, cl_ville, cl_pays
from lib_client
order by cl_nom, cl_prenom;
-- 10 lignes

/* 2) Les différents genres de livres, sans doublon. */
select distinct li_genre
from lib_livre
order by li_genre;
-- 9 lignes

/* 3) Les livres vendus entre 10 et 25 euros, du plus cher au moins cher. */
select li_numero, li_titre, li_genre, li_prix_vente
from lib_livre
where li_prix_vente between 10 and 25
order by li_prix_vente desc;
-- 9 lignes

/* 4) Les livres qui n'ont pas de genre. */
select *
from lib_livre
where li_genre is null;
-- 2 lignes

/* 5) Pour chaque livre, la marge (prix de vente - prix d'achat) et le taux de marge
      en %, de la plus grosse marge à la plus petite. */
select li_numero, li_titre, li_prix_achat, li_prix_vente,
       li_prix_vente - li_prix_achat as marge,
       round((li_prix_vente - li_prix_achat) * 100 / li_prix_achat, 1) as taux_marge
from lib_livre
order by marge desc;
-- 20 lignes
-- Quand le prix d'achat est null, la marge est null aussi : n'importe quel calcul
-- avec null donne null.

/* 6) Les clients professionnels (type E) de CAEN ou de CHERBOURG. */
select *
from lib_client
where cl_ville in ('CAEN', 'CHERBOURG')
and cl_type = 'E';
-- 2 lignes

/* 7) Les livres dont le titre commence par C et contient IN. */
select *
from lib_livre
where li_titre like 'C%'
and li_titre like '%IN%';
-- 5 lignes


-- =============================================================================
--  2. Jointures
-- =============================================================================

/* 8) Les BD avec leur titre, leur numéro, leur nombre de pages et le nom de
      l'éditeur (je l'écris de deux façons). */
select l.li_titre, l.li_numero, l.li_pages, e.ed_nom
from lib_livre l
join lib_editeur e on e.ed_numero = l.ed_numero
where l.li_genre = 'BD'
order by l.li_numero;
-- 3 lignes

select li_titre, li_numero, li_pages, ed_nom
from lib_livre
join lib_editeur using (ed_numero)
where li_genre = 'BD'
order by li_numero;
-- 3 lignes

/* 9) Les clients qui ont passé au moins une commande (avec une sous-requête, puis
      avec une jointure). */
select *
from lib_client
where cl_numero in (select cl_numero from lib_commande)
order by cl_numero;
-- 8 lignes

-- avec la jointure il faut un distinct, sinon un client sort autant de fois qu'il a de commandes
select distinct c.*
from lib_client c
join lib_commande co on co.cl_numero = c.cl_numero
order by c.cl_numero;
-- 8 lignes

/* 10) Les livres commandés par des clients de CAEN : n° de commande, client, livre et
       quantité. */
select co.co_numero, c.cl_nom, l.li_numero, l.li_titre, lc.qte_cmdee
from lib_livre l
join lib_ligne_cde lc on lc.li_numero = l.li_numero
join lib_commande co on co.co_numero = lc.co_numero
join lib_client c on c.cl_numero = co.cl_numero
where c.cl_ville = 'CAEN'
order by co.co_numero, l.li_numero;
-- 14 lignes

/* 11) Tous les clients avec leurs n° de commande, même ceux qui n'ont jamais rien
       commandé. */
select c.cl_numero, c.cl_nom, co.co_numero
from lib_client c
left join lib_commande co on co.cl_numero = c.cl_numero
order by c.cl_numero, co.co_numero;
-- 14 lignes

/* 12) Chaque commande avec sa boutique (ville, gérant) et son client. */
select co.co_numero, co.co_date, b.bo_ville, b.bo_nom_gerant, c.cl_nom
from lib_commande co
join lib_boutique b on b.bo_numero = co.bo_numero
join lib_client c on c.cl_numero = co.cl_numero
order by co.co_date;
-- 12 lignes

/* 13) Tous les éditeurs avec leurs livres, même ceux qui n'ont aucun livre chez nous. */
select e.ed_numero, e.ed_nom, l.li_numero, l.li_titre
from lib_editeur e
left join lib_livre l on l.ed_numero = e.ed_numero
order by e.ed_numero, l.li_numero;
-- 21 lignes

/* 14) Auto-jointure : les paires de livres différents qui ont le même titre (chaque
       paire une seule fois). */
select l1.li_numero, l2.li_numero as li_numero_bis, l1.li_titre
from lib_livre l1
join lib_livre l2 on l2.li_titre = l1.li_titre
where l1.li_numero < l2.li_numero
order by l1.li_titre;
-- 2 lignes
-- J'ai mis < et pas <> : avec <> chaque paire sort deux fois (L01-L02 puis L02-L01).

/* 15) Auto-jointure : les gérants de boutique qui ont un homonyme. */
select distinct b1.bo_nom_gerant, b1.bo_prenom_gerant, b1.bo_ville
from lib_boutique b1
join lib_boutique b2 on b2.bo_nom_gerant = b1.bo_nom_gerant
where b1.bo_numero <> b2.bo_numero
order by b1.bo_nom_gerant;
-- 2 lignes


-- =============================================================================
--  3. Opérateurs ensemblistes
-- =============================================================================

/* 16) Les commandes pas encore livrées (avec not in, puis avec minus). */
select *
from lib_commande
where co_numero not in (select co_numero from lib_livraison)
order by co_numero;
-- 4 lignes

select co_numero from lib_commande
minus
select co_numero from lib_livraison;
-- 4 lignes

/* 17) Les villes où il y a à la fois un client et une boutique. */
select cl_ville as ville from lib_client
intersect
select bo_ville from lib_boutique;
-- 3 lignes

/* 18) Toutes les villes qu'on connaît (clients + boutiques), sans doublon puis avec
       les doublons. */
select cl_ville as ville from lib_client
union
select bo_ville from lib_boutique;
-- 8 lignes

select cl_ville as ville from lib_client
union all
select bo_ville from lib_boutique;
-- 14 lignes


-- =============================================================================
--  4. Vues
-- =============================================================================

/* 19) Deux vues livres + éditeurs. Dans v_livre_editeur1, ed_numero vient de
       lib_livre (on peut le modifier). Dans v_livre_editeur2, il vient de lib_editeur
       (on ne peut pas). */
create or replace view v_livre_editeur1 as
select e.ed_nom, l.ed_numero, l.li_numero, l.li_titre, l.li_genre, l.li_stock, l.li_prix_vente
from lib_livre l
join lib_editeur e on e.ed_numero = l.ed_numero;

create or replace view v_livre_editeur2 as
select e.ed_nom, e.ed_numero, l.li_numero, l.li_titre, l.li_genre, l.li_stock, l.li_prix_vente
from lib_livre l
join lib_editeur e on e.ed_numero = l.ed_numero;

select * from v_livre_editeur1 order by li_numero;
-- 20 lignes

-- pour voir quelles colonnes sont modifiables dans chaque vue
select table_name, column_name, updatable, insertable, deletable
from user_updatable_columns
where table_name like 'V_LIVRE_EDITEUR%'
and column_name like '%NUMERO%';
-- Dans la vue 1, ed_numero est modifiable parce qu'il vient de lib_livre (la table
-- « préservée par clé »). Dans la vue 2 il vient de lib_editeur, donc non.

/* 20) Avec v_livre_editeur1, les livres de l'éditeur ATLAS VOYAGES. */
select li_numero, li_titre, li_genre, li_prix_vente
from v_livre_editeur1
where ed_nom = 'ATLAS VOYAGES'
order by li_numero;
-- 3 lignes


-- =============================================================================
--  5. Sous-requêtes
-- =============================================================================

/* 21) Les livres achetés plus cher que le livre L04. */
select *
from lib_livre
where li_prix_achat > (select li_prix_achat from lib_livre where li_numero = 'L04')
order by li_prix_achat;
-- 3 lignes

/* 22) Les livres que personne n'a jamais commandés. */
select *
from lib_livre
where li_numero not in (select li_numero from lib_ligne_cde)
order by li_numero;
-- 2 lignes

/* 23) Les livres qui ont moins de pages que le L07 (avec une sous-requête, puis avec
       une auto-jointure). */
select *
from lib_livre
where li_pages < (select li_pages from lib_livre where li_numero = 'L07')
order by li_pages;
-- 1 ligne

select l1.*
from lib_livre l1
join lib_livre l2 on l1.li_pages < l2.li_pages
where l2.li_numero = 'L07'
order by l1.li_pages;
-- 1 ligne

/* 24) Le ou les livres les plus chers, sans max(). */
select *
from lib_livre
where li_prix_vente >= all (select li_prix_vente from lib_livre);
-- 1 ligne

/* 25) Les clients qui ont commandé au moins un livre de BULLES ET CASES, seulement
       avec des sous-requêtes (pas de jointure). */
select *
from lib_client
where cl_numero in
(
  select cl_numero
  from lib_commande
  where co_numero in
  (
    select co_numero
    from lib_ligne_cde
    where li_numero in
    (
      select li_numero
      from lib_livre
      where ed_numero in
      (
        select ed_numero
        from lib_editeur
        where ed_nom = 'BULLES ET CASES'
      )
    )
  )
)
order by cl_numero;
-- 4 lignes

/* 26) Requête synchronisée : les clients qui n'ont jamais commandé (not exists). */
select *
from lib_client c
where not exists
(
  select *
  from lib_commande co
  where co.cl_numero = c.cl_numero
);
-- 2 lignes

/* 27) Requête synchronisée : pour chaque éditeur, son ou ses livres les plus épais. */
select ed_numero, li_numero, li_titre, li_pages
from lib_livre l1
where li_pages =
(
  select max(li_pages)
  from lib_livre l2
  where l2.ed_numero = l1.ed_numero
)
order by ed_numero;
-- 6 lignes


-- =============================================================================
--  6. Expressions et fonctions
-- =============================================================================

/* 28) Les livres avec leur genre ('non classé' quand il est vide, avec nvl) et une
       catégorie de prix avec case : moins de 5 € 'petit prix', moins de 20 € 'moyen',
       sinon 'cher'. */
select li_numero, li_titre, nvl(li_genre, 'non classé') as genre,
       case
         when li_prix_vente < 5 then 'petit prix'
         when li_prix_vente < 20 then 'moyen'
         else 'cher'
       end as categorie
from lib_livre
order by li_numero;
-- 20 lignes

/* 29) Pour chaque commande : la date en JJ/MM/AAAA, le mois en toutes lettres et le
       nombre de jours passés depuis. */
select co_numero, to_char(co_date, 'DD/MM/YYYY') as date_commande,
       to_char(co_date, 'month') as mois,
       trunc(sysdate - co_date) as jours_ecoules
from lib_commande
order by co_date;
-- 12 lignes

/* 30) Les commandes du premier semestre 2025. */
select *
from lib_commande
where co_date between to_date('01/01/2025', 'DD/MM/YYYY') and to_date('30/06/2025', 'DD/MM/YYYY')
order by co_date;
-- 10 lignes

/* 31) Le délai de livraison en jours de chaque commande livrée, du plus long au plus
       court. */
select co.co_numero, co.co_date, lv.date_liv, lv.date_liv - co.co_date as delai_jours
from lib_commande co
join lib_livraison lv on lv.co_numero = co.co_numero
order by delai_jours desc;
-- 8 lignes

/* 32) Le nom complet des clients dans une seule colonne : prénom puis nom en
       majuscules. */
select cl_prenom || ' ' || upper(cl_nom) as client
from lib_client
order by cl_nom;
-- 10 lignes


-- =============================================================================
--  7. Group by et fonctions d'agrégat
-- =============================================================================

/* 33) Le nombre de livres par genre, avec une ligne TOTAL (rollup). Je ne compte pas
       les livres sans genre. */
select nvl(li_genre, 'TOTAL') as genre, count(*) as nb_livres
from lib_livre
where li_genre is not null
group by rollup (li_genre);
-- 9 lignes

/* 34) Le nombre de livres, et le prix de vente moyen, minimum et maximum. */
select count(*) as nb_livres, round(avg(li_prix_vente), 2) as prix_moyen,
       min(li_prix_vente) as prix_mini, max(li_prix_vente) as prix_maxi
from lib_livre;
-- 1 ligne

/* 35) Je compte les livres, les livres dont on connaît le prix d'achat et les
       éditeurs différents. Pourquoi ce n'est pas le même nombre ? */
select count(*) as nb_livres, count(li_prix_achat) as nb_avec_prix_achat,
       count(distinct ed_numero) as nb_editeurs
from lib_livre;
-- 1 ligne
-- count(*) compte toutes les lignes, alors que count(colonne) saute les null.

/* 36) Le nombre de commandes de chaque client, y compris ceux qui en ont 0. */
select c.cl_numero, c.cl_nom, count(co.co_numero) as nb_commandes
from lib_client c
left join lib_commande co on co.cl_numero = c.cl_numero
group by c.cl_numero, c.cl_nom
order by nb_commandes desc, c.cl_numero;
-- 10 lignes
-- count(co.co_numero) et pas count(*) : sinon un client sans commande compte pour 1.

/* 37) Le montant de chaque commande (quantité x prix unitaire). */
select co_numero, sum(qte_cmdee * prix_unitaire) as montant
from lib_ligne_cde
group by co_numero
order by montant desc;
-- 12 lignes

/* 38) Les clients qui ont commandé pour plus de 200 € en tout. */
select c.cl_numero, c.cl_nom, sum(lc.qte_cmdee * lc.prix_unitaire) as total_commande
from lib_client c
join lib_commande co on co.cl_numero = c.cl_numero
join lib_ligne_cde lc on lc.co_numero = co.co_numero
group by c.cl_numero, c.cl_nom
having sum(lc.qte_cmdee * lc.prix_unitaire) > 200
order by total_commande desc;
-- 4 lignes

/* 39) Pour chaque boutique : le nombre de commandes et le chiffre d'affaires. */
select b.bo_numero, b.bo_ville, count(distinct co.co_numero) as nb_commandes,
       sum(lc.qte_cmdee * lc.prix_unitaire) as chiffre_affaires
from lib_boutique b
join lib_commande co on co.bo_numero = b.bo_numero
join lib_ligne_cde lc on lc.co_numero = co.co_numero
group by b.bo_numero, b.bo_ville
order by chiffre_affaires desc;
-- 4 lignes

/* 40) Le ou les livres les plus commandés (en quantité totale). */
select l.li_numero, l.li_titre, sum(lc.qte_cmdee) as qte_totale
from lib_livre l
join lib_ligne_cde lc on lc.li_numero = l.li_numero
group by l.li_numero, l.li_titre
having sum(lc.qte_cmdee) =
(
  select max(sum(qte_cmdee))
  from lib_ligne_cde
  group by li_numero
);
-- 1 ligne

/* 41) Les lignes de commande pas livrées en entier, avec ce qu'il reste à livrer. */
select co_numero, li_numero, qte_cmdee, qte_livree, qte_cmdee - qte_livree as reste_a_livrer
from lib_ligne_cde
where qte_livree < qte_cmdee
order by co_numero, li_numero;
-- 8 lignes


-- =============================================================================
--  8. Mises à jour
-- =============================================================================

/* 42) J'ajoute un livre avec toutes ses colonnes, puis un deuxième avec seulement les
       colonnes obligatoires. Ensuite je réessaie d'ajouter le premier : ça doit
       planter à cause de la clé primaire. */
insert into lib_livre (li_numero, ed_numero, li_titre, li_pages, li_genre, li_stock, li_prix_achat, li_prix_vente)
values ('L21', 'E02', 'LE VENT DU LARGE', 250, 'ROMAN', 10, 8.00, 17.50);

insert into lib_livre (li_numero, ed_numero, li_titre)
values ('L22', 'E02', 'LE VENT DU LARGE');

-- erreur attendue : ORA-00001 (violation de PK_LIB_LIVRE)
insert into lib_livre (li_numero, ed_numero, li_titre, li_pages, li_genre, li_stock, li_prix_achat, li_prix_vente)
values ('L21', 'E02', 'LE VENT DU LARGE', 250, 'ROMAN', 10, 8.00, 17.50);

select *
from lib_livre
where li_numero in ('L21', 'L22');
-- 2 lignes

/* 43) J'augmente de 5 % le prix de vente des livres de l'éditeur E02. */
update lib_livre
set li_prix_vente = round(li_prix_vente * 1.05, 2)
where ed_numero = 'E02';

/* 44) Je supprime les deux livres ajoutés en 42, puis j'annule tout ce que j'ai fait
       depuis le dernier commit. */
delete from lib_livre
where li_numero in ('L21', 'L22');

rollback;
