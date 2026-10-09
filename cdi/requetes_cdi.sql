-- -----------------------------------------------------------------------------
-- CDI : magasin de fournitures de bureau
-- Base utilisée : ma base BUR_* (base_cdi.sql), pas la base du prof.
--   cdi_xxx  ->  bur_xxx   (mêmes colonnes, voir MLD.pdf)
-- Énoncés : l'archive ne contient pas la feuille d'exercices CDI. Les questions
-- 5.5.x / 5.7.x reprennent la numérotation de mes réponses (perso4.sql) ; les autres
-- suivent les chapitres du cours (2-cours_sql.pdf) dans le même ordre que le TDF.
-- Syntaxe Oracle. Sous chaque requête : nombre de lignes obtenues sur ma base.
-- -----------------------------------------------------------------------------


-- =============================================================================
-- Projection et restriction
-- =============================================================================

/* 1) Afficher le nom, la localité et le pays de tous les clients, classés par nom puis
      par prénom. */
select cl_nom, cl_prenom, cl_localite, cl_pays from bur_client
order by cl_nom, cl_prenom;
-- 10 lignes

/* 2) Afficher les différentes couleurs d'articles (sans doublon). */
select distinct ar_couleur from bur_article
order by ar_couleur;
-- 7 lignes

/* 3) Afficher les articles dont le prix de vente est compris entre 2 et 10 euros, du plus
      cher au moins cher. */
select ar_numero, ar_nom, ar_couleur, ar_pv from bur_article
where ar_pv between 2 and 10
order by ar_pv desc;
-- 7 lignes

/* 4) Afficher les articles dont la couleur n'est pas renseignée. */
select * from bur_article
where ar_couleur is null;
-- 2 lignes

/* 5) Afficher pour chaque article sa marge unitaire (prix de vente - prix d'achat) et son
      taux de marge en %. */
select ar_numero, ar_nom, ar_pa, ar_pv, ar_pv - ar_pa as marge, round((ar_pv - ar_pa) * 100 / ar_pa, 1) as taux_marge from bur_article
order by marge desc;
-- 20 lignes
-- Les articles dont le prix d'achat est null ont une marge null : toute opération avec
-- null donne null.

/* 6) Afficher les clients de CAEN ou de CHERBOURG qui sont des entreprises (type 'E'). */
select * from bur_client
where cl_localite in ('CAEN', 'CHERBOURG')
and cl_type = 'E';
-- 2 lignes

/* 7) Afficher les articles dont le nom commence par 'C' et contient 'SE'. */
select * from bur_article
where ar_nom like 'C%'
and ar_nom like '%SE%';
-- 4 lignes


-- =============================================================================
-- Jointures  (5.5.1 à 5.5.4)
-- =============================================================================

/* 5.5.1) Afficher le nom, le numéro et le poids des articles rouges, avec le nom de leur
          fournisseur. */
select ar.ar_nom, ar.ar_numero, ar.ar_poids, fo.fo_nom from bur_article ar
join bur_fournisseur fo on fo.fo_numero = ar.fo_numero
where ar.ar_couleur = 'ROUGE'
order by ar.ar_numero;
-- 4 lignes

-- même requête avec join using
select ar_nom, ar_numero, ar_poids, fo_nom from bur_article
join bur_fournisseur using (fo_numero)
where ar_couleur = 'ROUGE'
order by ar_numero;
-- 4 lignes

/* 5.5.2) Afficher les clients ayant passé au moins une commande. */
-- solution sous-requête
select * from bur_client
where cl_numero in
(
  select cl_numero from bur_commande
)
order by cl_numero;
-- 8 lignes

-- solution jointure : le distinct est obligatoire (un client peut avoir plusieurs commandes)
select distinct cli.* from bur_client cli
join bur_commande com on com.cl_numero = cli.cl_numero
order by cli.cl_numero;
-- 8 lignes

/* 5.5.3) Afficher les articles commandés par des clients de CAEN (n° de commande, client,
          article, quantité commandée). */
select com.co_numero, cli.cl_nom, cli.cl_prenom, ar.ar_numero, ar.ar_nom, lig.lic_qtcmdee from bur_article ar
join bur_ligcde lig on lig.ar_numero = ar.ar_numero
join bur_commande com on com.co_numero = lig.co_numero
join bur_client cli on cli.cl_numero = com.cl_numero
where cli.cl_localite = 'CAEN'
order by com.co_numero, ar.ar_numero;
-- 14 lignes

/* 5.5.4) Afficher tous les clients avec leurs numéros de commande, y compris les clients
          qui n'ont jamais commandé. */
select cli.cl_numero, cli.cl_nom, com.co_numero from bur_client cli
left join bur_commande com on com.cl_numero = cli.cl_numero
order by cli.cl_numero, com.co_numero;
-- 14 lignes

