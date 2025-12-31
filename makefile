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
	@echo "  make db-create POSTGRES_DB=mocha_db POSTGRES_USER=mocha_user POSTGRES_PASSWORD=mocha_password POSTGRES_PORT=5432 - Crée le container PostgreSQL"

back:
	lsof -ti:8080 | xargs kill -9 2>/dev/null; dart run backend/bin/server.dart

# Crée le container PostgreSQL
db-create:
	docker run -d --name MochaDB \
		-e POSTGRES_DB=${POSTGRES_DB} \
		-e POSTGRES_USER=${POSTGRES_USER} \
		-e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
		-p ${POSTGRES_PORT}:5432 \
		postgres:15-alpine

# Remplir la base de données
db-populate:
	docker exec -i MochaDB psql -U mocha_user -d mocha_db < backend/database_schema.sql