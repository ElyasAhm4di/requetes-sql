select cou.nom as nom_coureur, cou.prenom, c_typeaban, spo.nom as nom_equipe,
dir1.nom as nom_pre_dir, dir2.nom as nom_dir_adj, dir3.nom as nom_dir_troi
from prof.vt_abandon aba
join prof.vt_coureur cou on cou.n_coureur = aba.n_coureur
join prof.vt_parti_coureur par on par.annee= aba.annee and par.n_coureur=aba.n_coureur
join prof.vt_sponsor spo on spo.n_equipe=par.n_equipe and spo.n_sponsor = par.n_sponsor
join prof.vt_parti_equipe eqa on eqa.n_equipe=par.n_equipe 
and eqa.n_sponsor = par.n_sponsor and eqa.annee= par.annee
join prof.vt_directeur dir1 on eqa.n_pre_directeur = dir1.n_directeur
left join prof.vt_directeur dir2 on eqa.n_sec_directeur = dir2.n_directeur
left join prof.vt_directeur dir3 on eqa.n_troi_directeur = dir3.n_directeur
Where Par.Annee = 2025
and spo.nom in ('XDS ASTANA TEAM','COFIDIS','MOVISTAR TEAM'); 

select cou.nom as nom_coureur, cou.prenom, c_typeaban, spo.nom as nom_equipe,
dir1.nom as nom_pre_dir, dir2.nom as nom_dir_adj, dir3.nom as nom_dir_troi
from prof.vt_abandon 
join prof.vt_coureur cou using(n_coureur)
join prof.vt_parti_coureur using(annee,n_coureur)
join prof.vt_sponsor spo using (n_equipe,n_sponsor)
join prof.vt_parti_equipe eqa using (n_equipe,n_sponsor,annee)
join prof.vt_directeur dir1 on eqa.n_pre_directeur = dir1.n_directeur
left join prof.vt_directeur dir2 on eqa.n_sec_directeur = dir2.n_directeur
left join prof.vt_directeur dir3 on eqa.n_troi_directeur = dir3.n_directeur
where annee = 2025
and spo.nom in ('XDS ASTANA TEAM','COFIDIS','MOVISTAR TEAM');
-- 4 réponses