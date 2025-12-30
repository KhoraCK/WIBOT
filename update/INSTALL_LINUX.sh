#!/bin/bash
#===============================================================================
#
#   ██╗    ██╗██╗██████╗  ██████╗ ████████╗
#   ██║    ██║██║██╔══██╗██╔═══██╗╚══██╔══╝
#   ██║ █╗ ██║██║██████╔╝██║   ██║   ██║
#   ██║███╗██║██║██╔══██╗██║   ██║   ██║
#   ╚███╔███╔╝██║██████╔╝╚██████╔╝   ██║
#    ╚══╝╚══╝ ╚═╝╚═════╝  ╚═════╝    ╚═╝
#
#   INSTALLATION AUTOMATIQUE LINUX
#   Version: 2.0 - Full Auto
#
#===============================================================================

set -e

#-------------------------------------------------------------------------------
# COULEURS
#-------------------------------------------------------------------------------
ROUGE='\033[0;31m'
VERT='\033[0;32m'
JAUNE='\033[1;33m'
BLEU='\033[0;34m'
CYAN='\033[0;36m'
NORMAL='\033[0m'

#-------------------------------------------------------------------------------
# FONCTIONS UTILITAIRES
#-------------------------------------------------------------------------------
titre() {
    echo ""
    echo -e "${BLEU}╔══════════════════════════════════════════════════════════════╗${NORMAL}"
    echo -e "${BLEU}║${NORMAL} $1"
    echo -e "${BLEU}╚══════════════════════════════════════════════════════════════╝${NORMAL}"
}

info() {
    echo -e "${CYAN}[INFO]${NORMAL} $1"
}

succes() {
    echo -e "${VERT}[OK]${NORMAL} $1"
}

erreur() {
    echo -e "${ROUGE}[ERREUR]${NORMAL} $1"
}

attention() {
    echo -e "${JAUNE}[ATTENTION]${NORMAL} $1"
}

#-------------------------------------------------------------------------------
# DETECTION DES CHEMINS
#-------------------------------------------------------------------------------
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WIBOT_DIR="$SCRIPT_DIR"
BACKEND_DIR="$WIBOT_DIR/wibot-backend"
FRONTEND_DIR="$WIBOT_DIR/wibot-frontend"
CONFIG_FILE="$WIBOT_DIR/config.txt"

#-------------------------------------------------------------------------------
# AFFICHAGE HEADER
#-------------------------------------------------------------------------------
clear
echo -e "${CYAN}"
cat << "EOF"

   ██╗    ██╗██╗██████╗  ██████╗ ████████╗
   ██║    ██║██║██╔══██╗██╔═══██╗╚══██╔══╝
   ██║ █╗ ██║██║██████╔╝██║   ██║   ██║
   ██║███╗██║██║██╔══██╗██║   ██║   ██║
   ╚███╔███╔╝██║██████╔╝╚██████╔╝   ██║
    ╚══╝╚══╝ ╚═╝╚═════╝  ╚═════╝    ╚═╝

   Assistant IA interne WIDIP
   Installation Automatique Linux v2.0

EOF
echo -e "${NORMAL}"

#===============================================================================
# ETAPE 0: VERIFICATION ROOT
#===============================================================================
titre "ETAPE 0/9: Verification des permissions"

if [ "$EUID" -ne 0 ]; then
    erreur "Ce script doit etre lance en ROOT (administrateur)"
    echo ""
    echo "   Comment faire ?"
    echo "   ---------------"
    echo "   Tape cette commande:"
    echo -e "   ${VERT}sudo ./INSTALL_LINUX.sh${NORMAL}"
    echo ""
    exit 1
fi

succes "Tu es bien en mode root"

#===============================================================================
# ETAPE 1: LECTURE DE LA CONFIGURATION
#===============================================================================
titre "ETAPE 1/9: Lecture de la configuration"

if [ ! -f "$CONFIG_FILE" ]; then
    erreur "Le fichier config.txt n'existe pas!"
    echo ""
    echo -e "   ${JAUNE}Que faire ?${NORMAL}"
    echo "   1. Ouvre le fichier config.txt dans le dossier WIBOT"
    echo "   2. Remplis ta cle API Mistral et les autres infos"
    echo "   3. Relance ce script"
    echo ""
    exit 1
fi

