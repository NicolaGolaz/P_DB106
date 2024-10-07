/* Ci-dessous la commande pour importer la base de données. Pour l'executer vous devez vous placer ou se trouve le fichier sql de la base de 
données avec gitbash, puis exécuter la commmande. Avant de faire cette commande veuiller vous assurer que la base de données est deja créer dans phpmyadmin


"docker exec"  permet d'éxecuter une commande dans un conteneur docker.
"-i"  permet d'accepter des entrées standard
"db" est le nom du conteneur dans lequel la commande va être éxecuter.
"mysql" éxecute le client mysql pour intéragir avec la base de données.
"-uroot" et "-proot" spécifie les informations permettant la connection a la base de données.
"db_space_invaders" est le nom de la base de données vers laquelle le script sera exécuter.
"< db_space_invaders" redirige le contenu du fichier sql vers la base de données.

Cette commande s'éxxécute depuis le terminal windows.

docker exec -i db mysql -uroot -proot db_space_invaders < db_space_invaders.sql 
*/

/* /////////////////////////////////////////// Creation d'utilisateur et de rôle //////////////////////////////////////////////////// */

/* Supprime les roles et utilisateurs si ils éxistent deja */

DROP ROLE 'administrateur';
DROP USER 'admin'@'localhost';
DROP ROLE 'joueur';
DROP USER 'joueur1'@'localhost';
DROP ROLE 'gestboutique';
DROP USER 'gestboutique1'@'localhost';





/* Création du role administrateur */
CREATE ROLE 'administrateur';
/* Attribution de tous les priviléges sur le role administrateur */
GRANT ALL PRIVILEGES ON db_space_invaders.* TO 'administrateur' WITH GRANT OPTION;
/* Creation de l'utilisateur administrateur */
CREATE USER 'admin'@'localhost' IDENTIFIED BY '1234';
/* Attribution du rôle administrateur a l'utilisateur administrateur */
GRANT 'administrateur' TO 'admin'@'localhost';
SET DEFAULT ROLE 'administrateur' TO 'admin'@'localhost';

/* Creation du role Joueur*/
CREATE ROLE 'joueur';
/* Attribution du privilége select sur le role joueur, pour qu'il puisse voir les informations des armes  */
GRANT SELECT ON db_space_invaders.t_arme TO 'joueur';
/* Attribution des priviléges select et insert sur le role joueur, pour qu'il puisse créer une commande et lire toutes les commandes*/
GRANT SELECT, INSERT ON db_space_invaders.t_commande TO 'joueur';
/*Création de l'utilisateur joueur1 */
CREATE USER 'joueur1'@'localhost' IDENTIFIED BY '1234';
/* Attribution du role joueur a l'utilisateur joueur1 */
GRANT 'joueur' TO 'joueur1'@'localhost';
SET DEFAULT ROLE 'joueur' TO 'joueur1'@'localhost';


/* Creation du role gestboutique*/
CREATE ROLE 'gestboutique';
/* Attribution du privilege select au role gestboutique sur la table t_joueur */
GRANT SELECT ON db_space_invaders.t_joueur TO 'gestboutique';
/* Attribution de tout les privileges au role gestboutique sur la table t_arme */
GRANT ALL PRIVILEGES ON db_space_invaders.t_arme TO 'gestboutique';
/* Attribution du privilege select au role gestboutique sur la table t_commande */
GRANT SELECT ON db_space_invaders.t_commande TO 'gestboutique';
/* Création de l'utilisateur gestboutique1 */ 
CREATE USER 'gestboutique1'@'localhost' IDENTIFIED BY '1234';
/* Attribution du role gestboutique a l'utilisateur gestboutique1*/
GRANT 'gestboutique' TO 'gestboutique1'@'localhost';
SET DEFAULT ROLE 'gestboutique' TO 'gestboutique1'@'localhost';


/* Recharge les tables de privileges */
FLUSH PRIVILEGES;

/* ////////////////////////////////////////// Requete de selection ///////////////////////////////////////// */


/* Requete 1 */

SELECT * 
FROM t_joueur 
ORDER BY jouNombrePoints DESC LIMIT 5; 

/* Requete 2 */

SELECT MAX(armPrix) AS PrixMaximum, MIN(armPrix) AS PrixMinimum, AVG(armPrix) AS PrixMoyen 
FROM t_arme;

/* Requete 3 */

