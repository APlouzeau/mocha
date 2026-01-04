#!/bin/bash

# Script pour générer une clé JWT aléatoire
# Fonctionne sur Linux, macOS et Windows (avec Git Bash ou WSL)

# Fonction pour générer la clé avec OpenSSL
generate_with_openssl() {
    openssl rand -base64 32
}

# Fonction pour générer la clé avec /dev/urandom (Linux/macOS)
generate_with_urandom() {
    head -c 32 /dev/urandom | base64
}

# Fonction pour générer la clé avec /dev/random (fallback)
generate_with_random() {
    head -c 32 /dev/random | base64
}

# Essayer différentes méthodes selon la disponibilité
if command -v openssl &> /dev/null; then
    # Méthode 1 : OpenSSL (le plus fiable)
    KEY=$(generate_with_openssl)
elif [ -e /dev/urandom ]; then
    # Méthode 2 : /dev/urandom (Linux/macOS)
    KEY=$(generate_with_urandom)
elif [ -e /dev/random ]; then
    # Méthode 3 : /dev/random (fallback)
    KEY=$(generate_with_random)
else
    # Méthode 4 : Fallback avec date + shasum (moins sécurisé mais fonctionne partout)
    KEY=$(date +%s | shasum -a 256 | base64 | head -c 44)
fi

# Afficher la clé
echo "$KEY"

