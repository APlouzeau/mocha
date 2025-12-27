-- 🗄️ SCHÉMA DE BASE DE DONNÉES POUR MOCHA FORUM
-- Ce fichier contient la structure de toutes les tables

-- ============================================
-- TABLE: users (utilisateurs)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,                    -- ID auto-incrémenté
    username VARCHAR(50) UNIQUE NOT NULL,     -- Nom d'utilisateur unique
    email VARCHAR(100) UNIQUE NOT NULL,       -- Email unique
    password_hash VARCHAR(255) NOT NULL,      -- Mot de passe hashé (JAMAIS en clair!)
    created_at TIMESTAMP DEFAULT NOW(),       -- Date de création du compte
    updated_at TIMESTAMP DEFAULT NOW()        -- Dernière modification
);

-- ============================================
-- TABLE: topics (sujets/catégories du forum)
-- ============================================
CREATE TABLE IF NOT EXISTS topics (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,               -- Ex: "Café", "Thé", "Chocolat chaud"
    description TEXT,                         -- Description du topic
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- TABLE: posts (messages/posts du forum)
-- ============================================
CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,              -- Titre du post
    content TEXT NOT NULL,                    -- Contenu du post
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,  -- Auteur (lié à users)
    topic_id INTEGER REFERENCES topics(id) ON DELETE CASCADE, -- Topic associé
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- INDEXES pour améliorer les performances
-- ============================================
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_topic_id ON posts(topic_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- ============================================
-- Données de test (optionnel - topics par défaut)
-- ============================================
INSERT INTO topics (name, description) VALUES
    ('Café', 'Discussions autour du café : recettes, techniques, matériel'),
    ('Thé', 'L''univers du thé : variétés, préparations, cérémonies'),
    ('Chocolat chaud', 'Le plaisir du chocolat chaud et ses variantes'),
    ('Infusions', 'Tisanes et infusions de toutes sortes')
ON CONFLICT DO NOTHING;

-- ============================================
-- FIN DU SCHÉMA
-- ============================================
