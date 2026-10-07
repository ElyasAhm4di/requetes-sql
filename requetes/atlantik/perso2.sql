select * from atl_reservation
order by res_nom desc, res_prenom asc;


select * from atl_port
where lower(trim(por_nom)) not like '%t';


select * 
from atl_tarifer
where per_date_debut 
between to_date('01/09/2010', 'dd/mm/yyyy')
    and to_date('01/09/2012', 'dd/mm/yyyy');
    
    
    select 
      
       per_date_fin - per_date_debut as duree_jours
from atl_periode;

    
    
    
    
select s.sec_num,s.sec_nom,l.lia_code,l.lia_distance  from atl_secteur s
join atl_liaison l on s.sec_num = l.sec_num;


select sec_num,sec_nom,lia_code,lia_distance  from atl_secteur 
join atl_liaison  using(sec_num);



select s.sec_nom as SECTEUR,l.lia_distance as DISTANCE,p1.por_nom as DEPART , p2.por_nom as ARRIVEE  from atl_secteur s
join atl_liaison l on s.sec_num = l.sec_num
join atl_port p1 on l.por_code_depart = p1.por_code
join atl_port p2 on l.por_code_arrivee = p2.por_code;



select b.bat_nom , t.tra_code from atl_bateau b  
left join atl_traversee t on b.bat_id = t.bat_id
order by b.bat_id, t.tra_code;



select distinct a.res_nom , a.res_prenom from atl_reservation a, atl_reservation b
where a.res_nom = b.res_nom
and a.res_prenom = b.res_prenom
and a.tra_code <> b.tra_code
order by a.res_nom , a.res_prenom;
