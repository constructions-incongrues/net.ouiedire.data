# net.ouiedire.data

## Présentation

Cette application est destinée à la gestion des données du site https://www.ouiedire.net.

Basée sur [Directus](https://directus.io/) elle permet notamment :

- La gestion des données via une interface graphique
- La mise à disposition des données sous forme d'API REST et GraphQL

## Développement

### Pré-requis

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Git](https://git-scm.com/)
- [Make](https://www.gnu.org/software/make/)

### Composants

#### Application

- [`directus`](https://directus.io/) : API dynamique, permet d'administrer entre autre la base de données
- `db` : Serveur des bases de données de l'application

#### Outils de maintenance et surveillance

- [`adminer`](https://www.adminer.org) : Interface graphique de gestion des bases de données du service `db`
- [`portainer`](https://www.portainer.io) : Interface graphique de gestion du serveur Docker
- [`traefik`](https://www.traefik.io) : Routeur HTTP et TCP. Point d'entrée vers les différents services de l'applications

### Interface en ligne de commande

L'application expose un jeu d'outils destiné au contrôle et au développement d

La liste des commandes et leur documentation peut être obtenue en exécutant la commande suivante :

```sh
make help
```

### Cookbooks

#### Démarrer l'application et des outils de développement

```sh
make dev
```

L'exécution de cette commande affiche la liste des URL accessibles.

#### Se connecter à Directus

- <http://directus.net.ouiedire.www.localhost>
- Nom d'utilisateur : `admin@data.ouiedire.net`
- Mot de passe : `admin`

#### Exporter la base de données Directus

```sh
make db.dump
```

### Contribuer au projet

Se référer au [guide de contribution](/CONTRIBUTING.md).

