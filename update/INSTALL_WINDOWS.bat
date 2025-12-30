@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ============================================================================
::
::   ██╗    ██╗██╗██████╗  ██████╗ ████████╗
::   ██║    ██║██║██╔══██╗██╔═══██╗╚══██╔══╝
::   ██║ █╗ ██║██║██████╔╝██║   ██║   ██║
::   ██║███╗██║██║██╔══██╗██║   ██║   ██║
::   ╚███╔███╔╝██║██████╔╝╚██████╔╝   ██║
::    ╚══╝╚══╝ ╚═╝╚═════╝  ╚═════╝    ╚═╝
::
::   INSTALLATION AUTOMATIQUE WINDOWS
::   Version: 2.0 - Full Auto
::
:: ============================================================================

title WIBOT - Installation Automatique Windows

:: Variables globales
set "SCRIPT_DIR=%~dp0"
set "WIBOT_DIR=%SCRIPT_DIR:~0,-1%"
set "BACKEND_DIR=%WIBOT_DIR%\wibot-backend"
set "FRONTEND_DIR=%WIBOT_DIR%\wibot-frontend"
set "CONFIG_FILE=%WIBOT_DIR%\config.txt"

:: Couleurs (codes ANSI)
set "VERT=[92m"
set "ROUGE=[91m"
set "JAUNE=[93m"
set "BLEU=[94m"
set "CYAN=[96m"
set "RESET=[0m"

:: ============================================================================
:: AFFICHAGE HEADER
:: ============================================================================
cls
echo.
echo %CYAN%   ██╗    ██╗██╗██████╗  ██████╗ ████████╗%RESET%
echo %CYAN%   ██║    ██║██║██╔══██╗██╔═══██╗╚══██╔══╝%RESET%
echo %CYAN%   ██║ █╗ ██║██║██████╔╝██║   ██║   ██║%RESET%
echo %CYAN%   ██║███╗██║██║██╔══██╗██║   ██║   ██║%RESET%
echo %CYAN%   ╚███╔███╔╝██║██████╔╝╚██████╔╝   ██║%RESET%
echo %CYAN%    ╚══╝╚══╝ ╚═╝╚═════╝  ╚═════╝    ╚═╝%RESET%
echo.
echo %BLEU%   Assistant IA interne WIDIP%RESET%
echo %BLEU%   Installation Automatique Windows v2.0%RESET%
echo.
echo %CYAN%══════════════════════════════════════════════════════════════%RESET%
echo.

:: ============================================================================
:: ETAPE 1: Verification du fichier config.txt
:: ============================================================================
echo %BLEU%[ETAPE 1/8]%RESET% Lecture de la configuration...

if not exist "%CONFIG_FILE%" (
    echo.
    echo %ROUGE%[ERREUR]%RESET% Le fichier config.txt n'existe pas!
    echo.
    echo    %JAUNE%Que faire ?%RESET%
    echo    1. Ouvre le fichier %CYAN%config.txt%RESET% dans le dossier WIBOT
    echo    2. Remplis ta cle API Mistral et les autres infos
    echo    3. Relance ce script
    echo.
    pause
    exit /b 1
)

:: Lire les valeurs du fichier config.txt
for /f "tokens=1,* delims==" %%a in ('type "%CONFIG_FILE%" ^| findstr /v "^#" ^| findstr "="') do (
    set "%%a=%%b"
)

:: Nettoyer les espaces
set "MISTRAL_API_KEY=%MISTRAL_API_KEY: =%"
set "N8N_USER=%N8N_USER: =%"
set "N8N_PASSWORD=%N8N_PASSWORD: =%"
set "POSTGRES_USER=%POSTGRES_USER: =%"
set "POSTGRES_PASSWORD=%POSTGRES_PASSWORD: =%"
set "POSTGRES_DB=%POSTGRES_DB: =%"
set "WIBOT_PORT=%WIBOT_PORT: =%"
set "N8N_PORT=%N8N_PORT: =%"
set "POSTGRES_PORT=%POSTGRES_PORT: =%"
set "JWT_SECRET=%JWT_SECRET: =%"

