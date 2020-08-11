# Guide de contribution

## Branches

- `master` : Cette branche contient le code stable de l'application. On ne peut y ajouter des modifications qu'en y mergeant des Pull Requests dûment testées et revues.

Toutes les autres branches sont considérées comme des branches de travail.

## Cycle de vie d'une contribution

### Création d'une branche de travail

- Se placer sur la branche `master` et s'assurer qu'elle est à jour :

```sh
git checkout master
git rebase origin/master
```

- Créer la branche de travail :

```sh
git checkout -b <nom-de-la-branche>
```

### Développement

- Coder ce qui doit l'être, ajouter et commiter les fichiers impactés :

```sh
git add <fichiers>
git commit -m "Un message de commit signifiant"
```

Si la branche de travail concerne un ticket existant, terminer le message de commit par `Fixes #<numéro-du-ticket>`.

- Mettre à jour la branche à partir de la dernière version de la branche `master` :

```
git rebase origin/master
```

### Revue de code

- Pousser la branche de travail vers le dépôt distant :

```sh
git push -f origin <nom-de-la-branche>
```

- Créer une Pull Request (PR) : 

```sh
gh pr create
```

- Consulter les éventuels commentaires de revue, échanger à leur sujet et adapter le code en fonction du résultat de la discussion

### Intégration à la branche stable

- Une fois tous les commentaires résolus, merger la branche de travail vers la branche `master` :

```sh
gh pr merge --delete-branch --squash 
```

ET WALA !