/* 8) Afficher chaque commande avec son magasin (localité, gérant) et son client. */
select com.co_numero, com.co_date, mag.ma_localite, mag.ma_nom_gerant, cli.cl_nom from bur_commande com
join bur_magasin mag on mag.ma_numero = com.ma_numero
join bur_client cli on cli.cl_numero = com.cl_numero
order by com.co_date;
-- 12 lignes

/* 9) Afficher tous les fournisseurs avec leurs articles, y compris les fournisseurs qui
      n'en proposent aucun. */
select fo.fo_numero, fo.fo_nom, ar.ar_numero, ar.ar_nom from bur_fournisseur fo
left join bur_article ar on ar.fo_numero = fo.fo_numero
order by fo.fo_numero, ar.ar_numero;
-- 21 lignes

/* 10) Auto-jointure : afficher les couples d'articles différents qui portent le même nom
       (une seule fois par couple). */
select a1.ar_numero, a2.ar_numero as ar_numero_bis, a1.ar_nom from bur_article a1
join bur_article a2 on a2.ar_nom = a1.ar_nom
where a1.ar_numero < a2.ar_numero
order by a1.ar_nom;
-- 3 lignes
-- "<" plutôt que "<>" : avec "<>" chaque couple apparaîtrait deux fois (A01-A02 et A02-A01).

/* 11) Auto-jointure : afficher les gérants de magasin qui ont un homonyme (même nom). */
select distinct m1.ma_nom_gerant, m1.ma_prenom_gerant, m1.ma_localite from bur_magasin m1
join bur_magasin m2 on m2.ma_nom_gerant = m1.ma_nom_gerant
where m1.ma_numero <> m2.ma_numero
order by m1.ma_nom_gerant;
-- 2 lignes


-- =============================================================================
-- Opérateurs ensemblistes  (5.5.6 solution 2)
-- =============================================================================

/* 5.5.6) Afficher les commandes qui n'ont pas encore été livrées (2 solutions). */
-- solution 1 : sous-requête
select * from bur_commande
where co_numero not in
(
  select co_numero from bur_livraison
)
order by co_numero;
-- 4 lignes

-- solution 2 : différence
select co_numero from bur_commande
minus
select co_numero from bur_livraison;
-- 4 lignes

/* 12) Afficher les localités où il y a à la fois un client et un magasin. */
select cl_localite as localite from bur_client
intersect
select ma_localite from bur_magasin;
-- 3 lignes

/* 13) Afficher toutes les localités connues (clients et magasins) sans doublon, puis avec
       les doublons. Comparer. */
select cl_localite as localite from bur_client
union
select ma_localite from bur_magasin;
-- 8 lignes

select cl_localite as localite from bur_client
union all
select ma_localite from bur_magasin;
-- 14 lignes


-- =============================================================================
-- Vues  (exemple du cours 1.5)
-- =============================================================================

/* 14) Créer une vue modifiable v_article_fournisseur1 (n° fournisseur pris dans l'article)
       et une vue non modifiable sur cette colonne v_article_fournisseur2 (n° fournisseur
       pris dans le fournisseur). */
create or replace view v_article_fournisseur1 as
select fo.fo_nom, ar.fo_numero, ar.ar_numero, ar.ar_nom, ar.ar_poids, ar.ar_couleur, ar.ar_stock, ar.ar_pa, ar.ar_pv from bur_article ar
join bur_fournisseur fo on ar.fo_numero = fo.fo_numero;

create or replace view v_article_fournisseur2 as
select fo.fo_nom, fo.fo_numero, ar.ar_numero, ar.ar_nom, ar.ar_poids, ar.ar_couleur, ar.ar_stock, ar.ar_pa, ar.ar_pv from bur_article ar
join bur_fournisseur fo on ar.fo_numero = fo.fo_numero;

select * from v_article_fournisseur1
order by ar_numero;
-- 20 lignes

