.PHONY: run clean build devices help

# Lance l'app avec hot reload sur le téléphone
run:
	flutter run

# Lance sur un device spécifique
run-device:
	flutter run -d $(DEVICE)

# Nettoie le projet
clean:
	flutter clean
	flutter pub get

# Build APK pour Android
build-apk:
	flutter build apk --release

# Build pour iOS
build-ios:
	flutter build ios --release

# Liste les devices connectés
devices:
	flutter devices

# Récupère les dépendances
deps:
	flutter pub get

# Aide
help:
	@echo "Commandes disponibles:"
	@echo "  make run          - Lance l'app avec hot reload"
	@echo "  make run-device   - Lance sur un device spécifique (DEVICE=id)"
	@echo "  make clean        - Nettoie le projet"
	@echo "  make build-apk    - Build APK release"
	@echo "  make build-ios    - Build iOS release"
	@echo "  make devices      - Liste les devices connectés"
	@echo "  make deps         - Récupère les dépendances"
