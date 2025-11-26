# 📁 Structure du Projet - Fruit Classifier

## 🏗️ Architecture

```
fruit_classifier/
│
├── 📱 FLUTTER (Frontend Multi-Plateforme)
│   ├── lib/
│   │   ├── main.dart                      # Point d'entrée de l'app
│   │   ├── screens/
│   │   │   ├── home_page.dart            # Page d'accueil
│   │   │   ├── login_page.dart           # Authentification (Firebase)
│   │   │   ├── register_page.dart        # Inscription
│   │   │   └── classifier_page.dart      # 🎯 UI Classification (cible)
│   │   ├── inference/
│   │   │   ├── inference_interface.dart  # Interface abstraite (IClassifier)
│   │   │   ├── native_classifier.dart    # Impl. Android/iOS/Desktop (TFLite local)
│   │   │   ├── web_classifier.dart       # Impl. Web (HTTP REST API)
│   │   │   └── classifier.dart           # Wrapper TFLite pour native
│   │   ├── firebase_options.dart         # Config Firebase
│   │   └── stubs/
│   │       └── tflite_flutter_stub.dart  # Stub pour Web (evite erreurs import)
│   │
│   ├── assets/
│   │   ├── images/                       # Logos, icônes
│   │   └── model/
│   │       ├── model.tflite              # Modèle TFLite (32×32)
│   │       └── labels.txt                # Classes: Apple, Banana, Orange
│   │
│   ├── pubspec.yaml                      # Dépendances Flutter
│   ├── web/                              # Web assets
│   ├── ios/                              # Config iOS
│   ├── android/                          # Config Android
│   ├── windows/                          # Config Windows Desktop
│   ├── linux/                            # Config Linux Desktop
│   └── macos/                            # Config macOS Desktop
│
├── 🖥️ SERVER (Backend Flask - Inférence Web)
│   ├── app.py                            # 🎯 Serveur principal
│   ├── requirements.txt                  # Dépendances Python (Flask, TFLite, etc.)
│   ├── model.tflite                      # Copie du modèle
│   ├── labels.txt                        # Copie des labels
│   ├── run.ps1                           # Script démarrage (PowerShell)
│   ├── run.bat                           # Script démarrage (CMD)
│   ├── README.md                         # Doc serveur
│   └── debug_uploads/                    # (Auto-créé) Images de debug
│
├── 📚 DOCUMENTATION
│   ├── README.md                         # Vue d'ensemble + Quick Start
│   ├── INDEX.md                          # Index de navigation
│   ├── QUICK_START.md                    # 3 étapes pour démarrer
│   └── STRUCTURE.md                      # 📍 Vous êtes ici
│
├── 🔧 CONFIGURATION
│   ├── pubspec.yaml                      # Dépendances Flutter/Dart
│   ├── analysis_options.yaml             # Règles lint
│   ├── firebase.json                     # Firebase config
│   └── .gitignore                        # Fichiers à ignorer Git
│
└── 📦 BUILD & CACHE (Auto-générés, à ignorer)
    ├── build/                            # Artefacts de compilation
    ├── .dart_tool/                       # Cache Dart
    ├── pubspec.lock                      # Versions verrouillées
    └── .flutter-plugins-dependencies     # Cache plugins
```

---

## 🎯 Points Clés

### 1️⃣ **Frontend Flutter** (`lib/`)
- **`classifier_page.dart`** — UI principale où l'utilisateur upload une image
- Détecte plateforme (`kIsWeb`) et choisit implémentation:
  - ✅ **Web**: `WebClassifier` → HTTP POST au serveur
  - ✅ **Native**: `NativeClassifier` → TFLite local (rapide, sans serveur)

### 2️⃣ **Backend Flask** (`server/app.py`)
- Charge modèle TFLite
- Endpoint `/predict` — accepte multipart image, retourne JSON
- Endpoint `/health` — vérification serveur
- Prétraitement: uint8 (0-255) → modèle (let Rescaling layer normalize)

### 3️⃣ **Architecture Multi-Plateforme**
```
Interface: IClassifier
    ↓
    ├─ Web: WebClassifier (HTTP REST)
    │   └─ Hits: http://localhost:5000/predict
    │
    └─ Native: NativeClassifier (TFLite local)
        └─ Hits: assets/model/model.tflite directly
```

---

## 🚀 Utilisation

### Lancer le serveur (pour Web)
```bash
cd server
python -m pip install -r requirements.txt
python app.py
```

### Lancer l'app Flutter
```bash
# Web (Chrome) - nécessite serveur
flutter run -d chrome

# Mobile (Android)
flutter run -d emulator

# Desktop (Windows)
flutter run -d windows
```

---

## 📦 Dépendances

### Python (`server/requirements.txt`)
- Flask 3.0.0 — Web framework
- flask_cors 4.0.0 — CORS pour navigateur
- TensorFlow 2.14.0 — TFLite inférence
- Pillow — Image processing

### Dart (`pubspec.yaml`)
- flutter — Framework
- tflite_flutter ^0.12.1 — TFLite pour Android/iOS
- image_picker ^1.1.1 — Galerie/caméra
- image ^4.1.7 — Traitement images
- http ^1.5.0 — Requêtes HTTP (Web)
- firebase_core, firebase_auth — Auth Firebase

---

## 📊 Modèle TFLite

| Propriété | Valeur |
|-----------|--------|
| **Input** | 32×32×3 (RGB) uint8 (0-255) |
| **Output** | 3 logits (Apple, Banana, Orange) |
| **Normalisation** | Rescaling(1./255) dans le modèle |
| **Taille** | ~150 KB |

---

## ⚡ Points Importants

✅ **Serveur écoute sur**: http://localhost:5000  
✅ **Web utilise**: http://localhost:5000/predict  
✅ **Native utilise**: TFLite local (pas de serveur)  
✅ **Labels alignés**: Apple (idx 0), Banana (idx 1), Orange (idx 2)  
✅ **Modèle prétraité**: uint8 (0-255), pas float32 (0-1)  

---

## 🔗 Fichiers Essentiels à Modifier

| Besoin | Fichier |
|--------|---------|
| Changer UI | `lib/screens/classifier_page.dart` |
| Ajouter classe | `assets/model/labels.txt` + réentraîner `model.tflite` |
| Changer URL serveur | `lib/screens/classifier_page.dart` ligne ~38 |
| Ajouter authentification | `lib/screens/login_page.dart` |
| Déployer serveur | `server/app.py` sur Heroku/AWS/GCP |

---

**Status:** ✅ Production Ready  
**Dernière mise à jour:** 26 novembre 2025
