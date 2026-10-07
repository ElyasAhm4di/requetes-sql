select * from tdf_coureur c
join tdf_parti_coureur p on c.n_coureur = p.n_coureur
where n_dossard between 28 and 49
and (nom like '%ZI%' or c.nom like '%IZ%')
ORDER by annee;




select * from tdf_coureur c
join tdf_parti_coureur p on c.n_coureur = p.n_coureur
where jeune is not  null
and annee = 2025;


select c.nom,c.prenom,s.nom as nom_sponsor from tdf_coureur c
join tdf_parti_coureur p on c.n_coureur = p.n_coureur
join tdf_sponsor s using (n_equipe,n_sponsor)
where jeune is not  null
and annee = 2025
order by nom_sponsor,c.nom;



drop table exoplus2;
create table exoplus2(num number(3), nom varchar2(20));
insert into exoplus2 values (1,'Julian');
insert into exoplus2 values (2,'Julian');
insert into exoplus2 values (3,'lance');
insert into exoplus2 values (4,'Romain');
insert into exoplus2 values (5,'Romain');
insert into exoplus2 values (6,'Romain');
insert into exoplus2 values (7,'Thibaut');
insert into exoplus2 values (8,'Thibaut');
commit;



SELECT nom  from exoplus2;




select distinct a.nom , a.prenom from
tdf_coureur a, tdf_coureur b
where a.nom = b.nom
and a.n_coureur <> b.n_coureur
order by a.nom , a.prenom;


SELECT DISTINCT
  e1.n_etape, e1.n_comp, e1.ville_d, e1.ville_a, e1.annee
FROM vt_etape e1, vt_etape e2
WHERE e1.ville_a = e2.ville_a
  AND NOT (e1.annee = e2.annee
           AND e1.n_etape = e2.n_etape
           AND e1.n_comp  = e2.n_comp)
ORDER BY e1.ville_a, e1.annee, e1.n_etape, e1.n_comp; 

SELECT DISTINCT
  e1.n_etape, e1.n_comp, e1.ville_d, e1.ville_a
FROM vt_etape e1, vt_etape e2
WHERE e1.ville_a = e2.ville_a
  AND NOT (e1.annee = e2.annee
           AND e1.n_etape = e2.n_etape
           AND e1.n_comp  = e2.n_comp)
ORDER BY e1.ville_a, e1.n_etape, e1.n_comp; 




SELECT DISTINCT
       a.c_typeaban      AS type_aban_vt_abandon,
       t.c_typeaban      AS type_aban_vt_typeaban,
       t.libelle        AS libelle_type
FROM vt_typeaban t
LEFT JOIN vt_abandon a
  ON a.c_typeaban = t.c_typeaban
ORDER BY t.c_typeaban;


select distinct * 
       from tdf_abandon
join tdf_coureur using (n_coureur)      
join tdf_parti_coureur using (n_coureur)
join tdf_sponsor using (n_equipe, n_sponsor)
join tdf_parti_equipe using (n_equipe,n_sponsor)
join tdf_directeur using
     n_directeur = n_pre_directeur      
     
      
       