-- colonnes modifiables de chaque vue (dictionnaire Oracle)
select table_name, column_name, updatable, insertable, deletable from user_updatable_columns
where table_name like 'V_ARTICLE_FOURNISSEUR%'
and column_name like '%NUMERO%';
-- fo_numero est modifiable dans la vue 1 (il vient de bur_article, table "préservée par
-- clé") et pas dans la vue 2 (il vient de bur_fournisseur).

/* 15) Utiliser la vue v_article_fournisseur1 pour afficher les articles du fournisseur
       'STYLO PLUS'. */
select ar_numero, ar_nom, ar_couleur, ar_pv from v_article_fournisseur1
where fo_nom = 'STYLO PLUS'
order by ar_numero;
-- 4 lignes


-- =============================================================================
-- Sous-requêtes  (5.5.5, 5.5.7, 5.5.8)
-- =============================================================================

/* 5.5.5) Afficher les articles dont le prix d'achat est supérieur à celui de l'article A07. */
select * from bur_article
where ar_pa >
(
  select ar_pa from bur_article
  where ar_numero = 'A07'
)
order by ar_pa;
-- 7 lignes

/* 5.5.7) Afficher les articles qui n'ont jamais été commandés. */
select * from bur_article
where ar_numero not in
(
  select ar_numero from bur_ligcde
)
order by ar_numero;
-- 2 lignes

/* 5.5.8) Afficher les articles plus légers que l'article A02 (2 solutions). */
-- solution 1 : sous-requête
select * from bur_article
where ar_poids <
(
  select ar_poids from bur_article
  where ar_numero = 'A02'
)
order by ar_poids;
-- 1 ligne

-- solution 2 : auto-jointure
select ar1.* from bur_article ar1
join bur_article ar2 on ar1.ar_poids < ar2.ar_poids
where ar2.ar_numero = 'A02'
order by ar1.ar_poids;
-- 1 ligne

/* 16) Afficher le ou les articles les plus chers à la vente (sans fonction d'agrégat). */
select * from bur_article
where ar_pv >= all
(
  select ar_pv from bur_article
);
-- 1 ligne

/* 17) Afficher les clients ayant commandé au moins un article du fournisseur
       'BUREAU EXPRESS' (sous-requêtes imbriquées, aucune jointure). */
select * from bur_client
where cl_numero in
(
  select cl_numero from bur_commande
  where co_numero in
  (
    select co_numero from bur_ligcde
    where ar_numero in
    (
      select ar_numero from bur_article
      where fo_numero in
      (
        select fo_numero from bur_fournisseur
        where fo_nom = 'BUREAU EXPRESS'
      )
    )
  )
)
order by cl_numero;
-- 4 lignes

/* 18) Requête synchronisée : afficher les clients qui n'ont passé aucune commande
       (not exists). */
select * from bur_client cli
where not exists
(
  select * from bur_commande com
  where com.cl_numero = cli.cl_numero
);
-- 2 lignes

/* 19) Requête synchronisée : afficher pour chaque fournisseur son ou ses articles les plus
       lourds. */
select fo_numero, ar_numero, ar_nom, ar_poids from bur_article ar1
where ar_poids =
(
  select max(ar_poids) from bur_article ar2
  where ar2.fo_numero = ar1.fo_numero
)
order by fo_numero;
-- 7 lignes


-- =============================================================================
-- Expressions et fonctions
-- =============================================================================

/* 20) Afficher les articles avec leur couleur en clair : 'non renseignée' si la couleur est
       vide (nvl), et une catégorie de prix avec decode / case (moins de 1 euro : 'petit
       prix', moins de 10 : 'moyen', sinon 'cher'). */
select ar_numero, ar_nom, nvl(ar_couleur, 'non renseignée') as couleur,
case
  when ar_pv < 1 then 'petit prix'
  when ar_pv < 10 then 'moyen'
  else 'cher'
end as categorie from bur_article
order by ar_numero;
-- 20 lignes

/* 21) Afficher pour chaque commande la date au format JJ/MM/AAAA, le nom du mois et le
       nombre de jours écoulés depuis la commande. */
select co_numero, to_char(co_date, 'DD/MM/YYYY') as date_cde, to_char(co_date, 'month') as mois, trunc(sysdate - co_date) as jours_ecoules from bur_commande
order by co_date;
-- 12 lignes

/* 22) Afficher les commandes passées au premier semestre 2025. */
select * from bur_commande
where co_date between to_date('01/01/2025', 'DD/MM/YYYY') and to_date('30/06/2025', 'DD/MM/YYYY')
order by co_date;
-- 10 lignes

/* 23) Afficher le délai de livraison (en jours) de chaque commande livrée. */
select com.co_numero, com.co_date, liv.date_liv, liv.date_liv - com.co_date as delai_jours from bur_commande com
join bur_livraison liv on liv.co_numero = com.co_numero
order by delai_jours desc;
-- 8 lignes

/* 24) Afficher le nom et le prénom des clients en une seule colonne "client" (prénom puis
       nom en majuscules). */
select cl_prenom || ' ' || upper(cl_nom) as client from bur_client
order by cl_nom;
-- 10 lignes


-- =============================================================================
-- Groupement et fonctions d'agrégat  (5.5.9, 5.5.10)
-- =============================================================================

/* 25) Afficher par couleur le nombre d'articles, avec une ligne TOTAL (rollup). Les
       articles sans couleur ne sont pas comptés. */
select nvl(upper(ar_couleur), 'TOTAL') as couleur, count(*) as nb_par_couleur from bur_article
where ar_couleur is not null
group by rollup (upper(ar_couleur));
-- 7 lignes

/* 26) Nombre d'articles, prix de vente moyen, minimum et maximum. */
select count(*) as nb_articles, round(avg(ar_pv), 2) as pv_moyen, min(ar_pv) as pv_mini, max(ar_pv) as pv_maxi from bur_article;
-- 1 ligne

/* 27) Compter les articles, les articles ayant un prix d'achat et les fournisseurs
       distincts. Expliquer la différence. */
select count(*) as nb_articles, count(ar_pa) as nb_avec_pa, count(distinct fo_numero) as nb_fournisseurs from bur_article;
-- 1 ligne
-- count(*) compte les lignes, count(colonne) ignore les null.

/* 5.5.9) Afficher pour chaque client le nombre de commandes passées (y compris 0). */
select cli.cl_numero, cli.cl_nom, count(com.co_numero) as nb_commandes from bur_client cli
left join bur_commande com on com.cl_numero = cli.cl_numero
group by cli.cl_numero, cli.cl_nom
order by nb_commandes desc, cli.cl_numero;
-- 10 lignes
-- count(com.co_numero) et non count(*) : sinon un client sans commande compterait 1.

/* 5.5.10) Afficher le montant total de chaque commande (quantité commandée x prix unitaire). */
select co_numero, sum(lic_qtcmdee * lic_pu) as montant from bur_ligcde
group by co_numero
order by montant desc;
-- 12 lignes

/* 28) Afficher les clients dont le total commandé dépasse 100 euros. */
select cli.cl_numero, cli.cl_nom, sum(lig.lic_qtcmdee * lig.lic_pu) as total_commande from bur_client cli
join bur_commande com on com.cl_numero = cli.cl_numero
join bur_ligcde lig on lig.co_numero = com.co_numero
group by cli.cl_numero, cli.cl_nom
having sum(lig.lic_qtcmdee * lig.lic_pu) > 100
order by total_commande desc;
-- 4 lignes

/* 29) Afficher par magasin le nombre de commandes et le chiffre d'affaires. */
select mag.ma_numero, mag.ma_localite, count(distinct com.co_numero) as nb_commandes, sum(lig.lic_qtcmdee * lig.lic_pu) as chiffre_affaires from bur_magasin mag
join bur_commande com on com.ma_numero = mag.ma_numero
join bur_ligcde lig on lig.co_numero = com.co_numero
group by mag.ma_numero, mag.ma_localite
order by chiffre_affaires desc;
-- 4 lignes

/* 30) Afficher le ou les articles les plus commandés (en quantité totale). */
select ar.ar_numero, ar.ar_nom, sum(lig.lic_qtcmdee) as qte_totale from bur_article ar
join bur_ligcde lig on lig.ar_numero = ar.ar_numero
group by ar.ar_numero, ar.ar_nom
having sum(lig.lic_qtcmdee) =
(
  select max(sum(lic_qtcmdee)) from bur_ligcde
  group by ar_numero
);
-- 1 ligne

/* 31) Afficher les commandes dont la quantité livrée est inférieure à la quantité
       commandée (reste à livrer). */
select co_numero, ar_numero, lic_qtcmdee, lic_qtlivree, lic_qtcmdee - lic_qtlivree as reste from bur_ligcde
where lic_qtlivree < lic_qtcmdee
order by co_numero, ar_numero;
-- 8 lignes


-- =============================================================================
-- Mises à jour  (5.7.1)
-- =============================================================================

/* 5.7.1) Insérer un nouvel article : d'abord avec toutes les colonnes, puis seulement les
          colonnes obligatoires, puis réinsérer le même n° (erreur de clé primaire). */
insert into bur_article (ar_numero, fo_numero, ar_nom, ar_poids, ar_couleur, ar_stock, ar_pa, ar_pv)
values ('A21', 'F02', 'STYLO SIMPLE', 50, 'BLEU', 10, 0.25, 0.36);

insert into bur_article (ar_numero, fo_numero, ar_nom)
values ('A22', 'F02', 'STYLO SIMPLE');

-- erreur attendue : ORA-00001 contrainte unique (PK_BUR_ARTICLE) violée
insert into bur_article (ar_numero, fo_numero, ar_nom, ar_poids, ar_couleur, ar_stock, ar_pa, ar_pv)
values ('A21', 'F02', 'STYLO SIMPLE', 50, 'BLEU', 10, 0.25, 0.36);

select * from bur_article
where ar_numero in ('A21', 'A22');
-- 2 lignes

/* 5.7.2) Augmenter de 5 % le prix de vente des articles du fournisseur F02. */
update bur_article set ar_pv = round(ar_pv * 1.05, 2)
where fo_numero = 'F02';

/* 5.7.3) Supprimer les articles insérés en 5.7.1, puis annuler les modifications. */
delete from bur_article
where ar_numero in ('A21', 'A22');

rollback;
