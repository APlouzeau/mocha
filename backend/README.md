# 🍫 Mocha Backend - API REST

Backend de l'application Mocha Forum, développé en Dart avec PostgreSQL.

## 📋 Table des matières

-   [Prérequis](#prérequis)
-   [Installation](#installation)
-   [Configuration](#configuration)
-   [Lancement du serveur](#lancement-du-serveur)
-   [Routes disponibles](#routes-disponibles)
-   [Pattern pour créer une nouvelle route](#pattern-pour-créer-une-nouvelle-route)
-   [Structure du projet](#structure-du-projet)

---

## 🔧 Prérequis

-   **Dart SDK** >= 3.10.0 (installé avec Flutter)
-   **PostgreSQL** >= 14
-   **Linux/WSL** (ou adapter les commandes pour macOS/Windows)

---

## 📦 Installation

### 1. Installer PostgreSQL

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib -y
sudo systemctl start postgresql
```

### 2. Créer la base de données

```bash
# Créer la base de données
sudo -u postgres psql -c "CREATE DATABASE mocha_db;"

# Créer l'utilisateur
sudo -u postgres psql -c "CREATE USER mocha_user WITH PASSWORD 'mocha_password_dev';"

# Donner les permissions
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE mocha_db TO mocha_user;"
sudo -u postgres psql -d mocha_db -c "GRANT ALL ON SCHEMA public TO mocha_user;"
sudo -u postgres psql -d mocha_db -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO mocha_user;"
sudo -u postgres psql -d mocha_db -c "GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO mocha_user;"
sudo -u postgres psql -d mocha_db -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO mocha_user;"
sudo -u postgres psql -d mocha_db -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO mocha_user;"
```

### 3. Créer les tables

```bash
sudo -u postgres psql -d mocha_db -f database_schema.sql
```

### 4. Installer les dépendances Dart

```bash
cd backend
dart pub get
```

---

## ⚙️ Configuration

Le fichier `.env` contient toutes les variables d'environnement :

```env
# Configuration PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mocha_db
DB_USER=mocha_user
DB_PASSWORD=mocha_password_dev

# Configuration JWT
JWT_SECRET=chaud_cacao_cho_cho_cho_chocolat

# Port du serveur
PORT=8080
```

⚠️ **Ne JAMAIS commit le fichier `.env` sur Git !**

---

## 🚀 Lancement du serveur

```bash
cd backend
dart run bin/server.dart
```

Tu devrais voir :

```
✅ Connexion à PostgreSQL établie !
✅ Base de données connectée
🚀 Serveur Mocha Backend lancé !
📡 Écoute sur: http://0.0.0.0:8080
```

---

## 🛣️ Routes disponibles

### **Authentification**

#### POST `/auth/register` - Inscription

**Requête :**

```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "alex",
    "email": "alex@test.com",
    "password": "secret123"
  }'
```

**Réponse :**

```json
{
    "message": "User registered successfully",
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
        "id": 1,
        "username": "alex",
        "email": "alex@test.com",
        "createdAt": "2025-12-27T14:25:35.837830Z"
    }
}
```

#### POST `/auth/login` - Connexion

**Requête :**

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alex@test.com",
    "password": "secret123"
  }'
```

**Réponse :**

```json
{
    "message": "Login successful",
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
        "id": 1,
        "username": "alex",
        "email": "alex@test.com"
    }
}
```

---

## 🏗️ Pattern pour créer une nouvelle route

### Exemple : Créer un post

Voici le pattern complet pour créer une route qui enregistre en BDD.

#### 1️⃣ **Créer le modèle** (`lib/models/post.dart`)

```dart
class Post {
  final int? id;
  final String title;
  final String content;
  final int userId;
  final int topicId;
  final DateTime? createdAt;

  Post({
    this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.topicId,
    this.createdAt,
  });

  // Convertir une ligne de BDD en objet Post
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      userId: map['user_id'] as int,
      topicId: map['topic_id'] as int,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : null,
    );
  }

  // Convertir un objet Post en JSON (pour renvoyer au frontend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'userId': userId,
      'topicId': topicId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
```

#### 2️⃣ **Créer le fichier de routes** (`lib/routes/posts_routes.dart`)

```dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database/db.dart';
import '../models/post.dart';

Router postsRoutes(Database db) {
  final router = Router();

  // POST /posts - Créer un nouveau post
  router.post('/', (Request request) async {
    try {
      // 1. Lire le body JSON
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      // 2. Extraire les données
      final title = data['title'] as String?;
      final content = data['content'] as String?;
      final userId = data['userId'] as int?;
      final topicId = data['topicId'] as int?;

      // 3. Valider les données
      if (title == null || title.isEmpty ||
          content == null || content.isEmpty ||
          userId == null || topicId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'All fields are required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // 4. Insérer en base de données
      final conn = db.connection;
      final result = await conn.execute(
        '''INSERT INTO posts (title, content, user_id, topic_id)
           VALUES (\$1, \$2, \$3, \$4)
           RETURNING id, title, content, user_id, topic_id, created_at''',
        parameters: [title, content, userId, topicId],
      );

      // 5. Créer l'objet Post depuis le résultat
      final postRow = result.first;
      final post = Post(
        id: postRow[0] as int,
        title: postRow[1] as String,
        content: postRow[2] as String,
        userId: postRow[3] as int,
        topicId: postRow[4] as int,
        createdAt: postRow[5] as DateTime,
      );

      // 6. Retourner la réponse
      return Response.ok(
        jsonEncode({
          'message': 'Post created successfully',
          'post': post.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in POST /posts: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create post: ${e.toString()}'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // GET /posts - Récupérer tous les posts
  router.get('/', (Request request) async {
    try {
      final conn = db.connection;
      final results = await conn.execute('SELECT * FROM posts ORDER BY created_at DESC');

      final posts = results.map((row) {
        return Post(
          id: row[0] as int,
          title: row[1] as String,
          content: row[2] as String,
          userId: row[3] as int,
          topicId: row[4] as int,
          createdAt: row[5] as DateTime,
        );
      }).toList();

      return Response.ok(
        jsonEncode({
          'posts': posts.map((p) => p.toJson()).toList(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch posts'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  return router;
}
```

#### 3️⃣ **Ajouter la route dans le serveur** (`bin/server.dart`)

```dart
import '../lib/routes/posts_routes.dart'; // Ajouter cet import

// Dans la fonction main(), après les routes auth :
router.mount('/posts', postsRoutes(db).call);
```

#### 4️⃣ **Tester la route**

```bash
# Créer un post
curl -X POST http://localhost:8080/posts \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Mon premier post",
    "content": "Contenu du post",
    "userId": 1,
    "topicId": 1
  }'

# Récupérer tous les posts
curl http://localhost:8080/posts
```

---

## 📁 Structure du projet

```
backend/
├── bin/
│   └── server.dart          # Point d'entrée du serveur
├── lib/
│   ├── database/
│   │   └── db.dart          # Connexion PostgreSQL
│   ├── models/
│   │   ├── user.dart        # Modèle User
│   │   └── post.dart        # Modèle Post
│   ├── routes/
│   │   ├── auth_routes.dart # Routes d'authentification
│   │   └── posts_routes.dart # Routes des posts
│   └── utils/
│       ├── password.dart    # Hash/vérification mots de passe
│       ├── jwt.dart         # Génération/vérification tokens
│       └── check_data.dart  # Validation des données
├── .env                     # Variables d'environnement (NE PAS COMMIT)
├── database_schema.sql      # Schéma de la base de données
├── pubspec.yaml             # Dépendances Dart
└── README.md                # Ce fichier
```

---

## 🔑 Checklist pour créer une nouvelle route

-   [ ] Créer le modèle dans `lib/models/`
-   [ ] Créer le fichier de routes dans `lib/routes/`
-   [ ] Implémenter les routes (GET, POST, PUT, DELETE)
-   [ ] Ajouter la route dans `bin/server.dart` avec `router.mount()`
-   [ ] Tester avec `curl` ou Postman

---

## 🐛 Debugging

### Voir les logs du serveur

Les logs s'affichent dans le terminal où tu as lancé `dart run bin/server.dart`.

### Vérifier la base de données

```bash
PGPASSWORD='mocha_password_dev' psql -h localhost -U mocha_user -d mocha_db
```

Puis :

```sql
\dt                    -- Lister les tables
SELECT * FROM users;   -- Voir tous les users
SELECT * FROM posts;   -- Voir tous les posts
```

---

## 👥 Auteurs

-   **Alex** - Authentification
-   **[Nom du camarade]** - Gestion des posts

---

## 📝 License

Projet d'école - Tous droits réservés
