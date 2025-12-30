# WIBOT - Quick Start

Guide rapide pour lancer WIBOT sur ta machine.

---

## 1. Lancer Docker Desktop

Ouvre **Docker Desktop** et attends qu'il affiche "Running" (icone verte).

---

## 2. Lancer le Backend

Ouvre un terminal (CMD ou PowerShell) :

```cmd
cd "C:\Users\maxim\Desktop\Projet IA\WIDIP\Widip Clé 25-12-2025\Projet WIDIP IA\Constructions\WIBOT\wibot-backend"

docker-compose up -d
```

Attendre ~30 secondes puis verifier :

```cmd
docker ps
```

Tu dois voir 3 conteneurs : `wibot-postgres`, `wibot-n8n`, `wibot-nginx`

---

## 3. Lancer le Frontend

Ouvre un **nouveau terminal** :

```cmd
cd "C:\Users\maxim\Desktop\Projet IA\WIDIP\Widip Clé 25-12-2025\Projet WIDIP IA\Constructions\WIBOT\wibot-frontend"

npm run dev
```

---

## 4. Acceder a WIBOT

| Service | URL | Login |
|---------|-----|-------|
| **WIBOT** | http://localhost:8080 | khora / test123 |
| **WIBOT (dev)** | http://localhost:5173 | khora / test123 |
| **n8n Admin** | http://localhost:5679 | admin / wibot_admin_2024 |

---

## Arreter WIBOT

### Arreter le frontend
`Ctrl + C` dans le terminal frontend

### Arreter le backend
```cmd
cd "C:\Users\maxim\Desktop\Projet IA\WIDIP\Widip Clé 25-12-2025\Projet WIDIP IA\Constructions\WIBOT\wibot-backend"

docker-compose down
```

---

## Commandes utiles

```cmd
:: Voir les logs du backend
docker-compose logs -f

:: Voir les logs n8n uniquement
docker-compose logs -f n8n

:: Redemarrer le backend
docker-compose restart

:: Status des conteneurs
docker ps
```

---

## Resume en 4 commandes

```cmd
:: Terminal 1 - Backend
cd "C:\Users\maxim\Desktop\Projet IA\WIDIP\Widip Clé 25-12-2025\Projet WIDIP IA\Constructions\WIBOT\wibot-backend"
docker-compose up -d

:: Terminal 2 - Frontend
cd "C:\Users\maxim\Desktop\Projet IA\WIDIP\Widip Clé 25-12-2025\Projet WIDIP IA\Constructions\WIBOT\wibot-frontend"
npm run dev
```

Puis ouvrir http://localhost:8080
