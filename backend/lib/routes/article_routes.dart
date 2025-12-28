import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database/db.dart';
import '../models/article.dart';
import '../utils/check_data.dart';

Router articleRoutes(Database db) {
  final router = Router();
  
  router.post('/save', (Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final title = data['title'] as String?;
      final content = data['content'] as String?;
      final user_id = data['user_id'] as int?;
      
      if (!CheckDataUtils.isValidFields([title, content, user_id])) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Tous les champs sont requis.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final conn = db.connection;
      final existingArticle = await conn.execute(
        'SELECT title FROM articles WHERE title = \$1',
        parameters: [title],
      );
      
      if (existingArticle.isNotEmpty) {
        return Response(409,
          body: jsonEncode({'error': 'Titre déjà utilisé'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = await conn.execute(
        'INSERT INTO articles (title, content, user_id) VALUES (\$1, \$2, \$3) RETURNING id, title, content, user_id, created_at',
        parameters: [title, content, user_id],
      );

      final articleRow = result.first;
      final article = Article(
        id: articleRow[0] as int,
        title: articleRow[1] as String,
        content: articleRow[2] as String,
        user_id: articleRow[3] as int,
        created_at: articleRow[4] as DateTime,
      );


      return Response.ok(
        jsonEncode({
          'message': 'Article enregistré avec succès',
          'article': article.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in /register: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Échec de l\'enregistrement : ${e.toString()}'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

/*   router.post('/login', (Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final email = data['email'] as String?;
      final password = data['password'] as String?;
      
      if (!CheckDataUtils.isValidFields([email, password])) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Tous les champs sont requis'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final conn = db.connection;
      final existingUser = await conn.execute(
        'SELECT id, password_hash, nick_name, role_id FROM users WHERE email = \$1',
        parameters: [email],
      );
      
      if (existingUser.isEmpty) {
        return Response(401,
          body: jsonEncode({'error': 'Identifiant ou mot de passe incorrect'}),
          headers: {'Content-Type': 'application/json'},
        );
      }


      


      final user = User(
        id: existingUser.first[0] as int,
        nickName: existingUser.first[2] as String,
        email: email!,
        passwordHash: existingUser.first[1] as String,
        roleId: existingUser.first[3] as int,
        createdAt: DateTime.now(),
      );

      final token = JwtUtils.generateToken(user);

      return Response.ok(
        jsonEncode({
          'message': 'Connexion réussie',
          'token': token,
          'user': user.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in /login: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erreur lors de la connexion'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }); */

  return router;
}