# Lire les valeurs du fichier config.txt
while IFS='=' read -r key value; do
    # Ignorer les commentaires et lignes vides
    [[ "$key" =~ ^#.*$ ]] && continue
    [[ -z "$key" ]] && continue

    # Nettoyer les espaces
    key=$(echo "$key" | tr -d ' ')
    value=$(echo "$value" | tr -d ' ')

    # Exporter la variable
    export "$key=$value"
done < "$CONFIG_FILE"

# Valeurs par defaut
WIBOT_PORT=${WIBOT_PORT:-8080}
N8N_PORT=${N8N_PORT:-5679}
POSTGRES_PORT=${POSTGRES_PORT:-5433}
JWT_SECRET=${JWT_SECRET:-wibot_jwt_secret_key_minimum_32_chars_2024}
N8N_USER=${N8N_USER:-admin}
N8N_PASSWORD=${N8N_PASSWORD:-wibot_admin_2024}
POSTGRES_USER=${POSTGRES_USER:-widip}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-widip_secure_password_2024}
POSTGRES_DB=${POSTGRES_DB:-wibot}

# Verifier que la cle Mistral est renseignee
if [[ "$MISTRAL_API_KEY" == *"<"* ]] || [[ -z "$MISTRAL_API_KEY" ]]; then
    erreur "La cle API Mistral n'est pas configuree!"
    echo ""
    echo -e "   ${JAUNE}Que faire ?${NORMAL}"
    echo "   1. Ouvre le fichier config.txt"
    echo "   2. Remplace <TA_CLE_MISTRAL_ICI> par ta vraie cle API"
    echo "   3. Relance ce script"
    echo ""
    echo -e "   ${JAUNE}Ou obtenir une cle ?${NORMAL}"
    echo "   https://console.mistral.ai/api-keys"
    echo ""
    exit 1
fi

succes "Configuration chargee"
echo "    - Mistral API: ${MISTRAL_API_KEY:0:8}..."
echo "    - n8n User: $N8N_USER"
echo "    - PostgreSQL: $POSTGRES_USER@$POSTGRES_DB"
echo "    - Ports: WIBOT=$WIBOT_PORT, n8n=$N8N_PORT, PG=$POSTGRES_PORT"

#===============================================================================
# ETAPE 2: VERIFICATION DES DOSSIERS
#===============================================================================
titre "ETAPE 2/9: Verification des dossiers"

if [ ! -d "$BACKEND_DIR" ]; then
    erreur "Le dossier wibot-backend n'existe pas!"
    exit 1
fi

if [ ! -d "$FRONTEND_DIR" ]; then
    erreur "Le dossier wibot-frontend n'existe pas!"
    exit 1
fi

if [ ! -f "$BACKEND_DIR/docker-compose.yml" ]; then
    erreur "Le fichier docker-compose.yml n'existe pas dans wibot-backend!"
    exit 1
fi

succes "Tous les dossiers sont presents"

#===============================================================================
# ETAPE 3: INSTALLATION DE DOCKER
#===============================================================================
titre "ETAPE 3/9: Verification de Docker"

if command -v docker &> /dev/null; then
    succes "Docker est deja installe: $(docker --version)"
else
    attention "Docker n'est pas installe. Installation en cours..."
    echo ""
    info "Telechargement et installation de Docker..."
    curl -fsSL https://get.docker.com | sh
    succes "Docker installe!"
fi

# Demarrer Docker
info "Demarrage du service Docker..."
systemctl start docker 2>/dev/null || true
systemctl enable docker 2>/dev/null || true

# Verifier que Docker fonctionne
if docker info &> /dev/null; then
    succes "Docker fonctionne correctement"
else
    erreur "Docker ne fonctionne pas!"
    echo "   Essaie de redemarrer ton PC et relance ce script"
    exit 1
fi

#===============================================================================
# ETAPE 4: INSTALLATION DE DOCKER COMPOSE
#===============================================================================
titre "ETAPE 4/9: Verification de Docker Compose"

if command -v docker-compose &> /dev/null; then
    succes "Docker Compose est deja installe: $(docker-compose --version)"
elif docker compose version &> /dev/null; then
    succes "Docker Compose (plugin) est disponible"
    # Creer un alias
    alias docker-compose="docker compose"
else
    attention "Docker Compose n'est pas installe. Installation..."

    if command -v apt-get &> /dev/null; then
        apt-get update -y && apt-get install -y docker-compose-plugin
    elif command -v dnf &> /dev/null; then
        dnf install -y docker-compose-plugin
    elif command -v yum &> /dev/null; then
        yum install -y docker-compose-plugin
    elif command -v pacman &> /dev/null; then
        pacman -Sy --noconfirm docker-compose
    else
        erreur "Impossible d'installer docker-compose automatiquement"
        exit 1
    fi

    succes "Docker Compose installe!"
fi

#===============================================================================
# ETAPE 5: INSTALLATION DE NODE.JS
#===============================================================================
titre "ETAPE 5/9: Verification de Node.js"

if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    succes "Node.js est deja installe: $NODE_VERSION"
else
    attention "Node.js n'est pas installe. Installation de Node.js 20 LTS..."

    if command -v apt-get &> /dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt-get install -y nodejs
    elif command -v dnf &> /dev/null; then
        dnf install -y nodejs
    elif command -v pacman &> /dev/null; then
        pacman -Sy --noconfirm nodejs npm
    else
        erreur "Impossible d'installer Node.js automatiquement"
        exit 1
    fi

    succes "Node.js installe: $(node --version)"
fi

#===============================================================================
# ETAPE 6: CREATION DU FICHIER .env
#===============================================================================
titre "ETAPE 6/9: Configuration de l'environnement"

cat > "$BACKEND_DIR/.env" << EOF
# ===========================================
# WIBOT Backend - Variables d'environnement
# ===========================================
# Genere automatiquement par INSTALL_LINUX.sh

# ===========================================
# PostgreSQL
# ===========================================
POSTGRES_DB=$POSTGRES_DB
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD

# ===========================================
# n8n Configuration
# ===========================================
N8N_HOST=localhost
N8N_PROTOCOL=http
WEBHOOK_URL=http://localhost:$N8N_PORT

# n8n Admin credentials
N8N_USER=$N8N_USER
N8N_PASSWORD=$N8N_PASSWORD

# ===========================================
# JWT Secret
# ===========================================
JWT_SECRET=$JWT_SECRET

# ===========================================
# Mistral API
# ===========================================
MISTRAL_API_KEY=$MISTRAL_API_KEY
EOF

succes "Fichier .env cree"

#===============================================================================
# ETAPE 7: COMPILATION DU FRONTEND
#===============================================================================
titre "ETAPE 7/9: Compilation du frontend React"

cd "$FRONTEND_DIR"

# Supprimer node_modules Windows (incompatible avec Linux)
if [ -d "node_modules" ]; then
    attention "Suppression des node_modules (reinstallation propre)..."
    rm -rf node_modules
fi

info "Installation des dependances npm (ca peut prendre 1-2 minutes)..."
npm install --silent

info "Compilation du frontend..."
npm run build

# Copier le build vers le backend
info "Copie du frontend compile vers le backend..."
rm -rf "$BACKEND_DIR/frontend"
cp -r dist "$BACKEND_DIR/frontend"

succes "Frontend compile et copie!"

#===============================================================================
# ETAPE 8: DEMARRAGE DES CONTAINERS
#===============================================================================
titre "ETAPE 8/9: Demarrage de WIBOT"

# Creer les dossiers RAG
mkdir -p "$BACKEND_DIR/rag-documents/procedures"
mkdir -p "$BACKEND_DIR/rag-documents/clients"
mkdir -p "$BACKEND_DIR/rag-documents/tickets"
mkdir -p "$BACKEND_DIR/rag-documents/documentation"

cd "$BACKEND_DIR"

info "Arret des anciens containers (si existants)..."
docker-compose down 2>/dev/null || docker compose down 2>/dev/null || true

info "Telechargement des images Docker (ca peut prendre quelques minutes)..."
docker-compose pull 2>/dev/null || docker compose pull

info "Demarrage des services..."
docker-compose up -d 2>/dev/null || docker compose up -d

info "Attente du demarrage (20 secondes)..."
sleep 20

succes "Services demarres!"

#===============================================================================
# ETAPE 9: IMPORT AUTOMATIQUE DES WORKFLOWS
#===============================================================================
titre "ETAPE 9/9: Import des workflows dans n8n"

# Attendre que n8n soit pret
info "Attente que n8n soit pret..."
N8N_READY=0
for i in {1..30}; do
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$N8N_PORT/healthz" 2>/dev/null | grep -q "200"; then
        N8N_READY=1
        break
    fi
    sleep 2
done

if [ $N8N_READY -eq 0 ]; then
    attention "n8n n'est pas encore pret"
    echo "    Tu devras importer les workflows manuellement"
else
    succes "n8n est pret!"
    echo ""

    # Credentials base64
    AUTH=$(echo -n "$N8N_USER:$N8N_PASSWORD" | base64)

    # Import du workflow chat_main.json
    info "Import de chat_main.json..."
    if curl -s -X POST "http://localhost:$N8N_PORT/api/v1/workflows" \
        -H "Authorization: Basic $AUTH" \
        -H "Content-Type: application/json" \
        -d @"$BACKEND_DIR/workflows/chat_main.json" > /dev/null 2>&1; then
        succes "chat_main.json importe"
    else
        attention "chat_main.json - import manuel requis"
    fi

    # Import du workflow rag_ingestion.json
    info "Import de rag_ingestion.json..."
    if curl -s -X POST "http://localhost:$N8N_PORT/api/v1/workflows" \
        -H "Authorization: Basic $AUTH" \
        -H "Content-Type: application/json" \
        -d @"$BACKEND_DIR/workflows/rag_ingestion.json" > /dev/null 2>&1; then
        succes "rag_ingestion.json importe"
    else
        attention "rag_ingestion.json - import manuel requis"
    fi

    # Activer les workflows
    info "Activation des workflows..."
    WORKFLOWS=$(curl -s "http://localhost:$N8N_PORT/api/v1/workflows" \
        -H "Authorization: Basic $AUTH" 2>/dev/null)

    echo "$WORKFLOWS" | grep -o '"id":"[^"]*"' | cut -d'"' -f4 | while read WF_ID; do
        curl -s -X POST "http://localhost:$N8N_PORT/api/v1/workflows/$WF_ID/activate" \
            -H "Authorization: Basic $AUTH" > /dev/null 2>&1
    done

    succes "Workflows actives!"
fi

#===============================================================================
# RESUME FINAL
#===============================================================================
echo ""
echo -e "${VERT}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║   ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗                      ║
║   ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║                      ║
║   ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║                      ║
║   ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║                      ║
║   ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗                 ║
║   ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝                 ║
║                                                                          ║
║                         TERMINEE AVEC SUCCES !                           ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NORMAL}"

