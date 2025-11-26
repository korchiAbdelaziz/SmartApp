# Script de lancement du serveur Flask
# Pour Windows PowerShell

# Vérifier si Python est installé
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✓ Python trouvé: $pythonVersion"
} catch {
    Write-Host "✗ Python n'est pas installé ou n'est pas dans le PATH"
    exit 1
}

# Vérifier si le fichier requirements.txt existe
if (-Not (Test-Path "requirements.txt")) {
    Write-Host "✗ requirements.txt non trouvé dans le répertoire courant"
    exit 1
}

# Vérifier si le modèle existe
if (-Not (Test-Path "model.tflite")) {
    Write-Host "⚠ ATTENTION: model.tflite non trouvé. Le serveur ne fonctionnera pas."
}

if (-Not (Test-Path "labels.txt")) {
    Write-Host "⚠ ATTENTION: labels.txt non trouvé. Le serveur ne fonctionnera pas."
}

# Installer les dépendances
Write-Host ""
Write-Host "📦 Installation des dépendances..."
Write-Host "Exécution: python -m pip install -r requirements.txt"
Write-Host ""
python -m pip install -r requirements.txt

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Erreur lors de l'installation des dépendances"
    exit 1
}

Write-Host ""
Write-Host "✓ Dépendances installées"
Write-Host ""
Write-Host "🚀 Lancement du serveur Flask..."
Write-Host "Le serveur sera disponible à: http://localhost:5000"
Write-Host "Endpoint de prédiction: http://localhost:5000/predict"
Write-Host ""
Write-Host "IMPORTANT:"
Write-Host "- Gardez ce terminal ouvert pendant que vous testez l'app Flutter"
Write-Host "- Appuyez sur Ctrl+C pour arrêter le serveur"
Write-Host ""

# Lancer le serveur
python app.py
