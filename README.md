sudo apt update
sudo -u postgres psql
git clone https://github.com/ton/repo.git

# Mocha

Application mobile Flutter avec backend Dart et base PostgreSQL.

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

### Ubuntu/Debian

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### Windows/Mac

Télécharge depuis [postgresql.org/download](https://www.postgresql.org/download/)

### Créer la base Mocha

```sql
sudo -u postgres psql
CREATE DATABASE mocha;
CREATE USER mocha_user WITH PASSWORD 'mocha_pass';
GRANT ALL PRIVILEGES ON DATABASE mocha TO mocha_user;
\q
```

## 📦 Installation du projet

1. **Cloner le repo**

```bash
git clone https://github.com/ton/repo.git
cd mocha
```

2. **Copier le fichier .env**

```bash
cp .env.example .env
```

Le fichier `.env.example` se trouve à la racine du projet.

3. **Éditer `.env`** (adapter si besoin) :

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mocha
DB_USER=mocha_user
DB_PASSWORD=mocha_pass
BACKEND_PORT=8080
FRONTEND_PORT=3000
```

4. **Installer les dépendances**

-   **Backend Dart** :

```bash
cd backend/
dart pub get
```

-   **Frontend Flutter** (à la racine du projet) :

```bash
flutter pub get
```

## 🗃️ Initialiser la base de données

**Important** : Utilise le schéma SQL fourni !

Le fichier du schéma est `backend/database_schema.sql`.

```bash
cd backend/
psql -h localhost -U mocha_user -d mocha < database_schema.sql
```

## ▶️ Lancement

### 1. Démarrer PostgreSQL

```bash
sudo systemctl start postgresql # Ubuntu
```

### 2. Lancer le backend Dart (terminal 1)

```bash
dart run bin/server.dart
```

### 3. Lancer le frontend Flutter (terminal 2)

```bash
flutter run
```

**Sélectionne** un émulateur Android/iOS ou Chrome

## 📱 Prévisualisation

-   **App mobile** : Émulateur Android/iOS ou appareil physique
-   **Web preview** : `flutter run -d chrome`
-   **API Backend** : `http://localhost:8080`
