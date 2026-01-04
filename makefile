.PHONY: run clean build devices help db-start db-stop db-remove db-logs

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
	@echo "  make back         - Lance le backend de l'app"
	@echo "  make run-device   - Lance sur un device spécifique (DEVICE=id)"
	@echo "  make clean        - Nettoie le projet"
	@echo "  make build-apk    - Build APK release"
	@echo "  make build-ios    - Build iOS release"
	@echo "  make devices      - Liste les devices connectés"
	@echo "  make deps         - Récupère les dépendances"
	@echo "  make dev          - Lance DB + Backend + Frontend"
	@echo "  make stop         - Arrête tous les services"
	@echo "  make back-logs    - Voir les logs du backend"
	@echo "  make db-start     - Démarrer PostgreSQL avec Docker"
	@echo "  make db-stop      - Arrêter PostgreSQL"
	@echo "  make db-clean     - Supprimer le container et les données"

back:
	lsof -ti:8080 | xargs kill -9 2>/dev/null; dart run backend/bin/server.dart

# Docker PostgreSQL
db-start:
	docker-compose up -d
	@echo "⏳ Attente du démarrage de PostgreSQL..."
	@sleep 5
	@echo "✅ PostgreSQL démarré sur localhost:5432"

db-stop:
	docker-compose down

db-clean:
	docker-compose down -v
	@echo "🗑️  Base de données supprimée"

db-logs:
	docker-compose logs -f postgres

# Lancer tout en développement (DB + Backend + Frontend)
dev:
	@echo "🚀 Démarrage de l'environnement de développement..."
	@make db-start
	@echo "🔧 Lancement du backend en arrière-plan..."
	@(make back > /tmp/mocha-backend.log 2>&1 &)
	@sleep 3
	@echo "📱 Lancement de l'application Flutter..."
	@make run

# Arrêter tous les services
stop:
	@echo "🛑 Arrêt des services..."
	@lsof -ti:8080 | xargs kill -9 2>/dev/null || true
	@make db-stop
	@echo "✅ Services arrêtés"

# Voir les logs du backend
back-logs:
	@tail -f /tmp/mocha-backend.log