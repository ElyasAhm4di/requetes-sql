# Requêtes SQL

Exercices SQL en syntaxe **Oracle**, sur deux bases imaginaires que j'ai créées. Toutes les données sont fictives.

| Thème | À lire | Base | Requêtes brutes |
|---|---|---|---|
| Rallye des Sables (rallye-raid) | [rallye/exercices.md](rallye/exercices.md) | [base_rallye.sql](rallye/base_rallye.sql) | [requetes_rallye.sql](rallye/requetes_rallye.sql) |
| Librairie (clients, commandes, livraisons) | [librairie/exercices.md](librairie/exercices.md) | [base_librairie.sql](librairie/base_librairie.sql) | [requetes_librairie.sql](librairie/requetes_librairie.sql) |

Les pages `exercices.md` présentent chaque question puis sa requête dans un bloc de code coloré, avec le nombre de lignes qu'elle renvoie. Les fichiers `.sql` contiennent les mêmes requêtes, prêtes à exécuter.

## Notions travaillées

Les exercices sont rangés dans le même ordre que le cours :

1. Projection et restriction (`WHERE`, `LIKE`, `BETWEEN`, `IN`, `IS NULL`)
2. Jointures : internes, externes, auto-jointures, écriture SQL1 / `ON` / `USING`
3. Opérateurs ensemblistes (`UNION`, `INTERSECT`, `MINUS`)
4. Vues
5. Sous-requêtes, `ALL`, `EXISTS`, requêtes synchronisées
6. Expressions et fonctions (`DECODE`, `CASE`, `NVL`, dates, chaînes)
7. Regroupements (`GROUP BY`, `HAVING`, `ROLLUP`, fonctions analytiques)
8. Requêtes avancées (requête hiérarchique `CONNECT BY`) et mises à jour (`INSERT`, `UPDATE`, `DELETE`)

## Utilisation

1. Dans SQL Developer, exécuter le fichier `base_*.sql` en script (F5). Au premier lancement, les `DROP TABLE` en tête échouent parce que les tables n'existent pas encore : c'est normal.
2. Ouvrir le fichier `requetes_*.sql` et exécuter les requêtes une par une (Ctrl+Entrée).

## Vérification

Toutes les requêtes ont été exécutées sur une copie PostgreSQL des deux bases, et les nombres de lignes indiqués viennent de cette exécution. Certaines requêtes sont propres à Oracle (`DECODE`, `ROWNUM`, `CONNECT BY`, `DUMP`, `MAX(COUNT(*))`) : pour celles-là, c'est leur équivalent PostgreSQL qui a été testé.

Ce travail a été réalisé avec l'aide d'une IA (Claude), qui a servi à concevoir les bases fictives, rédiger et mettre en forme les requêtes, et les exécuter pour les vérifier.
