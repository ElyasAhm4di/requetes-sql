



select distinct par_nom,par_prenom from epo_participant 
join epo_ecrire e using (par_matricule)
where e.art_num in(
select a.art_num from epo_article a);

SELECT p.PAR_NOM, p.PAR_PRENOM
FROM EPO_PARTICIPANT p
JOIN EPO_PIGISTE pg
    ON pg.PAR_MATRICULE = p.PAR_MATRICULE
LEFT JOIN EPO_ECRIRE e
    ON e.PAR_MATRICULE = p.PAR_MATRICULE
WHERE e.ART_NUM IS NULL;



select distinct par_nom,par_prenom,art_titre from epo_participant
join epo_pigiste using (par_matricule)
left join epo_ecrire using (par_matricule)
left join epo_article using  (art_num);



select num_code,min(ver_date) as date_prem, max(ver_date) as date_dernier
from epo_numero
join epo_version using (num_code)
group by num_code;


select * from epo_article;
select * from epo_pigiste;

select par_nom, par_prenom , sum(pig_prix_feuillet * art_nb_feuilles) as somme from epo_participant 
join epo_pigiste using (par_matricule)
join epo_ecrire using (par_matricule)
join epo_article using (art_num)
group by par_nom,par_prenom 
having sum(pig_prix_feuillet * art_nb_feuilles) > 150;


SELECT par_nom, par_prenom,
       SUM(art_nb_feuilles) AS nb_feuilles,
       (SELECT SUM(art_nb_feuilles) FROM epo_article) AS total
FROM epo_participant
JOIN epo_ecrire USING (par_matricule)
JOIN epo_article USING (art_num)
GROUP BY par_nom, par_prenom;



select par_nom, par_prenom , sum(art_nb_feuilles) as nb_feuilles from epo_participant 
JOIN epo_ecrire USING (par_matricule)
JOIN epo_article USING (art_num)
GROUP BY par_nom, par_prenom


union 


select 'TOTAL' ,null, sum(art_nb_feuilles) from epo_article;


SELECT rub_titre, SUM(art_nb_feuilles) AS TOTAL
FROM epo_article 
JOIN epo_rubrique USING (rub_code)
GROUP BY rub_titre
HAVING SUM(art_nb_feuilles) >
       (SELECT AVG(art_nb_feuilles) FROM epo_article);
       
       
       
select a.par_nom, a.par_prenom,round(((sysdate-par_date_naissance) / 365)) as age from epo_participant a
join epo_participant b on a.par_matricule = b.par_matricule
where a.par_nom = b.par_nom;



SELECT DISTINCT a.par_nom, a.par_prenom,
       ROUND((SYSDATE - a.par_date_naissance) / 365) AS age
FROM epo_participant a
JOIN epo_participant b
    ON a.par_nom = b.par_nom
   AND a.par_matricule <> b.par_matricule;






