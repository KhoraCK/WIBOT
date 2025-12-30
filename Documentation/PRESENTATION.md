# WIBOT - Fiche de Presentation

## Identite du Projet

| Element | Valeur |
|---------|--------|
| **Nom** | WIBOT |
| **Type** | Chatbot IA interne |
| **Entreprise** | WIDIP (Services informatiques, France) |
| **Version** | 1.0 |
| **Date de creation** | Decembre 2025 |
| **Statut** | MVP fonctionnel |

---

## Description

WIBOT est un assistant conversationnel intelligent developpe pour les employes de WIDIP. Il offre une interface de chat moderne similaire a Claude.ai, permettant d'interagir avec une IA (Mistral) pour obtenir de l'aide sur des questions techniques, des processus internes ou des taches quotidiennes.

L'application est entierement auto-hebergee, garantissant la confidentialite des echanges au sein de l'entreprise.

---

## Objectifs

1. **Productivite** : Fournir une assistance IA instantanee aux employes
2. **Centralisation** : Un point d'acces unique pour les questions techniques
3. **Confidentialite** : Donnees hebergees en interne (pas de cloud tiers pour le stockage)
4. **Evolutivite** : Architecture modulaire permettant d'ajouter des fonctionnalites

---

## Fonctionnalites Actuelles (v1.0)

