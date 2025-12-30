#!/bin/bash

echo "========================================"
echo "   WIBOT - Demarrage"
echo "========================================"
echo

# Aller dans le repertoire du script
cd "$(dirname "$0")"

# Demarrer le backend (Docker)
echo "[1/2] Demarrage du backend Docker..."
cd wibot-backend
docker compose up -d

echo
echo "Attente du demarrage des services (15 secondes)..."
sleep 15

# Demarrer le frontend
echo
echo "[2/2] Demarrage du frontend..."
cd ../wibot-frontend
npm run dev &

echo
echo "========================================"
echo "   WIBOT demarre !"
echo "========================================"
echo
echo "Frontend : http://localhost:5173"
echo "n8n Editor : http://localhost:5679"
echo
echo "Identifiants : khora / test123"
echo
