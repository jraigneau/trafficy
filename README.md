# Trafficy
### Optimisez vos temps de trajet simplement!

**Trafficy** est une application web pour **définir et calculer** au mieux vos temps de **trajet quotidien Domicile-Travail**. 

**Trafficy** s'appuie sur les données de [Google Maps](http://maps.google.fr) en récupérant **chaque jour et sur chaque tranche horaire** les temps de transport en incluant **bouchons et travaux**. 

A partir de ces données, **Trafficy** calcule différentes **métriques** (moyennes par jour, semaine, mois et tranche horaire) pour vous permettre de choisir **le meilleur créneau horaire pour vos trajets**.

### TODO
- Gestion des login/password
  - [DB]ajouts dans la base sur Paths + nouvelle table User
  - [IHM]nouvelle vues
  - [DB][IHM]gestion des emails de création de compte et de perte de mdp
  - [DB][IHM]notion de compte premium
- Gestion de la volumétrie de requetes vers google Maps
  - [SER] Algo de répartition de charge sur le serveur
  - [DB] Ajout de la notion de chemins activés/desactivés
- [IHM] Gestion des messages de retour via flash
- [IHM] Création/édition de chemins
- Consultation des résultats
  - affichage matin/soir
  - moyenne / max / min par horaire et par jour
  - Meilleurs résultats (horaire de départ)