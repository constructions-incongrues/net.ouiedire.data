

# net.ouiedire.www (v0.0.0-1-gf571844)

## Pré-requis

Les logiciels suivant doivent être installés sur la machine hôte :

- [Github CLI](https://cli.github.com/)
- [Docker](https://www.docker.com/)

## Présentation

### Principales fonctionnalités

- Bibliothèque de compilations d'une multitude de personnes invité.es 
- Pour l'utilisateur: écouter et télécharger les différentes compilations 
- Pour l'administrateur: ajout de nouvelles compilations

### Services

#### Application

- `apache` : Image Docker basée sur l'image [php:apache](https://hub.docker.com/layers/php/library/php/7.4.8-apache/images/sha256-d64789a928c6ff660e94567ad044aec6dded6a5b2cc60ee6f131ae50b1b6d53a?context=explore). Elle embarque les sources de l'application
- `db` : Serveur des bases de données de l'application

#### Outils de maintenance et surveillance

- [`adminer`](https://www.adminer.org) : Interface graphique de gestion des bases de données du service `db`
- [`portainer`](https://www.portainer.io) : Interface graphique de gestion du serveur Docker
- [`traefik`](https://www.traefik.io) : Routeur HTTP et TCP. Point d'entrée vers les différents services de l'applications
- [`directus`](https://directus.io/) : API dynamique, permet d'administrer entre autre la base de données 

## Utilisation


## Développement

### Commandes 

- clean : suppression des conteneurs. Les volumes sont conservés

```sh
make clean
```

- help : Affichage de ce message d'aide et des informations urls publiques

```sh
make help
```

- start :  Démarrage de de l'application 

```sh
make start
```

- stop : Arrêt de l'application 

```sh 
make stop
```

## URL publiques 

### Application

- Page d'acceuil: (http://net.ouiedire.www.localhost)

### Outils

- Adminer: http://adminer.net.ouiedire.www.localhost
- Portainer: http://portainer.net.ouiedire.www.localhost
- Traefik: http://traefik.net.ouiedire.www.localhost
- Directus: (soon) 


