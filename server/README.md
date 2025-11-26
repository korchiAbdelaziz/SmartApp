# Serveur d'inférence Fruit Classifier

Serveur Flask + TensorFlow Lite pour exécuter les prédictions de classification de fruits.

## Installation

### Préalables
- Python 3.8+
- pip

### Setup

```bash
# 1. Créer un virtual environment (optionnel mais recommandé)
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate  # Windows

# 2. Installer les dépendances
pip install -r requirements.txt

# 3. Copier le modèle dans le dossier server/
# Placez model.tflite et labels.txt dans ce dossier

# 4. Lancer le serveur
python app.py
```

## Utilisation

### Health Check
```bash
curl http://localhost:5000/health
```

Réponse :
```json
{"status": "ok", "model": "model.tflite", "labels": 3}
```

### Predict (Classification)
```bash
curl -X POST -F "file=@image.jpg" http://localhost:5000/predict
```

Réponse :
```json
{
  "label": "Banana",
  "index": 1,
  "confidence": 0.95,
  "all_predictions": {
    "Apple": 0.02,
    "Banana": 0.95,
    "Orange": 0.03
  }
}
```

## Configuration

### Variables d'environnement
```bash
export MODEL_PATH=model.tflite
export LABELS_PATH=labels.txt
python app.py
```

Ou directement dans le code (voir `app.py` ligne 20-21).

## Docker (optionnel)

Pour déployer dans un conteneur :

```bash
docker build -t fruit-classifier-server .
docker run -p 5000:5000 -v $(pwd):/app fruit-classifier-server
```

## CORS

Le serveur accepte les requêtes cross-origin (CORS) de n'importe quelle source. Pour restreindre :

Modifiez la ligne `CORS(app)` dans `app.py` :
```python
CORS(app, resources={r"/predict": {"origins": "http://localhost:3000"}})
```

## Troubleshooting

### Model not found
Vérifiez que `model.tflite` et `labels.txt` sont dans le même dossier que `app.py`.

### Port 5000 already in use
Changez le port dans `app.py` (dernière ligne) :
```python
app.run(host='0.0.0.0', port=5001)  # Utiliser le port 5001
```

Puis mettez à jour l'URL dans le code Flutter.

### tensorflow vs tflite_runtime
Le serveur essaie d'importer `tflite_runtime` (plus léger). Si non disponible, il utilise `tensorflow`.
Pour installer seulement tflite_runtime (plus rapide) :
```bash
pip install tflite-runtime
```
Et commentez la ligne `tensorflow` dans `requirements.txt`.

## Notes

- Pour tester localement en web: `flutter run -d chrome` puis uploadez une image.
- Sur réseau local : remplacez `localhost` par l'adresse IP du serveur (ex: `192.168.1.10:5000/predict`).
- En production : déployez sur un service cloud (AWS Lambda, Google Cloud Function, Azure, Heroku) et mettez à jour l'URL dans l'app Flutter.
