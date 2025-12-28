import 'dart:convert';
import 'package:http/http.dart' as http;

class CommentService extends BaseService {

  static Future<Map<String, dynamic>> postComment({
    required String comment,
    required int article_id,
    required int user_id,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseService.baseUrl}/comment/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'comment': comment,
          'article_id': article_id,
          'user_id': user_id,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Commentaire créé avec succès',
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Une erreur est survenue',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur : $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getComment({
    required int id,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseService.baseUrl}/comment/get'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Commentaire récupéré avec succès',
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Une erreur est survenue',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur : $e',
      };
    }
  }
}