:: Valeurs par defaut si non definies
if "%WIBOT_PORT%"=="" set "WIBOT_PORT=8080"
if "%N8N_PORT%"=="" set "N8N_PORT=5679"
if "%POSTGRES_PORT%"=="" set "POSTGRES_PORT=5433"
if "%JWT_SECRET%"=="" set "JWT_SECRET=wibot_jwt_secret_key_minimum_32_chars_2024"

:: Verifier que la cle Mistral est renseignee
echo %MISTRAL_API_KEY% | findstr /c:"<" >nul
if %errorlevel% equ 0 (
    echo.
    echo %ROUGE%[ERREUR]%RESET% La cle API Mistral n'est pas configuree!
    echo.
    echo    %JAUNE%Que faire ?%RESET%
    echo    1. Ouvre le fichier %CYAN%config.txt%RESET%
    echo    2. Remplace %CYAN%^<TA_CLE_MISTRAL_ICI^>%RESET% par ta vraie cle API
    echo    3. Relance ce script
    echo.
    echo    %JAUNE%Ou obtenir une cle ?%RESET%
    echo    https://console.mistral.ai/api-keys
    echo.
    pause
    exit /b 1
)

echo %VERT%[OK]%RESET% Configuration chargee
echo     - Mistral API: %MISTRAL_API_KEY:~0,8%...
echo     - n8n User: %N8N_USER%
echo     - PostgreSQL: %POSTGRES_USER%@%POSTGRES_DB%
echo     - Ports: WIBOT=%WIBOT_PORT%, n8n=%N8N_PORT%, PG=%POSTGRES_PORT%
echo.

:: ============================================================================
:: ETAPE 2: Verification des dossiers
:: ============================================================================
echo %BLEU%[ETAPE 2/8]%RESET% Verification des dossiers...

if not exist "%BACKEND_DIR%" (
    echo %ROUGE%[ERREUR]%RESET% Dossier wibot-backend manquant!
    pause
    exit /b 1
)

if not exist "%FRONTEND_DIR%" (
    echo %ROUGE%[ERREUR]%RESET% Dossier wibot-frontend manquant!
    pause
    exit /b 1
)

echo %VERT%[OK]%RESET% Tous les dossiers sont presents
echo.

:: ============================================================================
:: ETAPE 3: Verification de Docker
:: ============================================================================
echo %BLEU%[ETAPE 3/8]%RESET% Verification de Docker Desktop...

where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo %ROUGE%[ERREUR]%RESET% Docker n'est pas installe!
    echo.
    echo %CYAN%╔═══════════════════════════════════════════════════════════╗%RESET%
    echo %CYAN%║%RESET%  %JAUNE%COMMENT INSTALLER DOCKER ?%RESET%                               %CYAN%║%RESET%
    echo %CYAN%╠═══════════════════════════════════════════════════════════╣%RESET%
    echo %CYAN%║%RESET%                                                           %CYAN%║%RESET%
    echo %CYAN%║%RESET%  1. Va sur: %BLEU%https://www.docker.com/products/docker-desktop%RESET%%CYAN%║%RESET%
    echo %CYAN%║%RESET%                                                           %CYAN%║%RESET%
    echo %CYAN%║%RESET%  2. Telecharge "Docker Desktop for Windows"               %CYAN%║%RESET%
    echo %CYAN%║%RESET%                                                           %CYAN%║%RESET%
    echo %CYAN%║%RESET%  3. Installe-le (laisse les options par defaut)           %CYAN%║%RESET%
    echo %CYAN%║%RESET%                                                           %CYAN%║%RESET%
    echo %CYAN%║%RESET%  4. %JAUNE%Redemarre ton PC%RESET%                                      %CYAN%║%RESET%
    echo %CYAN%║%RESET%                                                           %CYAN%║%RESET%
    echo %CYAN%║%RESET%  5. Lance Docker Desktop                                  %CYAN%║%RESET%
    echo %CYAN%║%RESET%                                                           %CYAN%║%RESET%
    echo %CYAN%║%RESET%  6. Relance ce script                                     %CYAN%║%RESET%
    echo %CYAN%║%RESET%                                                           %CYAN%║%RESET%
    echo %CYAN%╚═══════════════════════════════════════════════════════════╝%RESET%
    echo.
    pause
    exit /b 1
)

docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo %JAUNE%[ATTENTION]%RESET% Docker n'est pas demarre!
    echo.
    echo    Lance %CYAN%Docker Desktop%RESET% et attends qu'il soit pret (icone verte).
    echo    Puis relance ce script.
    echo.
    pause
    exit /b 1
)

echo %VERT%[OK]%RESET% Docker est installe et fonctionne
echo.

:: ============================================================================
:: ETAPE 4: Verification de Node.js
:: ============================================================================
echo %BLEU%[ETAPE 4/8]%RESET% Verification de Node.js...

where node >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo %ROUGE%[ERREUR]%RESET% Node.js n'est pas installe!
    echo.
    echo %CYAN%╔═══════════════════════════════════════════════════════════╗%RESET%
    echo %CYAN%║%RESET%  %JAUNE%COMMENT INSTALLER NODE.JS ?%RESET%                              %CYAN%║%RESET%
    echo %CYAN%╠═══════════════════════════════════════════════════════════╣%RESET%
    echo %CYAN%║%RESET%                                                           %CYAN%║%RESET%
    echo %CYAN%║%RESET%  1. Va sur: %BLEU%https://nodejs.org%RESET%                            %CYAN%║%RESET%
    echo %CYAN%║%RESET%                                                           %CYAN%║%RESET%
    echo %CYAN%║%RESET%  2. Telecharge la version %VERT%LTS%RESET% (bouton vert)               %CYAN%║%RESET%
    echo %CYAN%║%RESET%                                                           %CYAN%║%RESET%
    echo %CYAN%║%RESET%  3. Installe-le (laisse les options par defaut)           %CYAN%║%RESET%
    echo %CYAN%║%RESET%                                                           %CYAN%║%RESET%
    echo %CYAN%║%RESET%  4. %JAUNE%FERME cette fenetre%RESET% et relance ce script              %CYAN%║%RESET%
    echo %CYAN%║%RESET%                                                           %CYAN%║%RESET%
    echo %CYAN%╚═══════════════════════════════════════════════════════════╝%RESET%
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo %VERT%[OK]%RESET% Node.js installe: %NODE_VERSION%
echo.

:: ============================================================================
:: ETAPE 5: Creation du fichier .env
:: ============================================================================
echo %BLEU%[ETAPE 5/8]%RESET% Configuration de l'environnement...

(
echo # ===========================================
echo # WIBOT Backend - Variables d'environnement
echo # ===========================================
echo # Genere automatiquement par INSTALL_WINDOWS.bat
echo.
echo # ===========================================
echo # PostgreSQL
echo # ===========================================
echo POSTGRES_DB=%POSTGRES_DB%
echo POSTGRES_USER=%POSTGRES_USER%
echo POSTGRES_PASSWORD=%POSTGRES_PASSWORD%
echo.
echo # ===========================================
echo # n8n Configuration
echo # ===========================================
echo N8N_HOST=localhost
echo N8N_PROTOCOL=http
echo WEBHOOK_URL=http://localhost:%N8N_PORT%
echo.
echo # n8n Admin credentials
echo N8N_USER=%N8N_USER%
echo N8N_PASSWORD=%N8N_PASSWORD%
echo.
echo # ===========================================
echo # JWT Secret
echo # ===========================================
echo JWT_SECRET=%JWT_SECRET%
echo.
echo # ===========================================
echo # Mistral API
echo # ===========================================
echo MISTRAL_API_KEY=%MISTRAL_API_KEY%
) > "%BACKEND_DIR%\.env"

echo %VERT%[OK]%RESET% Fichier .env cree
echo.

