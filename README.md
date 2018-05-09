# yggtorrentPrezDocker

Cette image Docker facilite l'automatisation d'upload d'album pour la plateforme YggTorrent.
Elle est encore en phase de développement que je prends sur mon temps libre, mais je suis ouvert à toute proposition d'amélioration !




# Identifiants pour l'API imgur (upload automatique d'image)

Veuillez placer votre client_id (que l'on peut obtenir ici https://api.imgur.com/oauth2/addclient) dans le fichier './scripts/imgur.id' sous la forme 'client-id:2d4...8fa'

# Build de l'image Docker

Tout d'abord, vous devez build l'image Docker pour ensuite l'utiliser. Vous allez donc utiliser le [Dockerfile](./Dockerfile).  
Lancez la commande `docker build . -t yggtorrentprez` et attendez.

# Préparation des dossiers

Il y a deux dossier :
- *input* doit contenir **un seul** album source à convertir, il ne sera pas modifié, un lien plutôt qu'une copie est donc possible (cependant je ne suis pas responsable d'un disfonctionnement et/ou d'une faille)
- *output* est le dossier où les albums seront convertis, ainsi que les sorties des NFO et presentations

Dans un premier temps, veuillez garder les scripts dans le dossier script ; le conteneur viendra les chercher dans ce dossier, et ce pour des raisons de synchronisation si vous voulez modifier/améliorer le script

# Lancement du conteneur

Vous pouvez maintenant lancer le conteneur avec la commande suivante `docker run -v $(pwd)/scripts:/tmp/scripts/ -v $(pwd)/input:/tmp/input -v $(pwd)/output:/tmp/output -it yggtorrentprez`

Explications
- *docker run* lancer un conteneur
- *-v $(pwd)/scripts:/tmp/scripts/* permet de lier le dossier des scripts avec un dossier dans le conteneur, idem pour *output* et *input*
- *-it* permet de garder la main lorsque le script vous demande des informations

# Encore plus flemmard ?

`docker-compose run --rm yggtorrentprez` permet de lancer automatiquement l'image, et de build si besoin
