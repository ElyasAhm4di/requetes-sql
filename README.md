# Requêtes SQL

Mes requêtes SQL de BUT Informatique, écrites pour Oracle. Ce sont des réponses à des exercices de cours, classées par base de données.

**Ce dépôt ne contient pas les bases elles-mêmes.** Les tables (`vt_*` et `tdf_*` pour le Tour de France, `atl_*`, `cdi_*`, `epo_*`) viennent des bases fournies en cours, hébergées sur le schéma `prof` du serveur de l'IUT. Sans elles, les requêtes ne s'exécutent pas : elles sont là pour être lues.

## Ce qu'il y a dedans

**`requetes/tour_de_france/`** : la base du Tour de France (coureurs, étapes, équipes, abandons, sponsors).
- `45d2.sql` : une vue du classement général 2005, qui exclut les coureurs ayant abandonné et ajoute les écarts de temps.
- `57a_57b.sql` : les abandons de 2023, par type puis au total, avec des vues pour réutiliser les résultats.
- `exo16_16bis.sql` : les étapes qui partagent la même ville d'arrivée. Le fichier garde mes essais successifs, avec le nombre de lignes obtenues à chaque version (la première, fausse, en renvoyait 1071).
- `exo18.sql` : les coureurs ayant abandonné en 2025, avec leur équipe et les trois directeurs sportifs possibles (jointures externes pour les directeurs adjoints).
- `exo23.sql` : les sponsors classés dans les 10 premiers mais jamais engagés, plus ceux classés au-delà des 20 premiers mais engagés (`MINUS` et `UNION`).
- `perso1.sql` : des recherches libres sur les coureurs et leurs sponsors (plages de dossards, motifs sur le nom, classement des jeunes), sur les tables `tdf_*`.

**`requetes/atlantik/`**, **`requetes/cdi/`** et **`requetes/epo/`** : un fichier chacun. `atlantik` porte sur des réservations et des ports, `cdi` sur des articles, des clients et des fournisseurs (avec `ROLLUP` pour obtenir des sous-totaux par couleur), `epo` sur des participants et les articles qu'ils ont écrits.

## Conventions

Dans les fichiers, les mots-clés SQL sont écrits tels que je les ai tapés, en majuscules ou minuscules. Je n'ai pas uniformisé le style pour ne pas toucher à ce que j'avais rendu.

Les commentaires `/* ... */` en tête de fichier rappellent l'énoncé. La syntaxe est celle d'Oracle (`NVL`, `MINUS`, `ROWNUM`, `CREATE OR REPLACE VIEW`) : elle ne passe pas telle quelle sur MySQL ou PostgreSQL.

## Ce qui manque

Je n'ai pas mis ici mon gros fichier de réponses aux premiers TP, qui mélange mes requêtes et des commandes d'administration, ni les scripts de création des bases, qui ne sont pas de moi. Je les ajouterai si je les nettoie.

Aucun identifiant de base de données n'est présent dans ce dépôt.