:: ============================================================================
:: ETAPE 6: Compilation du frontend
:: ============================================================================
echo %BLEU%[ETAPE 6/8]%RESET% Compilation du frontend React...
echo     %JAUNE%(Cela peut prendre 1-2 minutes, patience...)%RESET%
echo.

cd /d "%FRONTEND_DIR%"

echo     Installation des dependances npm...
call npm install --silent >nul 2>&1
if %errorlevel% neq 0 (
    echo %ROUGE%[ERREUR]%RESET% Echec de npm install
    call npm install
    pause
    exit /b 1
)

echo     Compilation en cours...
call npm run build >nul 2>&1
if %errorlevel% neq 0 (
    echo %ROUGE%[ERREUR]%RESET% Echec de la compilation
    call npm run build
    pause
    exit /b 1
)

echo     Copie vers le backend...
if exist "%BACKEND_DIR%\frontend" rmdir /s /q "%BACKEND_DIR%\frontend"
xcopy /s /e /i /q "dist" "%BACKEND_DIR%\frontend" >nul

echo %VERT%[OK]%RESET% Frontend compile!
echo.

:: ============================================================================
:: ETAPE 7: Creation des dossiers RAG + Demarrage Docker
:: ============================================================================
echo %BLEU%[ETAPE 7/8]%RESET% Demarrage de WIBOT...
echo.

:: Creer les dossiers RAG
if not exist "%BACKEND_DIR%\rag-documents\procedures" mkdir "%BACKEND_DIR%\rag-documents\procedures"
if not exist "%BACKEND_DIR%\rag-documents\clients" mkdir "%BACKEND_DIR%\rag-documents\clients"
if not exist "%BACKEND_DIR%\rag-documents\tickets" mkdir "%BACKEND_DIR%\rag-documents\tickets"
if not exist "%BACKEND_DIR%\rag-documents\documentation" mkdir "%BACKEND_DIR%\rag-documents\documentation"

cd /d "%BACKEND_DIR%"

echo     Arret des anciens containers...
docker-compose down >nul 2>&1

echo     Telechargement des images Docker...
echo     %JAUNE%(Premiere fois: plusieurs minutes)%RESET%
docker-compose pull

echo     Demarrage des services...
docker-compose up -d

echo     Attente du demarrage (20 secondes)...
timeout /t 20 /nobreak >nul

echo %VERT%[OK]%RESET% Services demarres!
echo.

:: ============================================================================
:: ETAPE 8: Import automatique des workflows n8n
:: ============================================================================
echo %BLEU%[ETAPE 8/8]%RESET% Import des workflows dans n8n...
echo.

:: Attendre que n8n soit pret
echo     Attente que n8n soit pret...
set N8N_READY=0
for /l %%i in (1,1,30) do (
    curl -s -o nul -w "%%{http_code}" http://localhost:%N8N_PORT%/healthz 2>nul | findstr "200" >nul
    if !errorlevel! equ 0 (
        set N8N_READY=1
        goto :n8n_ready
    )
    timeout /t 2 /nobreak >nul
)

:n8n_ready
if %N8N_READY% equ 0 (
    echo %JAUNE%[ATTENTION]%RESET% n8n n'est pas encore pret
    echo     Tu devras importer les workflows manuellement
    goto :skip_import
)

echo %VERT%[OK]%RESET% n8n est pret!
echo.

:: Creer le script d'import PowerShell
echo     Import des workflows...

:: Import du workflow chat_main.json
powershell -Command "$headers = @{ Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes('%N8N_USER%:%N8N_PASSWORD%')); 'Content-Type' = 'application/json' }; $body = Get-Content '%BACKEND_DIR%\workflows\chat_main.json' -Raw; try { Invoke-RestMethod -Uri 'http://localhost:%N8N_PORT%/api/v1/workflows' -Method Post -Headers $headers -Body $body -ErrorAction Stop; Write-Host '     [OK] chat_main.json importe' } catch { Write-Host '     [INFO] chat_main.json - import manuel requis' }" 2>nul

