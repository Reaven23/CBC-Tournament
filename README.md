# 🏀 Tournament Go

> **Une application de gestion de tournois de basket-ball développée urgement pour répondre aux besoins d'un club de basket, et maintenant disponible pour tous !**

[![Ruby](https://img.shields.io/badge/Ruby-3.1.6-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-7.1.5-red.svg)](https://rubyonrails.org/)
[![Bootstrap](https://img.shields.io/badge/Bootstrap-5.3-blue.svg)](https://getbootstrap.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-blue.svg)](https://www.postgresql.org/)
[![Heroku](https://img.shields.io/badge/Deployed_on-Heroku-purple.svg)](https://heroku.com/)

## 📖 À propos

**Tournament Go** est née d'un besoin concret : organiser rapidement et efficacement un tournoi de basket-ball pour mon association. Face à l'urgence et au manque de solutions adaptées, j'ai développé cette application en moins d'une semaine, en utilisant l'IA pour accélérer le développement frontend et gagner un temps précieux.

L'application s'est révélée si pratique qu'elle peut maintenant servir à d'autres clubs, associations et organisateurs de tournois !

## ✨ Fonctionnalités

### 🏆 Gestion des Tournois
- **Création et configuration** de tournois personnalisés
- **Gestion des équipes** avec couleurs et descriptions
- **Organisation en poules** avec classements automatiques
- **Génération automatique** des phases finales (quarts, demies, finale)

### 📊 Classements et Statistiques
- **Calcul automatique** des classements de poules
- **Règles de basket-ball** : victoires, confrontations directes, goal average
- **Qualification automatique** des meilleurs troisièmes
- **Statistiques détaillées** par équipe et par match

### 👨‍⚖️ Gestion des Arbitres
- **Planning des arbitres** pour chaque match
- **Profils détaillés** des arbitres
- **Interface dédiée** pour consulter les affectations

### 🎮 Interface Utilisateur
- **Design responsive** avec Bootstrap 5
- **Interface intuitive** pour tous les utilisateurs
- **Pages publiques** pour suivre les tournois
- **Espace administrateur** complet


## 🚀 Technologies Utilisées

- **Backend** : Ruby on Rails 7.1.5
- **Base de données** : PostgreSQL
- **Frontend** : Bootstrap 5, Font Awesome, SCSS
- **Authentification** : Devise
- **Hébergement** : Heroku
- **Images** : Cloudinary
- **Développement** : IA assistée (GitHub Copilot, ChatGPT)


## 📱 Utilisation

### Pour les Administrateurs
1. **Créer un tournoi** via l'interface admin
2. **Ajouter les équipes** et les organiser en poules
3. **Assigner les arbitres** aux matchs
4. **Générer les matchs** de poules et phases finales
5. **Saisir les scores** et suivre les classements

### Pour le Public
1. **Consulter les tournois** en cours
2. **Suivre les classements** en temps réel
3. **Voir les détails** des matchs et équipes
4. **Consulter les planning** des arbitres

## ⚠️⚠️⚠️⚠️ Limitations Actuelles  ⚠️⚠️⚠️⚠️

### Scalabilité
- **Architecture monolithique** : L'application est conçue pour des tournois de taille spécifique, avec un nombre d'équipe spécifique et un nombre de poule spécifique. Il faut rendre cette partie plus scalable et évolutive.
- **Requêtes non optimisées** : Certaines parties nécessitent une refactorisation pour de gros volumes
- **Gestion mémoire** : Les calculs de classements peuvent être lents avec beaucoup d'équipes

### Fonctionnalités Manquantes
- **Système de notifications** en temps réel
- **Système de paiement** pour les inscriptions
- **Export des données** (PDF, Excel)

## 🤝 Contribution

Ce projet est open-source ! Les contributions sont les bienvenues :

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request


**Contact** : [tournamentgo.contact@gmail.com]

## 🌐 Site Web

**Tournament Go** est disponible en ligne : [https://www.tournamentgo.live](https://www.tournamentgo.live)

## 🙏 Remerciements

- À mon club de basket pour l'inspiration
- À la communauté Rails pour les ressources
- À l'IA pour l'accélération du développement
- À tous les testeurs et utilisateurs

---

**Tournament Go** - *Parce que chaque tournoi mérite d'être bien organisé !* 🏀