SELECT fkJoueur AS IdJoueur, COUNT(idCommande) AS NombreCommandes 
FROM t_commande 
GROUP BY fkJoueur 
ORDER BY NombreCommandes DESC;

/* Requete 4 */

SELECT fkJoueur AS IdJoueur, COUNT(idCommande) AS NombreCommandes 
FROM t_commande 
GROUP BY fkJoueur 
HAVING NombreCommandes > 2;

/* Requete 5 */

SELECT DISTINCT jouPseudo, armNom 
FROM t_joueur 
JOIN t_commande 
ON fkJoueur = idJoueur 
JOIN t_detail_commande 
ON fkCommande = idCommande 
JOIN t_arme 
ON fkArme = idArme;

/* Requete 6 */

SELECT idJoueur AS IdJoueur, SUM(armPrix) AS TotalDepense 
FROM t_joueur 
JOIN t_commande 
ON fkJoueur = idJoueur 
JOIN t_detail_commande 
ON fkCommande = idCommande 
JOIN t_arme 
ON fkArme = idArme 
GROUP BY idJoueur 
ORDER BY TotalDepense DESC LIMIT 10;

/* Requete 7 */

SELECT jouPseudo, idCommande 
FROM t_joueur 
LEFT JOIN t_commande 
ON fkJoueur = idJoueur;

/* Requete 8 */

SELECT jouPseudo, idCommande 
FROM t_joueur 
RIGHT JOIN t_commande 
ON fkJoueur = idJoueur;

/* Requete 9 */

SELECT jouPseudo, SUM(detQuantiteCommande) 
FROM t_joueur 
LEFT JOIN t_commande 
ON fkJoueur = idJoueur 
LEFT JOIN t_detail_commande 
ON idCommande = fkCommande
GROUP BY jouPseudo; 

/* Requete 10 */

SELECT jouPseudo, COUNT( DISTINCT armNom) AS Total_Armes 
FROM t_joueur 
JOIN t_commande 
ON fkJoueur = idJoueur 
JOIN t_detail_commande 
ON fkCommande = idCommande 
JOIN t_arme 
ON fkArme = idArme
GROUP BY jouPseudo 
HAVING Total_Armes > 3;

/* /////////////////////////////////////////////// Création des index //////////////////////////////////////////////////// */
/*
Dans le dump de db_space :

1. Certains index existent déjà. Pourquoi ?
Car certaine contraintes créent automatiquement des index.
A chaque création de clé primaire, un index est crée pour s'assurer que les valeur sont bien unique.
Les contrainte unique crée aussi un index pour s'assurer que les valeurs sont unique.
Ce n'est pas toujours le cas mais parfois des index sont crée lors de la création des clé étrangère, comme dans les base données MySQL pour améliorer les performances des jointures

2. Quels sont les avantages et les inconvénients des index ?

Avantages : 
Les index permettent d'améliorer les performances lors de la recherche, des jointure, du tris des donneés,etc.

Inconvenient :
L'utilisation des index demande plus de performance.

3. Sur quel champ (de quelle table), cela pourrait être pertinent d’ajouter un index ? 
Sur le numéro de commande, car beaucoup de recherche vont être faite avec le numéro de commande 
(Pour pouvoir accéder au informations de éa commande d'un joueur)
Sur le pseudo des joueurs, les joueurs recherche souvent leurs nom entre eux pour par exemple s'ajouter en amis ou voir les données 
les concernant.
Sur le nom des armes, les descriptions de chaque armes sont chercher grace au nom de l'arme.

/* /////////////////////////////////////// Backup / Restor ////////////////////////////////////////*/

/* Nous souhaitons réaliser une sauvegarde (Backup) de la base de données 
db_space_invaders. 
Ensuite, nous souhaitons nous assurer que cette sauvegarde est correcte en la 
rechargeant dans MySQL (opération de restauration) */

/* mysqldump, permet d'exporter une base de données en un fichier sql. -uroot -proot désigne l'utilisateur. --databases permet d'ajouer un 
CREATE DATABASE dans le fichier d'exportation sql.
mysqldump -uroot -proot --databases db_space_invaders > db_space_invaders.sql 
*/

/* Supprime la base de données db_space_invaders 
DROP DATABASE db_space_invaders;
*/



/* Import la base de données db_space_invaders a partir du fichier db_space_invaders.sql 
mysql -uroot -proot db_space_invaders < db_space_invaders.sql 
*/










