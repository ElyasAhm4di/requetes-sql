# Requêtes SQL : Tour de France et CDI

Mes réponses aux exercices SQL du module Bases de données (BUT Informatique, IUT Grand Ouest Normandie), en syntaxe **Oracle**.

Les requêtes ne tournent pas sur les bases du prof (`prof.vt_*`, `cdi_*`). Chaque exercice s'appuie sur une base que j'ai construite, avec la même structure et des données fictives.

## Contenu

| Dossier | Base | Requêtes |
|---|---|---|
| `tour_de_france/` | `base_tour.sql` : 19 tables `TOUR_*` (mêmes colonnes que la base TDF) | `requetes_tour.sql` : exercices 1 à 67 de *3-sql_tdf_exercices.pdf* |
| `cdi/` | `base_cdi.sql` : 8 tables `BUR_*` (mêmes colonnes que la base CDI) | `requetes_cdi.sql` : 31 questions + les exercices 5.5.x et 5.7.x |

Correspondance des noms : `vt_coureur` devient `tour_coureur`, `cdi_article` devient `bur_article`, et ainsi de suite. Les colonnes ne changent pas.

## Format des fichiers de requêtes

Chaque exercice reprend l'énoncé en commentaire, suivi de la requête écrite dans le format demandé dans l'énoncé :

```sql
/* 13) Donner la liste des coureurs considérés comme jeunes pour le Tour 2025. ... */
select cou.nom, cou.prenom, par.n_sponsor, par.n_equipe from tour_coureur cou
join tour_parti_coureur par on par.n_coureur = cou.n_coureur
where par.annee = 2025
and par.jeune = 'o'
order by cou.nom;
-- 7 lignes
```

La ligne `-- N lignes` sous la requête donne le nombre de lignes que renvoie ma base. Elle sert à vérifier son résultat après exécution.

## Utilisation

1. Dans SQL Developer, exécuter `base_tour.sql` ou `base_cdi.sql` en script (F5). Au premier lancement, les `DROP TABLE` échouent parce que les tables n'existent pas encore. C'est normal.
2. Ouvrir le fichier de requêtes et exécuter les requêtes une par une (Ctrl+Entrée).

## Remarques

- **Énoncés CDI** : la feuille d'exercices CDI ne figurait pas dans mes documents. Les questions 5.5.x et 5.7.x reprennent la numérotation de mes réponses de TP, et les énoncés ont été réécrits d'après ces requêtes. Les autres questions suivent les chapitres du cours.
- **Question 10 (TDF)** : l'énoncé demande le code `JAP`. Ma base utilise le vrai code CIO du Japon, `JPN`.
- **Questions 61e et 54 (TDF)** : l'énoncé renvoie à une capture d'écran qui n'est pas dans le PDF. J'ai donc choisi l'affichage.
- **Question 26 (TDF)** : les requêtes sur le dictionnaire (`user_views`, `desc`…) sont propres à Oracle et n'ont pas de nombre de lignes fixe.
- **Vérification** : toutes les requêtes ont été exécutées sur une copie PostgreSQL de ces bases, et les nombres de lignes viennent de cette exécution. Pour les quelques requêtes propres à Oracle (`decode`, `rownum`, `connect by`, `dump`, `max(count(*))`), c'est leur équivalent PostgreSQL qui a été exécuté. Elles n'ont pas encore été lancées sur un serveur Oracle.

Ce travail a été réalisé avec l'aide d'une IA (Claude), qui a servi à construire les bases de test, rédiger les requêtes et les exécuter pour les vérifier.