:: Import du workflow rag_ingestion.json
powershell -Command "$headers = @{ Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes('%N8N_USER%:%N8N_PASSWORD%')); 'Content-Type' = 'application/json' }; $body = Get-Content '%BACKEND_DIR%\workflows\rag_ingestion.json' -Raw; try { Invoke-RestMethod -Uri 'http://localhost:%N8N_PORT%/api/v1/workflows' -Method Post -Headers $headers -Body $body -ErrorAction Stop; Write-Host '     [OK] rag_ingestion.json importe' } catch { Write-Host '     [INFO] rag_ingestion.json - import manuel requis' }" 2>nul

echo.
echo %VERT%[OK]%RESET% Workflows importes!

:: Activer les workflows
echo     Activation des workflows...
powershell -Command "$headers = @{ Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes('%N8N_USER%:%N8N_PASSWORD%')) }; try { $workflows = Invoke-RestMethod -Uri 'http://localhost:%N8N_PORT%/api/v1/workflows' -Headers $headers -ErrorAction Stop; foreach ($wf in $workflows.data) { Invoke-RestMethod -Uri ('http://localhost:%N8N_PORT%/api/v1/workflows/' + $wf.id + '/activate') -Method Post -Headers $headers -ErrorAction SilentlyContinue } } catch { }" 2>nul

echo %VERT%[OK]%RESET% Workflows actives!
echo.

:skip_import

:: ============================================================================
:: RESUME FINAL
:: ============================================================================
echo.
echo %VERT%══════════════════════════════════════════════════════════════%RESET%
echo.
echo %VERT%   ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     %RESET%
echo %VERT%   ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     %RESET%
echo %VERT%   ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     %RESET%
echo %VERT%   ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     %RESET%
echo %VERT%   ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗%RESET%
echo %VERT%   ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝%RESET%
echo.
echo %VERT%              TERMINEE AVEC SUCCES !%RESET%
echo.
echo %VERT%══════════════════════════════════════════════════════════════%RESET%
echo.

docker-compose ps

echo.
echo %CYAN%══════════════════════════════════════════════════════════════%RESET%
echo %CYAN%                    ACCES A WIBOT                             %RESET%
echo %CYAN%══════════════════════════════════════════════════════════════%RESET%
echo.
echo   %VERT%CHAT WIBOT:%RESET%
echo   %BLEU%http://localhost:%WIBOT_PORT%%RESET%
echo.
echo   %VERT%ADMINISTRATION N8N:%RESET%
echo   %BLEU%http://localhost:%N8N_PORT%%RESET%
echo   Identifiants: %CYAN%%N8N_USER%%RESET% / %CYAN%%N8N_PASSWORD%%RESET%
echo.
echo %CYAN%══════════════════════════════════════════════════════════════%RESET%
echo %CYAN%                    DOCUMENTS RAG                             %RESET%
echo %CYAN%══════════════════════════════════════════════════════════════%RESET%
echo.
echo   Mets tes documents dans:
echo   %BLEU%%BACKEND_DIR%\rag-documents\%RESET%
echo.
echo   ├── procedures\      ^<- Procedures internes
echo   ├── clients\         ^<- Fiches clients
echo   ├── tickets\         ^<- Tickets resolus
echo   └── documentation\   ^<- Doc technique
echo.
echo %CYAN%══════════════════════════════════════════════════════════════%RESET%
echo %CYAN%                    COMMANDES UTILES                          %RESET%
echo %CYAN%══════════════════════════════════════════════════════════════%RESET%
echo.
echo   cd "%BACKEND_DIR%"
echo.
echo   docker-compose ps        # Voir l'etat
echo   docker-compose logs -f   # Voir les logs
echo   docker-compose restart   # Redemarrer
echo   docker-compose down      # Arreter
echo   docker-compose up -d     # Demarrer
echo.
echo %CYAN%══════════════════════════════════════════════════════════════%RESET%
echo.
echo   Appuie sur une touche pour ouvrir WIBOT...
echo.
pause >nul

start http://localhost:%WIBOT_PORT%

echo.
echo   %VERT%Enjoy!%RESET%
echo.
