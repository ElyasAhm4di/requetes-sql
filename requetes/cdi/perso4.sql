select nvl(upper(ar_couleur),'TOTAL') as couleur,
count(*) as nbParCouleur 
from cdi_article 
where ar_couleur is not null 
group by rollup (upper(ar_couleur));


// 5.5.1

select ar_nom,ar_numero,ar_poids,fo_nom from cdi_article
join cdi_fournisseur using (fo_numero)
where ar_couleur = 'ROUGE';



// 5.5.2

select * from cdi_client 
where cl_numero in (
    select cl_numero from cdi_commande  
);



//5.5.3
select *  from cdi_article  
join cdi_ligcde using (ar_numero)
join cdi_commande using (co_numero)
join cdi_client using (cl_numero)

where cdi_client.cl_localite = 'CAEN';


//5.5.4 
select cl_nom,co_numero from cdi_client 
left join cdi_commande using (cl_numero);



//5.5.5

select  * from cdi_article 
where ar_pa > 
( select ar_pa from cdi_article where upper(ar_numero) = 'A07');


//5.5.6
//1

select * from cdi_commande 
where co_numero not in (
select co_numero from cdi_livraison);



//2 

select co_numero from cdi_commande 


minus 

select co_numero from cdi_livraison;





//5.5.7


select * from cdi_article 
where ar_numero not in (
select ar_numero from cdi_ligcde);


//5.5.8
 select arl.*  from cdi_article arl, cdi_article ar2 
 where trim(ar2.ar_numero) = 'A02'
 and arl.ar_poids < ar2.ar_poids AND ar2.ar_poids < 
 (
 select ar_poids from cdi_article where  ar_poids < 
 ( select ar_poids from cdi_article where trim(ar_numero) = 'A02')
 );
 
 
 
 
 
 
 //5.510
 
 
 
 
 
//5.7.1
Insert into CDI_ARTICLE (AR_NUMERO,FO_NUMERO,AR_NOM,AR_POIDS,AR_COULEUR,AR_STOCK,AR_PA,AR_PV) values ('A103' , 'F010' , 'STYLO SIMPLE'     , 50  ,'BLEU'  , 10 , 25   , 36    )
;  



Insert into CDI_ARTICLE (AR_NUMERO,FO_NUMERO,AR_NOM)
values ('A105' , 'F010' , 'STYLO SIMPLE' );



insert into CDI_article (AR_NUMERO,FO_NUMERO,AR_NOM,AR_POIDS,AR_COULEUR,AR_STOCK,AR_PA,AR_PV)
values ('A103' , 'F010' , 'STYLO SIMPLE'     , 50  ,'BLEU'  , 10 , 25   , 36)
            

