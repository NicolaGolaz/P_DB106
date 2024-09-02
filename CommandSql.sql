/* Ci-dessous la commande pour importer la base de données. Pour l'executer vous devez vous placer ou se trouve le fichier sql de la base de 
données avec gitbash, puis exécuter la commmande. Avant de faire cette commande veuiller vous assurer que la base de données est deja créer dans phpmyadmin


"docker exec"  permet d'éxecuter une commande dans un conteneur docker.
"-i"  permet d'accepter des entrées standard
"db" est le nom du conteneur dans lequel la commande va être éxecuter.
"mysql" éxecute le client mysql pour intéragir avec la base de données.
"-uroot" et "-proot" spécifie les informations permettant la connection a la base de données.
"db_space_invaders" est le nom de la base de données vers laquelle le script sera exécuter.
"< db_space_invaders" redirige le contenu du fichier sql vers la base de données.
*/




docker exec -i db mysql -uroot -proot db_space_invaders < db_space_invaders.sql

/* Requete 1 */

SELECT * FROM t_joueur ORDER BY jouNombrePoints DESC LIMIT 5; 

/* Requete 2 */

SELECT MAX(armPrix) AS PrixMaximum, MIN(armPrix) AS PrixMinimum, AVG(armPrix) AS PrixMoyen FROM t_arme;

/* Requete 3 */

SELECT fkJoueur AS IdJoueur, COUNT(idCommande) AS NombreCommandes FROM t_commande GROUP BY fkJoueur;

/* Requete 4 */

SELECT fkJoueur AS IdJoueur, COUNT(idCommande) AS NombreCommandes FROM t_commande GROUP BY fkJoueur;

