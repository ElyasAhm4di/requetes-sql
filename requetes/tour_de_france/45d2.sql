create or replace view mon_classement_2005 as
select annee,rownum as classement, n_coureur, nom, prenom,TEMPS_TOTAL from 
(
  select annee,to_char(n_coureur) as n_coureur, nom, prenom, sum(total_seconde) +nvl(difference,0) as TEMPS_TOTAL
  from vt_coureur
  join vt_temps using(n_coureur)
  join vt_parti_coureur using(n_coureur, annee)
  left join vt_temps_difference using(n_coureur,annee)
  where (n_coureur,annee) not in
  (
    select n_coureur,annee from vt_abandon
  )
  and annee=2005 and valide='O'
  group by annee,n_coureur, nom, prenom , difference
  union
  select annee,'------', substr(nom,1,2)||'----', prenom, sum(total_seconde) +nvl(difference,0) as TEMPS_TOTAL
  from vt_coureur
  join vt_temps using(n_coureur)
  join vt_parti_coureur using(n_coureur, annee)
  left join vt_temps_difference using(n_coureur,annee)
  where (n_coureur,annee) not in
  (
    select n_coureur,annee from vt_abandon
  )
  and annee=2005 and valide='R'
  group by annee,nom, prenom , difference
  order by TEMPS_TOTAL
);

select * from mon_classement_2005;
-- 155 réponses