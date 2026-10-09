# Requêtes SQL

Mes exercices de SQL (syntaxe Oracle) pour le module de bases de données du BUT Informatique.

Pour m'entraîner, j'ai créé deux bases inventées de toutes pièces, et j'ai écrit dessus mes propres questions et leurs requêtes :

- **[Rallye des Sables](rallye/exercices.md)** : un rallye-raid avec des pilotes, des écuries, des étapes, des chronos et des abandons. 67 exercices.
- **[Librairie](librairie/exercices.md)** : des clients, des boutiques, des livres, des commandes et des livraisons. 44 exercices.

Chaque page donne la question, la requête et le nombre de lignes qu'elle renvoie. J'ai classé les exercices dans l'ordre du cours : projection, jointures, opérateurs ensemblistes, vues, sous-requêtes, fonctions, `group by`, puis des requêtes plus poussées (`rollup`, fonctions analytiques, `connect by`) et les mises à jour.

## Les essayer

Dans chaque dossier il y a :

- `base_*.sql` : crée les tables et les remplit. Je le lance en script dans SQL Developer (F5). La première fois, les `drop table` du début plantent parce que les tables n'existent pas encore : c'est normal.
- `requetes_*.sql` : toutes les requêtes, à lancer une par une (Ctrl+Entrée).
- `exercices.md` : la même chose en plus lisible.

## Remarques

- Toutes les données sont fictives.
- J'ai testé les requêtes sur une copie PostgreSQL des bases. Pour les quelques requêtes propres à Oracle (`decode`, `rownum`, `connect by`, `dump`, `max(count(*))`), c'est leur équivalent PostgreSQL qui a tourné.
- Je me suis fait aider par une IA (Claude) pour créer les bases, mettre les requêtes au propre et les vérifier.
