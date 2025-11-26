# 🍎 Fruit Classifier

Classification de fruits en temps réel avec **TensorFlow Lite** sur Web, Mobile et Desktop.

---

## 🚀 Quick Start (2 min)

### 1. Lancer le serveur (pour Web)
```bash
cd server
python -m pip install -r requirements.txt
python app.py
```

### 2. Lancer l'app Flutter
```bash
# Web (Chrome)
flutter run -d chrome

# Mobile (Android)
flutter run -d emulator

# Desktop (Windows)
flutter run -d windows
```

### 3. Classifier une image
- Cliquez "Classifier une image"
- Sélectionnez/uploadez une image
- **Résultat:** `Apple`, `Banana`, ou `Orange` ✅

---

## 📊 Plateformes

| Plateforme | Inférence | Status |
|-----------|-----------|--------|
| **Web** | Serveur Flask (REST API) | ✅ |
| **Android/iOS** | TFLite local | ✅ |
| **Windows/macOS** | TFLite local | ✅ |

---

## 📁 Organisation

```
fruit_classifier/
├── lib/                     # Code Flutter
│   ├── screens/classifier_page.dart
│   └── inference/           # Multi-platform logic
├── server/                  # Backend Flask
│   └── app.py              # Serveur inférence
├── assets/model/           # Modèle TFLite
└── README.md, STRUCTURE.md, QUICK_START.md  # Docs
```

**Voir [STRUCTURE.md](STRUCTURE.md) pour détails complets.**

---

## 📚 Documentation

- **[QUICK_START.md](QUICK_START.md)** — 3 étapes pour démarrer
- **[STRUCTURE.md](STRUCTURE.md)** — Organisation du code
- **[INDEX.md](INDEX.md)** — Index de navigation
- **[server/README.md](server/README.md)** — Doc serveur Flask

---

## 🛠️ Stack

**Frontend:** Flutter 3.35.5 + Dart 3.9.2  
**Backend:** Flask 3.0.0 + Python 3.10+  
**ML:** TensorFlow Lite (32×32×3 RGB)  
**Auth:** Firebase

---

## ⚙️ Config

### URL serveur (app Flutter)
```dart
// lib/screens/classifier_page.dart, ligne ~38
Uri.parse('http://localhost:5000/predict')
```

### Variables d'environnement (serveur)
```bash
export MODEL_PATH=model.tflite
export LABELS_PATH=labels.txt
```

---

## 📊 Modèle

- **Input:** 32×32 RGB (uint8, 0-255)
- **Output:** 3 logits (Apple, Banana, Orange)
- **Accuracy:** 94% (test set)

---

## 🐛 Aide Rapide

| Erreur | Solution |
|--------|----------|
| "Failed to fetch" | Vérifier serveur lancé |
| Port 5000 occupé | Changer port dans `server/app.py` |
| Import error | `pip install -r server/requirements.txt` |
| App won't compile | `flutter clean && flutter pub get` |

---

## 📞 Points Clés

- **UI:** `lib/screens/classifier_page.dart`
- **Serveur:** `server/app.py`
- **Modèle:** `assets/model/model.tflite`

---

**Status:** ✅ Production Ready  
**Dernière mise à jour:** 26 novembre 2025