echo ""
echo -e "${CYAN}Etat des services:${NORMAL}"
docker-compose ps 2>/dev/null || docker compose ps
echo ""

echo -e "${JAUNE}═══════════════════════════════════════════════════════════════${NORMAL}"
echo -e "${JAUNE}                    ACCES A WIBOT                              ${NORMAL}"
echo -e "${JAUNE}═══════════════════════════════════════════════════════════════${NORMAL}"
echo ""
echo -e "${VERT}CHAT WIBOT:${NORMAL}"
echo -e "   ${BLEU}http://localhost:$WIBOT_PORT${NORMAL}"
echo ""
echo -e "${VERT}ADMINISTRATION N8N:${NORMAL}"
echo -e "   ${BLEU}http://localhost:$N8N_PORT${NORMAL}"
echo "   Identifiants: $N8N_USER / $N8N_PASSWORD"
echo ""
echo -e "${JAUNE}═══════════════════════════════════════════════════════════════${NORMAL}"
echo -e "${JAUNE}                    DOCUMENTS RAG                              ${NORMAL}"
echo -e "${JAUNE}═══════════════════════════════════════════════════════════════${NORMAL}"
echo ""
echo "   Mets tes documents dans:"
echo -e "   ${BLEU}$BACKEND_DIR/rag-documents/${NORMAL}"
echo ""
echo "   ├── procedures/      <- Procedures internes"
echo "   ├── clients/         <- Fiches clients"
echo "   ├── tickets/         <- Tickets resolus"
echo "   └── documentation/   <- Doc technique"
echo ""
echo -e "${JAUNE}═══════════════════════════════════════════════════════════════${NORMAL}"
echo -e "${JAUNE}                    COMMANDES UTILES                           ${NORMAL}"
echo -e "${JAUNE}═══════════════════════════════════════════════════════════════${NORMAL}"
echo ""
echo "   cd $BACKEND_DIR"
echo ""
echo "   docker-compose ps        # Voir l'etat des services"
echo "   docker-compose logs -f   # Voir les logs en temps reel"
echo "   docker-compose restart   # Redemarrer les services"
echo "   docker-compose down      # Arreter WIBOT"
echo "   docker-compose up -d     # Demarrer WIBOT"
echo ""
echo -e "${VERT}Enjoy!${NORMAL}"
echo ""
