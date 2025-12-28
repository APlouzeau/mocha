-- Schéma PostgreSQL pour Mocha
-- Supprimer les anciennes tables si elles existent
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS articles CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS roles CASCADE;

-- Table des rôles utilisateurs
CREATE TABLE roles (
   id SERIAL PRIMARY KEY,
   role VARCHAR(50) NOT NULL UNIQUE
);


-- Table des utilisateurs
CREATE TABLE users (
   id SERIAL PRIMARY KEY,
   nick_name VARCHAR(50) NOT NULL UNIQUE,
   email VARCHAR(255) NOT NULL UNIQUE,
   password_hash CHAR(60) NOT NULL,
   role_id INTEGER NOT NULL DEFAULT 1,
   created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
   FOREIGN KEY(role_id) REFERENCES roles(id)
);

-- Table des articles
CREATE TABLE articles (
   id SERIAL PRIMARY KEY,
   title VARCHAR(100) NOT NULL,
   content TEXT NOT NULL,
   user_id INTEGER NOT NULL,
   created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
   FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des commentaires
CREATE TABLE comments (
   id SERIAL PRIMARY KEY,
   comment TEXT NOT NULL,
   article_id INTEGER NOT NULL,
   user_id INTEGER NOT NULL,
   created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
   FOREIGN KEY(article_id) REFERENCES articles(id) ON DELETE CASCADE,
   FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insertion des rôles par défaut
INSERT INTO roles (role) VALUES 
   ('user'),
   ('moderator'),
   ('admin');

-- Index pour améliorer les performances
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_articles_user_id ON articles(user_id);
CREATE INDEX idx_comments_article_id ON comments(article_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
