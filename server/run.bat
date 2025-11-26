@echo off
REM Script de lancement du serveur Flask pour Windows CMD

echo Verification de Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo ✗ Python n'est pas installe ou n'est pas dans le PATH
    pause
    exit /b 1
)

echo ✓ Python trouve

REM Vérifier si requirements.txt existe
if not exist requirements.txt (
    echo ✗ requirements.txt non trouve dans le repertoire courant
    pause
    exit /b 1
)

REM Vérifier si le modèle existe
if not exist model.tflite (
    echo ⚠ ATTENTION: model.tflite non trouve. Le serveur ne fonctionnera pas.
)

if not exist labels.txt (
    echo ⚠ ATTENTION: labels.txt non trouve. Le serveur ne fonctionnera pas.
)

echo.
echo Installation des dependances...
echo Execution: python -m pip install -r requirements.txt
echo.
python -m pip install -r requirements.txt

if errorlevel 1 (
    echo ✗ Erreur lors de l'installation des dependances
    pause
    exit /b 1
)

echo.
echo ✓ Dependances installees
echo.
echo Lancement du serveur Flask...
echo Le serveur sera disponible a: http://localhost:5000
echo Endpoint de prediction: http://localhost:5000/predict
echo.
echo IMPORTANT:
echo - Gardez ce terminal ouvert pendant que vous testez l'app Flutter
echo - Appuyez sur Ctrl+C pour arreter le serveur
echo.
pause

python app.py
pause
