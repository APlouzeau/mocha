import 'dart:convert';
import 'package:http/http.dart' as http;

class ArticleService extends BaseService {

  static Future<Map<String, dynamic>> postArticle({
    required String title,
    required String content,
    required int user_id,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseService.baseUrl}/article/save'),
        headers: await BaseService.authHeaders(),
        body: jsonEncode({
          'title': title,
          'content': content,
          'user_id': user_id,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Article créé avec succès',
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

  static Future<Map<String, dynamic>> getArticle({
    required String title,
    required String content,
    required String user_id,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseService.baseUrl}/article/get'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'content': content,
          'user_id': user_id,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Article récupéré avec succès',
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
