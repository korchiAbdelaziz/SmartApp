# ⚡ Quick Start Guide

## 🚀 En 3 étapes

### 1. Lancer le serveur Flask
```bash
cd server
python -m pip install -r requirements.txt
python app.py
```
✅ Doit afficher : `Running on http://127.0.0.1:5000`

### 2. Tester le serveur
```bash
# Dans un autre terminal
curl http://localhost:5000/health
```
✅ Réponse : `{"status": "ok", ...}`

### 3. Lancer l'app Flutter Web
```bash
flutter run -d chrome
```
✅ Uploadez une image, vous devez voir la prédiction

---

## 📁 Fichiers Importants

| Fichier | Rôle |
|---------|------|
| `server/app.py` | Serveur Flask avec endpoint `/predict` |
| `server/model.tflite` | Modèle TensorFlow Lite (copié) |
| `server/labels.txt` | Classes/labels (copié) |
| `lib/inference/web_classifier.dart` | Client Web qui envoie images au serveur |
| `lib/screens/classifier_page.dart` | Interface de classification |

---

## 🔧 Commandes Utiles

| Action | Commande |
|--------|----------|
| **Installer dépendances** | `pip install -r server/requirements.txt` |
| **Lancer serveur** | `python server/app.py` |
| **Tester serveur** | `curl http://localhost:5000/health` |
| **App Web** | `flutter run -d chrome` |
| **App Android** | `flutter run -d emulator` |
| **App iOS** | `flutter run -d ios` |
| **App Desktop** | `flutter run -d windows` |

---

## 🐛 Problèmes Courants

### ❌ "Failed to fetch" 
👉 Vérifiez que le serveur est en cours d'exécution

### ❌ "Port 5000 already in use"
👉 Changez le port dans `server/app.py` (dernière ligne)

### ❌ "Model not found"
👉 Vérifiez que `model.tflite` et `labels.txt` sont dans `server/`

### ❌ "Module not found"
👉 Réinstallez : `pip install -r server/requirements.txt`

---

## 📚 Plus d'Info

Voir `SETUP_GUIDE.md` pour la documentation complète.

---

**Status ✅**
- ✅ Serveur Flask créé
- ✅ Modèle copié au serveur
- ✅ Web classifier configuré
- ✅ URL locale définie
- ⏳ À tester : flutter run -d chrome
