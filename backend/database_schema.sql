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
   ('moderateur'),
   ('admin');

INSERT INTO users (nick_name, email, password_hash, role_id, created_at)
VALUES 
(
  'admin',
  'admin@admin.fr',
  '$2a$12$fq5hDdOGjcDsOtliLZRy.e4yuh.6gd0HpchXLchVEszJXtTqYkXG2',
  3,
  '2026-01-04 12:39:47.150227'
),
(
  'barista',
  'barista@mocha.fr',
  '$2a$12$fq5hDdOGjcDsOtliLZRy.e4yuh.6gd0HpchXLchVEszJXtTqYkXG2',
  1,
  NOW()
),
(
  'coffee_lover',
  'coffee@mocha.fr',
  '$2a$12$fq5hDdOGjcDsOtliLZRy.e4yuh.6gd0HpchXLchVEszJXtTqYkXG2',
  1,
  NOW()
);


INSERT INTO articles (title, content, user_id, created_at)
VALUES (
  'Les secrets du café',
  'Du grain à la tasse, chaque étape influence le goût du café : origine, torréfaction, mouture et extraction.',
  1,
  NOW()
),(
  'Le mythe du café trop fort',
  'Un café plus sombre n est pas forcément plus fort : il contient souvent moins de caféine qu une torréfaction claire.',
  2,
  NOW()
),(
  'Pourquoi le café sent si bon ?',
  'Les arômes du café proviennent de centaines de composés libérés pendant la torréfaction, proches de ceux du chocolat.',
  1,
  NOW()
),
(
  'Expresso vs café filtre',
  'L expresso utilise une forte pression et une extraction courte. Le filtre, lui, donne une boisson plus douce et aromatique.',
  2,
  NOW()
),
(
  'Le mythe du café trop fort',
  'Un café plus sombre n est pas forcément plus fort : il contient souvent moins de caféine qu une torréfaction claire.',
  2,
  NOW()
),(
  'Comment conserver son café',
  'Le café aime l obscurité, un contenant hermétique et une température stable. Évite le frigo et le congélateur.',
  3,
  NOW()
);



INSERT INTO comments (comment, article_id, user_id, created_at)
VALUES (
  'Un beau commentaire sur le café !',
  1,
  2,
  NOW()
),(
  'Un autre beau commentaire sur le café !',
  1,
  3,
  NOW()
),(
  'Un très beau commentaire sur le café !',
  2,
  1,
  NOW()
),
(
  'Un magnifique commentaire sur le café !',
  3,
  2,
  NOW()
),
(
  'Le café est délicieux !',
  4,
  3,
  NOW()
),(
  'Rrrrr!',
  5,
  2,
  NOW()
);

-- Index pour améliorer les performances
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_articles_user_id ON articles(user_id);
CREATE INDEX idx_comments_article_id ON comments(article_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
