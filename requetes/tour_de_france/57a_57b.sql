/* Exercice 57 a
 Afficher les types d’abandon, le nombre d’abandons par type, le total des abandons en 2023 */
 -- essais
select count(*) as total_abandon from vt_abandon where annee=2023;

select c_typeaban, count(*) as nb_par_type
from vt_abandon  where annee=2023
group by c_typeaban;

create or replace view vt_nb_aban_total  as
select count(*) as total_abandon 
from vt_abandon where annee=2023;

create or replace view vt_nb_aban  as
select c_typeaban, count(*) as nb_par_type 
from vt_abandon 
where annee=2023
group by c_typeaban;

-- solution 1 : produit cartésien entre 2 vues
select c_typeaban,nb_par_type ,total_abandon
from vt_nb_aban, vt_nb_aban_total;

-- solution 2 : produit cartésien entre ma table et la vue vt_nb_aban_total
select c_typeaban, count(*) as nb_par_type , total_abandon
from vt_abandon , vt_nb_aban_total
where annee=2023
group by c_typeaban, total_abandon;

-- solution 3 : plus de vue. La requête à la place de vt_nb_aban_total
select c_typeaban, count(*) as nb_par_type, total_abandon
from vt_abandon,(select count(*) as total_abandon from vt_abandon where annee=2023) 
where annee=2023
group by c_typeaban, total_abandon;

-- solution 4
select c_typeaban, count(*) as  nb_par_type,
(select count(*) from vt_abandon where annee=2023) as total_abandon
from vt_abandon  
where annee =2023 
group by c_typeaban;

-- solution 5
select distinct c_typeaban, 
count(*) over (partition by c_typeaban) as nb_par_type,
count(*) over () as total
from vt_abandon  
where annee =2023 ;
-- 2réponses

-- solution 6a
select c_typeaban, count(*) as nb from vt_abandon 
where annee=2023
group by c_typeaban
union
select ' TOTAL',count(*) as total_abandon from vt_abandon 
where annee=2023 
order by 1 desc;

-- solution 6b peu lisible à cause du null
select c_typeaban, count(c_typeaban) as nb
from vt_abandon
where annee =2023 
group by rollup (c_typeaban)
order by 1 desc;	

-- solution 6b  corrigée
select coalesce (c_typeaban,' TOTAL') as c_typeaban, count(c_typeaban) nb
from vt_abandon
where annee =2023 
group by rollup (c_typeaban)
order by 1 desc;	
-- 3 lignes

/* Exercice  57 b)
 Réutiliser une des solutions précédentes pour afficher en plus le pourcentage d'abandons par type */
-- solution 2 
select c_typeaban, count(*) as nb_par_type, total_abandon ,
round(count(*)/total_abandon*100,2)||'%' as pourcent
from vt_abandon , vt_nb_aban_total 
where annee=2023 
group by c_typeaban, total_abandon;

-- solution 3
select c_typeaban, count(*) as nb_par_type, total_abandon, 
round(count(*)/total_abandon*100,2)||'%' as pourcent
from vt_abandon,(select count(*) as total_abandon from vt_abandon where annee=2023) 
where annee=2023
group by c_typeaban, total_abandon;

-- solution 4a
select c_typeaban, count(*) as  nb_par_type, 
(select * from vt_nb_aban_total) as total_abandon,
round((count(*)/(select * from vt_nb_aban_total))*100,2) as pourcentage
from vt_abandon  
where annee =2023 
group by c_typeaban;

-- solution 4b
select c_typeaban, nb_par_type, total_abandon, to_char(nb_par_type/total_abandon*100,'99D00')||' %' from
(
    select c_typeaban, count(*) as  nb_par_type, 
    (select * from vt_nb_aban_total) as total_abandon,
    (count(*)/(select * from vt_nb_aban_total))*100 as pourcentage
    from vt_abandon  
    where annee =2023 
    group by c_typeaban
);

-- solution 5
select distinct c_typeaban, 
count(c_typeaban) over (partition by c_typeaban) as nb_par_type,
count(c_typeaban) over () as total_abandon,
round(count(c_typeaban) over (partition by c_typeaban) / count(c_typeaban) over ()*100,2) as pourcent
from vt_abandon  
where annee =2023 ;
