# Mocha ☕

Application mobile Flutter avec backend Dart et base de données PostgreSQL.

## 🚀 Prérequis

### Frontend Flutter

-   **Flutter SDK** ≥ 3.0 : [Télécharger](https://docs.flutter.dev/get-started/install)
-   **Dart SDK** (inclus avec Flutter)
-   **Android Studio** + émulateur Android **OU** Xcode (macOS) pour émulateur iOS
-   **Git** ≥ 2.x
-   **VS Code** ou **Android Studio** avec extensions Flutter/Dart

### Backend Dart

-   **Dart SDK** ≥ 3.0 (inclus avec Flutter)
-   **PostgreSQL** ≥ 15

### Vérification Flutter

```bash
flutter doctor
```

Tous les ✅ doivent être verts !

## 🗄️ Installation PostgreSQL

### Option 1 : Docker (recommandé - fonctionne sur tous les OS)

**Prérequis** : [Docker Desktop](https://www.docker.com/products/docker-desktop/) installé

```bash
# Démarrer PostgreSQL (créera automatiquement la base de données)
make db-start

# Vérifier que ça tourne
docker ps
```

C'est tout ! La base de données est créée et initialisée automatiquement avec :

-   **3 utilisateurs test** (voir section ci-dessous)
-   **6 articles** sur le café
-   **6 commentaires**

✅ Prêt à l'emploi !

### Option 2 : Installation locale

#### Ubuntu/Debian

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

#### macOS

```bash
brew install postgresql@15
brew services start postgresql@15
```

#### Windows

1. Téléchargez l'installeur depuis [postgresql.org/download/windows](https://www.postgresql.org/download/windows/)
2. Lancez l'installeur et suivez les instructions
3. Notez bien le mot de passe que vous définissez pour l'utilisateur `postgres`

### Créer la base de données Mocha (installation locale uniquement)

#### Linux/Mac

```bash
sudo -u postgres psql
```

#### Windows (PowerShell en mode Administrateur)

```powershell
psql -U postgres
```

Puis dans psql :

```sql
CREATE DATABASE mocha;
CREATE USER mocha_user WITH PASSWORD 'mocha_pass';
GRANT ALL PRIVILEGES ON DATABASE mocha TO mocha_user;
\q
```

## 📦 Installation du projet

1. **Cloner le repository**

```bash
git clone https://github.com/APlouzeau/mocha.git
cd mocha
```

2. **Créer le fichier d'environnement backend**

```bash
# Copier le fichier d'exemple
cp .env.example .env
```

3. **Générer une clé JWT secrète**

Utilisez les scripts fournis pour générer une clé JWT aléatoire et sécurisée :

**Sur Linux/macOS ou Windows (Git Bash/WSL) :**
```bash
./scripts/generate-jwt-unix.sh
```

**Sur Windows (PowerShell) :**
```powershell
.\scripts\generate-jwt-win.ps1
```

Copiez la clé générée, vous en aurez besoin pour l'étape suivante.

4. **Éditer le fichier `.env`** à la racine du projet :

```env
# Base de données
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mocha
DB_USER=mocha_user
DB_PASSWORD=mocha_pass

# JWT
JWT_SECRET=votre_secret_jwt_super_securise_ici
JWT_EXPIRATION=86400

# Backend
PORT=8080

# OpenRouter (optionnel)
OPENROUTER_API_KEY=
```

5. **Créer le fichier `.env` pour Flutter**

Créez un fichier `.env` **à la racine du projet** (même niveau que `pubspec.yaml`) :

```env
API_URL=http://localhost:8080
```

⚠️ **Important** :

-   Sur émulateur Android : utilisez `http://10.0.2.2:8080`
-   Sur appareil physique : utilisez l'IP de votre machine (ex: `http://192.168.1.10:8080`)

6. **Installer les dépendances**

**Backend Dart** :

```bash
cd backend
dart pub get
cd ..
```

**Frontend Flutter** :

```bash
flutter pub get
```

## 🗃️ Initialiser la base de données

⚠️ **Si vous utilisez Docker** : La base est déjà initialisée automatiquement, passez à la section suivante !

**Si installation locale uniquement** :

Le fichier du schéma est `backend/database_schema.sql`.

### Linux/Mac

```bash
psql -h localhost -U mocha_user -d mocha -f backend/database_schema.sql
```

### Windows (PowerShell)

```powershell
psql -h localhost -U mocha_user -d mocha -f backend/database_schema.sql
```

Mot de passe par défaut : `mocha_pass` (si vous avez suivi les instructions ci-dessus)

## 👤 Utilisateurs de test

La base de données est initialisée avec 3 utilisateurs pré-créés :

| Rôle            | Email            | Mot de passe |
| --------------- | ---------------- | ------------ |
| **Admin**       | admin@admin.fr   | password     |
| **Utilisateur** | barista@mocha.fr | password     |
| **Utilisateur** | coffee@mocha.fr  | password     |

Vous pouvez vous connecter avec n'importe lequel de ces comptes pour tester l'application.

## ▶️ Lancement de l'application

### Démarrage ultra-rapide (Docker + 1 commande)

```bash
# Lance TOUT : base de données + backend + frontend
make dev
```

Cette commande démarre automatiquement :

1. 🗄️ PostgreSQL dans Docker (port 5433)
2. 🚀 Backend Dart (port 8080) en arrière-plan
3. 📱 Application Flutter

Pour voir les logs du backend :

```bash
make back-logs
```

Pour tout arrêter :

```bash
make stop
```

### Démarrage pas à pas avec Docker

```bash
# Terminal 1 : Démarrer la base de données
make db-start

# Terminal 2 : Lancer le backend
make back

# Terminal 3 : Lancer l'application Flutter
make run
```

### Méthode manuelle (tous OS)

**1. Démarrer PostgreSQL**

```bash
# Avec Docker
make db-start

# Ou avec installation locale :
# Linux
sudo systemctl start postgresql

# Mac
brew services start postgresql@15

# Windows : PostgreSQL démarre automatiquement
```

**2. Lancer le backend** (dans un premier terminal)

```bash
dart run backend/bin/server.dart
```

Le backend démarrera sur `http://localhost:8080`

**3. Lancer Flutter** (dans un second terminal)

```bash
flutter run
```

Sélectionnez l'appareil cible :

-   `[1]` Émulateur Android
-   `[2]` Simulateur iOS (Mac uniquement)
-   `[3]` Chrome (web)
-   `[4]` Appareil physique connecté

### Lancer sur un appareil spécifique

```bash
# Lister les appareils disponibles
flutter devices

# Lancer sur un appareil spécifique
flutter run -d <device_id>
# Exemple : flutter run -d chrome
```

## 📱 Prévisualisation

-   **App mobile** : Émulateur Android/iOS ou appareil physique
-   **Web preview** : `flutter run -d chrome`
-   **API Backend** : `http://localhost:8080`

## 🛠️ Commandes utiles

### Développement

```bash
# Lancer tout (DB + Backend + Frontend)
make dev

# Arrêter tout
make stop

# Voir les logs du backend
make back-logs
```

### Base de données Docker

```bash
# Démarrer PostgreSQL
make db-start

# Arrêter PostgreSQL
make db-stop

# Voir les logs
make db-logs

# Réinitialiser complètement la base (supprime les données et recrée)
make db-clean
```

### Flutter

```bash
# Nettoyer le projet
make clean
# ou
flutter clean && flutter pub get

# Builder un APK Android
make build-apk
# ou
flutter build apk --release

# Lister les appareils
make devices
# ou
flutter devices
```

## 🐛 Résolution de problèmes

### Docker : Le container ne démarre pas

```bash
# Vérifier que Docker tourne
docker ps

# Voir les logs
make db-logs

# Redémarrer proprement
make db-stop
make db-start
```

### Docker : Pas de données de test (articles vides)

```bash
# Réinitialiser complètement la base
make db-clean

# Redémarrer tout
make dev
```

Cela supprime le volume Docker et recrée la base avec toutes les données de test.

### Erreur de connexion à la base de données

1. Vérifiez que PostgreSQL est démarré
2. Vérifiez les credentials dans `.env`
3. Testez la connexion manuellement :
    ```bash
    psql -h localhost -U mocha_user -d mocha
    ```

### Erreur "API_URL not found"

Assurez-vous que le fichier `.env` existe **à la racine du projet** avec :

```env
API_URL=http://localhost:8080
```

### Sur émulateur Android, l'app ne se connecte pas au backend

Changez dans `.env` :

```env
API_URL=http://10.0.2.2:8080
```

### Port 8080 déjà utilisé

```bash
# Linux/Mac
lsof -ti:8080 | xargs kill -9

# Windows (PowerShell en admin)
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```

### Flutter doctor affiche des erreurs

```bash
flutter doctor -v
# Suivez les instructions pour installer les composants manquants
```

## 📝 Structure du projet

```
mocha/
├── .env                    # Config backend
├── pubspec.yaml            # Dépendances Flutter
├── makefile                # Commandes automatisées
├── lib/                    # Code source Flutter
│   ├── main.dart
│   ├── pages/
│   ├── services/
│   ├── models/
│   └── helpers/
└── backend/
    ├── bin/
    │   └── server.dart     # Point d'entrée backend
    ├── lib/
    │   ├── routes/
    │   ├── models/
    │   ├── utils/
    │   └── database/
    └── database_schema.sql # Schéma de la base
```

## 👥 Fonctionnalités

-   ✅ Authentification (inscription, connexion, déconnexion)
-   ✅ Gestion de profil (modification pseudo, email, mot de passe)
-   ✅ Forum avec posts et commentaires
-   ✅ Rôles utilisateurs (utilisateur, modérateur, admin)
-   ✅ FAQ
-   ✅ Interface responsive et moderne

## 🔒 Sécurité

-   Mots de passe hashés avec bcrypt
-   Authentification JWT
-   Validation des données côté backend
-   Protection contre les injections SQL (requêtes paramétrées)
