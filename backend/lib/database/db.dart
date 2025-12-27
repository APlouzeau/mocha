import 'package:postgres/postgres.dart';
import 'package:dotenv/dotenv.dart';

class Database {
  late Connection _connection;
  
  Connection get connection => _connection;
  
  Future<void> connect() async {
    try {
      final env = DotEnv(includePlatformEnvironment: true)..load();
      
      final endpoint = Endpoint(
        host: env['DB_HOST'] ?? 'localhost',
        port: int.parse(env['DB_PORT'] ?? '5432'),
        database: env['DB_NAME'] ?? 'mocha_db',
        username: env['DB_USER'] ?? 'mocha_user',
        password: env['DB_PASSWORD'] ?? 'mocha_password_dev',
      );
      
      _connection = await Connection.open(
        endpoint,
        settings: const ConnectionSettings(
          sslMode: SslMode.disable,
        ),
      );
      
      print('✅ Connexion à PostgreSQL établie !');
    } catch (e) {
      print('❌ Erreur de connexion à PostgreSQL: $e');
      rethrow;
    }
  }
  
  Future<void> close() async {
    await _connection.close();
    print('🔌 Connexion PostgreSQL fermée');
  }
}
