/* Exercice 23
 Afficher le n° d'équipe et le n° de sponsor des sponsors classés dans les 
 10 premiers mais qui n'ont jamais participé au tour ainsi que les sponsors classés
 au-delà des 20 premiers et qui ont participé au tour */
(
  select n_equipe, n_sponsor from prof.vt_ordrequi 
  where numero_ordre<=10
  minus
  select n_equipe, n_sponsor from prof.vt_parti_equipe
)
union
(
  select n_equipe, n_sponsor from prof.vt_ordrequi 
  where numero_ordre>20
  intersect
  select n_equipe, n_sponsor from prof.vt_parti_equipe
);

(
  select n_equipe, n_sponsor,nom from prof.vt_ordrequi 
  join prof.vt_sponsor using(n_equipe,n_sponsor)
  where numero_ordre<=10
  minus
  select n_equipe, n_sponsor,nom  from prof.vt_parti_equipe
  join prof.vt_sponsor using(n_equipe,n_sponsor)
)
union
(
  select n_equipe, n_sponsor,nom from prof.vt_ordrequi 
  join prof.vt_sponsor using(n_equipe,n_sponsor)
  where numero_ordre>20
  intersect
  select n_equipe, n_sponsor,nom  from prof.vt_parti_equipe
  join prof.vt_sponsor using(n_equipe,n_sponsor)
);
-- 66 réponses