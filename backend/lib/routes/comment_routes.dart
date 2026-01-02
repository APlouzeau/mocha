import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database/db.dart';
import '../models/comment.dart';
import '../utils/check_data.dart';

Router commentRoutes(Database db) {
  final router = Router();

  router.post('/save', (Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final comment = data['comment'] as String?;
      final article_id = data['article_id'] as int?;
      final user_id = data['user_id'] as int?;

      if (!CheckDataUtils.isValidFields([comment, article_id, user_id])) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Tous les champs sont requis.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final conn = db.connection;
      final result = await conn.execute(
        'INSERT INTO comments (comment, article_id, user_id) VALUES (\$1, \$2, \$3) RETURNING id, comment, article_id, user_id, created_at',
        parameters: [comment, article_id, user_id],
      );

      final commentRow = result.first;
      final commentary = Comment(
        id: commentRow[0] as int,
        comment: commentRow[1] as String,
        article_id: commentRow[2] as int,
        user_id: commentRow[3] as int,
        created_at: commentRow[4] as DateTime,
      );

      return Response.ok(
        jsonEncode({
          'message': 'Commentaire enregistré avec succès',
          'comment': commentary.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in /register: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Échec de l\'inscription : ${e.toString()}',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.post('/getbyarticle', (Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final article_id = data['article_id'] as int?;

      if (!CheckDataUtils.isValidFields([article_id])) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Tous les champs sont requis'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final conn = db.connection;
      final commentsResult = await conn.execute(
        'SELECT c.id, c.comment, c.user_id, c.article_id, c.created_at, u.nick_name FROM comments c INNER JOIN users u ON c.user_id = u.id WHERE article_id = \$1 ORDER BY created_at DESC',
        parameters: [article_id],
      );

      final comments = commentsResult
          .map(
            (row) => {
              'id': row[0] as int,
              'comment': row[1] as String,
              'user_id': row[2] as int,
              'article_id': row[3] as int,
              'created_at': row[4].toString(),
              'nick_name': row[5] as String?,
            },
          )
          .toList();

      return Response.ok(
        jsonEncode({
          'message': 'Commentaires récupérés avec succès',
          'comments': comments,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in /getAll: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Erreur lors de la récupération des commentaires',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  return router;
}