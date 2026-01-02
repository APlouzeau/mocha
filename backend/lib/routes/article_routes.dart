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
        return Response(
          409,
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
        body: jsonEncode({
          'error': 'Échec de l\'enregistrement : ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.post('/get', (Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final id = data['id'] as int?;

      if (!CheckDataUtils.isValidFields([id])) {
        return Response.badRequest(
          body: jsonEncode({'error': 'ID requis.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final conn = db.connection;
      final existingArticle = await conn.execute(
        'SELECT a.id, a.title, a.content, a.user_id, a.created_at, u.nick_name FROM articles a INNER JOIN users u ON a.user_id = u.id WHERE a.id = \$1',
        parameters: [id],
      );

      if (existingArticle.isEmpty) {
        return Response(
          404,
          body: jsonEncode({'error': 'Article non trouvé'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final articleRow = existingArticle.first;
      final article = {
        'id': articleRow[0] as int,
        'title': articleRow[1] as String,
        'content': articleRow[2] as String,
        'nick_name': articleRow[5] as String?,
        'created_at': (articleRow[4] as DateTime).toIso8601String(),
      };

      print(article);

      return Response.ok(
        jsonEncode({
          'message': 'Article récupéré avec succès',
          'article': article,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in /get: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Erreur lors de la récupération de l\'article',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.post('/getallposts', (Request request) async {
    try {
      final conn = db.connection;
      final existingArticle = await conn.execute('SELECT * FROM articles');

      if (existingArticle.isEmpty) {
        return Response(
          404,
          body: jsonEncode({'error': 'Aucun article trouvé'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final articles = existingArticle.map((row) {
        return Article(
          id: row[0] as int,
          title: row[1] as String,
          content: row[2] as String,
          user_id: row[3] as int,
          created_at: row[4] as DateTime,
        );
      }).toList();

      return Response(
        200,
        body: jsonEncode(articles.map((a) => a.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in /get: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Erreur lors de la récupération de l\'article',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  return router;
}
