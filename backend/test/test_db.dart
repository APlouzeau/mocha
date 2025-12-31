import 'package:backend/database/db.dart';

void main() async {
  print('🧪 Test de connexion à PostgreSQL...\n');
  
  final success = await Database.connect();
  
  if (success) {
    print('\n✅ Tout fonctionne ! La base de données est prête.');
    
    // Récupérer les topics pour vérifier
    final conn = await Database.getConnection();
    final results = await conn.execute('SELECT * FROM topics');
    
    print('\n📚 Topics disponibles :');
    for (final row in results) {
      print('  - ${row[1]} : ${row[2]}');
    }
  } else {
    print('\n❌ Erreur : impossible de se connecter à la base de données');
  }
  
  await Database.close();
}
