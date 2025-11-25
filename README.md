# Classificateur de Fruits Simple

## Description
Cette application Flutter permet de classifier 3 types de fruits : **Pomme**, **Banane** et **Orange** en utilisant l'intelligence artificielle.

## Fonctionnalités
- 📱 Interface utilisateur moderne et intuitive
- 🔐 Système de connexion et d'inscription
- 📸 Prise de photo ou sélection depuis la galerie
- 🤖 Analyse d'image avec IA (simulation)
- 📊 Affichage des résultats avec pourcentage de confiance

## Structure du Projet

### Fichiers Principaux
- `lib/main.dart` - Point d'entrée de l'application
- `lib/screens/home_page.dart` - Page d'accueil principale
- `lib/screens/login_page.dart` - Page de connexion
- `lib/screens/register_page.dart` - Page d'inscription
- `lib/screens/image_analysis_page.dart` - Page d'analyse d'images
- `lib/services/image_analysis_service.dart` - Service d'analyse IA

### Modèle IA
- `assets/model/model.tflite` - Modèle TensorFlow Lite pour la classification
- `assets/model/labels.txt` - Liste des fruits reconnus (Apple, Banana, Orange)

## Comment Utiliser

1. **Connexion** : Entrez vos identifiants ou créez un compte
2. **Accueil** : Cliquez sur "Commencer l'analyse"
3. **Sélection** : Choisissez une image depuis la caméra ou la galerie
4. **Analyse** : Cliquez sur "Analyser l'image"
5. **Résultats** : Consultez les résultats de classification

## Technologies Utilisées
- **Flutter** - Framework de développement mobile
- **Dart** - Langage de programmation
- **TensorFlow Lite** - Modèle d'IA pour la classification
- **Material Design** - Design system de Google

## Développeur
**Kori Abdelaziz** - Étudiant en 5IIR

## Notes
- Cette version utilise des résultats simulés pour la démonstration
- Le modèle IA réel nécessiterait une intégration TensorFlow Lite complète
- Application optimisée pour les débutants avec commentaires détaillés