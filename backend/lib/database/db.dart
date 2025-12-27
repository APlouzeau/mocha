import 'package:postgres/postgres.dart';
import 'package:dotenv/dotenv.dart';

// 🗄️ CONNEXION À POSTGRESQL
// Ce fichier gère la connexion à la base de données

class Database {
  static Connection? _connection;
  
  // 📡 Créer la connexion à PostgreSQL
  static Future<Connection> getConnection() async {
    // Si une connexion existe déjà, on la réutilise
    if (_connection != null) {
      return _connection!;
    }
    
    // Charger les variables d'environnement depuis .env
    final env = DotEnv(includePlatformEnvironment: true)..load();
    
    // Créer la connexion avec les paramètres du .env
    _connection = await Connection.open(
      Endpoint(
        host: env['DB_HOST'] ?? 'localhost',
        port: int.parse(env['DB_PORT'] ?? '5432'),
        database: env['DB_NAME'] ?? 'mocha_db',
        username: env['DB_USER'] ?? 'mocha_user',
        password: env['DB_PASSWORD'] ?? 'mocha_password_dev',
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.disable, // En dev, pas de SSL
      ),
    );
    
    print('✅ Connexion à PostgreSQL établie !');
    return _connection!;
  }
  
  // 🔌 Fermer la connexion (utile pour les tests)
  static Future<void> close() async {
    await _connection?.close();
    _connection = null;
    print('🔌 Connexion PostgreSQL fermée');
  }
  
  // 🧪 Tester la connexion
  static Future<bool> testConnection() async {
    try {
      final conn = await getConnection();
      final result = await conn.execute('SELECT 1');
      print('🧪 Test de connexion réussi !');
      return true;
    } catch (e) {
      print('❌ Erreur de connexion: $e');
      return false;
    }
  }
}
