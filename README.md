# Mocha

Application Flutter multi-plateforme.

## 🚀 Démarrage rapide

### Prérequis

-   Flutter SDK (dernière version stable)
-   Un téléphone Android/iOS avec le débogage USB activé, ou un émulateur

### Installation

```bash
# Installer les dépendances
make deps

# Lancer l'app avec hot reload
make run
```

## 📱 Commandes disponibles

```bash
make run          # Lance l'app avec hot reload
make back         # Lance le backend de l'app
make run-device   # Lance sur un device spécifique (DEVICE=id)
make devices      # Liste les devices connectés
make clean        # Nettoie le projet
make build-apk    # Build APK Android release
make build-ios    # Build iOS release
make deps         # Récupère les dépendances
make help         # Affiche l'aide
```

## 🛠️ Développement

Pour lancer l'app sur un device spécifique :

```bash
# Liste les devices disponibles
make devices

# Lance sur le device choisi
make run-device DEVICE=<device-id>
```

Le hot reload est activé automatiquement - modifiez votre code et les changements seront instantanément reflétés sur votre appareil.

## 📦 Build

```bash
# Android
make build-apk

# iOS
make build-ios
```

## 📄 Licence

Ce projet est sous licence MIT.
