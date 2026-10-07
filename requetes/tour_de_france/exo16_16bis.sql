/* Exercice 16
 Donner la liste des étapes dont la ville d'arrivée pour différentes étapes 
 est la même. Afficher le n° étape, le n° comp la ville départ, la ville arrivée et l'année du Tour de France. */
select distinct e1.n_etape, e1.n_comp, e1.ville_d, e1.ville_a, e1.annee
from  prof.vt_etape e1
join prof.vt_etape e2 on e1.ville_a = e2.ville_a
where e1.n_etape <> e2.n_etape
order by ville_a,ville_d,n_etape,n_comp;
-- ERREUR 1  (1071 réponses)

select distinct e1.n_etape, e1.n_comp, e1.ville_d, e1.ville_a, e1.annee
from vt_etape e1 join vt_etape e2 on e1.ville_a = e2.ville_a
where e1.annee <> e2.annee
order by ville_a,ville_d,n_etape,n_comp;
-- ERREUR 2 (1073 réponses)


select distinct e1.n_etape, e1.n_comp, e1.ville_d,  e1.ville_a, e1.annee
from prof.vt_etape e1 join prof.vt_etape e2 on e1.ville_a = e2.ville_a
where e1.date_etape <> e2.date_etape 
order by ville_a,ville_d,n_etape,n_comp;
-- ERREUR 3 (1088 réponses)

select distinct e1.n_etape,e1.n_comp, e1.ville_d, e1.ville_a, e1.annee
from prof.vt_etape e1 join prof.vt_etape e2 on e1.ville_a = e2.ville_a
where not(e1.n_etape = e2.n_etape and e1.n_comp = e2.n_comp and e1.annee = e2.annee)
order by ville_a,ville_d,n_etape,n_comp;
-- 1094 réponses

select distinct e1.n_etape, e1.n_comp, e1.ville_d, e1.ville_a, e1.annee
from prof.vt_etape e1 
join prof.vt_etape e2 on e1.ville_a = e2.ville_a
where e1.n_etape <> e2.n_etape or e1.n_comp <> e2.n_comp or e1.annee <> e2.annee
order by ville_d,ville_a,n_etape,n_comp;
-- 1094 réponses

-- montrer l'erreur 1 avec ce test
select * from vt_etape;

select distinct e1.n_etape, e1.n_comp, e1.ville_d, e1.ville_a, e1.annee
from vt_etape e1 join vt_etape e2 on e1.ville_a = e2.ville_a
where e1.n_etape <> e2.n_etape or e1.n_comp <> e2.n_comp or e1.annee <> e2.annee
minus
(
  select distinct e1.n_etape, e1.n_comp, e1.ville_d, e1.ville_a, e1.annee
  from vt_etape e1 join vt_etape e2 on e1.ville_a = e2.ville_a
  where e1.n_etape <> e2.n_etape 
)
Order By Ville_A;
-- 23 réponses

-- montrer l'erreur 2 avec ce test
select distinct e1.n_etape, e1.n_comp, e1.ville_d, e1.ville_a, e1.annee
from prof.vt_etape e1 join prof.vt_etape e2 on e1.ville_a = e2.ville_a
where e1.n_etape <> e2.n_etape or e1.n_comp <> e2.n_comp or e1.annee <> e2.annee
minus
(
    select distinct e1.n_etape, e1.n_comp, e1.ville_d, e1.ville_a, e1.annee
    from prof.vt_etape e1 join prof.vt_etape e2 on e1.ville_a = e2.ville_a
    where e1.annee <> e2.annee 
)
order by ville_a;
-- 21 réponses

-- montrer l'erreur 3 avec ce test
select distinct e1.n_etape, e1.n_comp, e1.ville_d, e1.ville_a, e1.annee
from vt_etape e1 join vt_etape e2 on e1.ville_a = e2.ville_a
where e1.n_etape <> e2.n_etape or e1.n_comp <> e2.n_comp or e1.annee <> e2.annee
minus
(
    select distinct e1.n_etape, e1.n_comp, e1.ville_d,  e1.ville_a, e1.annee
    from prof.vt_etape e1 join prof.vt_etape e2 on e1.ville_a = e2.ville_a
    where e1.date_etape <> e2.date_etape 
)
Order By Ville_A;
-- 6 réponses

/* Exercice 16bis
Même question mais sans afficher l'année. 
Pourquoi perd-on des lignes ? */
select distinct e1.n_etape,e1.n_comp, e1.ville_d, e1.ville_a
from prof.vt_etape e1 join prof.vt_etape e2 on e1.ville_a = e2.ville_a
where not(e1.n_etape = e2.n_etape and e1.n_comp = e2.n_comp and e1.annee = e2.annee)
order by ville_d,ville_a,n_etape,n_comp;
-- 1059 réponses


-- voir ERREUR 4 

-- il manque 23 réponses car on ne doit pas afficher la moitié de la clé
-- avec distinct : il faut projeter la clé primaire complète même si on n'en a pas besoin