### Chat Intelligent
- Conversation en langage naturel avec Mistral AI
- Memoire de conversation (l'IA se souvient du contexte)
- Reponses en francais par defaut
- Support du Markdown (listes, tableaux, liens)
- Blocs de code avec coloration syntaxique
- Bouton copier le code

### Gestion des Conversations
- Creation de nouvelles conversations
- Historique des conversations dans la sidebar
- Persistance des messages en base de donnees
- Reprise de conversation avec contexte preserve

### Authentification
- Systeme de login securise (JWT)
- Gestion des utilisateurs (admin/user)
- Session persistante (24h)
- Deconnexion

### Interface Utilisateur
- Design sombre moderne (dark mode)
- Interface responsive
- Indicateur de chargement ("WIBOT reflechit...")
- Compteur de tokens avec jauge visuelle

### Upload de Fichiers (prepare)
- Interface drag & drop implementee
- Formats supportes : PDF, TXT, MD, CSV, JSON
- Limite : 10 Mo par fichier
- *Note : Le traitement backend n'est pas encore connecte*

---

## Fonctionnalites Futures (Roadmap)

### Court terme
- [ ] Traitement des fichiers uploades (analyse par l'IA)
- [ ] Recherche dans l'historique des conversations
- [ ] Export des conversations (PDF, Markdown)
- [ ] Themes clair/sombre

### Moyen terme
- [ ] Base de connaissances WIDIP (RAG)
- [ ] Integration documentation interne
- [ ] Agents specialises (code review, debug, etc.)
- [ ] Notifications et alertes

### Long terme
- [ ] Multi-utilisateurs simultanes
- [ ] Statistiques d'utilisation
- [ ] Fine-tuning sur donnees WIDIP
- [ ] Integration outils internes (tickets, projets)

---

## Architecture Technique

```
┌─────────────────────────────────────────────────────────────┐
│                        WIBOT                                 │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐   │
│  │   Frontend  │     │   Backend   │     │  Database   │   │
│  │   (React)   │────▶│   (n8n)     │────▶│ (PostgreSQL)│   │
│  └─────────────┘     └──────┬──────┘     └─────────────┘   │
│                             │                               │
│                             ▼                               │
│                      ┌─────────────┐                       │
│                      │ Mistral AI  │                       │
│                      │  (Cloud)    │                       │
│                      └─────────────┘                       │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│  Nginx (Reverse Proxy) - Port 8080                          │
└─────────────────────────────────────────────────────────────┘
```

### Stack Technique

| Couche | Technologies |
|--------|--------------|
| **Frontend** | React 19, TypeScript, Vite, Tailwind CSS, Zustand |
| **Backend** | n8n (workflows), Node.js |
| **Database** | PostgreSQL 14 |
| **IA** | Mistral AI (mistral-small-latest) |
| **Infrastructure** | Docker, Docker Compose, Nginx |

---

## Points d'Entree API

| Endpoint | Methode | Description |
|----------|---------|-------------|
| `/webhook/auth/login` | POST | Authentification utilisateur |
| `/webhook/wibot/chat` | POST | Envoyer un message au chatbot |
| `/webhook/wibot/conversations` | GET | Lister les conversations |
| `/webhook/wibot/conversations` | POST | Creer une conversation |
| `/webhook/wibot/conversations/:id/messages` | GET | Messages d'une conversation |

---

## Configuration IA

### Modele
- **Provider** : Mistral AI
- **Modele** : `mistral-small-latest`
- **Temperature** : 0.7
- **Max tokens** : 2048

### System Prompt
```
Tu es WIBOT, l'assistant IA interne de WIDIP, une entreprise francaise
de services informatiques.

Ton role:
- Aider les employes WIDIP avec leurs questions techniques
- Fournir des reponses claires et professionnelles
- Utiliser le francais par defaut
- Etre concis mais complet

Style:
- Utilise le markdown pour formater tes reponses
- Mets le code dans des blocs avec le langage specifie
- Sois amical mais professionnel
```

### Memoire
- **Type** : Postgres Chat Memory (n8n native)
- **Contexte** : 10 derniers messages
- **Persistance** : Table `n8n_chat_histories`

---

## Structure du Projet

```
WIBOT/
├── Documentation/           # Documentation technique
│   ├── FRONTEND.md
│   ├── BACKEND.md
│   ├── INSTALLATION.md
│   └── PRESENTATION.md     # Ce fichier
│
├── wibot-frontend/         # Application React
│   ├── src/
│   │   ├── components/     # Composants UI
│   │   ├── hooks/          # Custom hooks
│   │   ├── pages/          # Pages (Login, Chat)
│   │   ├── services/       # API client
│   │   ├── store/          # State management
│   │   └── types/          # Types TypeScript
│   ├── package.json
│   └── vite.config.ts
│
└── wibot-backend/          # Infrastructure Docker
    ├── docker-compose.yml  # Orchestration
    ├── nginx.conf          # Configuration proxy
    ├── init.sql            # Schema base de donnees
    ├── workflows/          # Workflows n8n (JSON)
    │   ├── auth_login.json
    │   ├── chat_main.json
    │   ├── get_conversations.json
    │   ├── get_messages.json
    │   └── create_conversation.json
    └── frontend/           # Build React (prod)
```

---

## Donnees et Securite

### Donnees stockees
- Utilisateurs (credentials)
- Historique des conversations
- Messages (user + assistant)
- Compteur de tokens

### Securite implementee
- Authentification JWT (24h)
- Mots de passe (a migrer vers bcrypt en prod)
- Rate limiting Nginx
- Headers securite HTTP
- Pas de donnees sensibles dans les logs

### Points d'attention pour la production
- [ ] Migrer vers bcrypt pour les mots de passe
- [ ] Ajouter HTTPS (certificat SSL)
- [ ] Configurer un vrai secret JWT
- [ ] Mettre en place des backups automatiques
- [ ] Monitorer les ressources Docker

---

## Utilisation avec Claude Code

### Contexte pour l'evolution

Ce projet peut etre modifie et ameliore avec Claude Code. Voici les informations cles :

**Pour modifier le Frontend :**
```
Dossier : wibot-frontend/
Stack : React 19 + TypeScript + Vite + Tailwind CSS
State : Zustand (stores dans src/store/)
Routing : React Router v7
API : Axios (src/services/api.ts)
```

**Pour modifier le Backend :**
```
Dossier : wibot-backend/
Workflows : Fichiers JSON dans workflows/
Base : PostgreSQL (schema dans init.sql)
IA : Nodes n8n Mistral + Postgres Chat Memory
```

**Commandes utiles :**
```bash
# Frontend
cd wibot-frontend && npm run dev

# Backend
cd wibot-backend && docker-compose up -d

# Logs
docker-compose logs -f n8n

# Base de donnees
docker exec wibot-postgres psql -U widip -d wibot
```

### Exemples de demandes d'evolution

1. **Ajouter une fonctionnalite UI :**
   > "Ajoute un bouton pour supprimer une conversation dans la sidebar"

2. **Modifier le comportement IA :**
   > "Modifie le system prompt dans chat_main.json pour que WIBOT reponde aussi en anglais si la question est en anglais"

3. **Ajouter un endpoint :**
   > "Cree un nouveau workflow n8n pour supprimer une conversation"

4. **Ameliorer le design :**
   > "Change la couleur accent de bleu (#5B9EFF) vers vert WIDIP (#00B894)"

5. **Ajouter une integration :**
   > "Ajoute un workflow n8n qui envoie un email de resume quotidien des conversations"

---

## Contacts et Ressources

### Documentation externe
- [n8n Documentation](https://docs.n8n.io/)
- [Mistral AI API](https://docs.mistral.ai/)
- [React Documentation](https://react.dev/)
- [Tailwind CSS](https://tailwindcss.com/docs)

### Fichiers de configuration cles
| Fichier | Role |
|---------|------|
| `docker-compose.yml` | Ports, volumes, variables d'env |
| `nginx.conf` | Routes, CORS, rate limiting |
| `init.sql` | Schema BDD, utilisateurs test |
| `tailwind.config.js` | Couleurs, espacements |
| `.env` | Credentials (ne pas commiter) |

---

## Changelog

### v1.0 (Decembre 2025)
- Interface chat complete
- Authentification JWT
- Integration Mistral AI
- Memoire de conversation PostgreSQL
- Infrastructure Docker
- Documentation complete

---

*Document genere le 26 Decembre 2025*
*Projet WIBOT - WIDIP*
