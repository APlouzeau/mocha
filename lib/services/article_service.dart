import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_service.dart';

class UnauthorizedException implements Exception {}

class ArticleService {
  static Future<Map<String, dynamic>> postArticle({
    required String title,
    required String content,
    required int user_id,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseService.baseUrl}/article/save'),
        headers: await BaseService.authHeaders()
          ..addAll({'Content-Type': 'application/json'}),
        body: jsonEncode({
          'title': title,
          'content': content,
          'user_id': user_id,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      }

      return {
        'success': false,
        'message': data['error'] ?? 'Erreur lors de la création',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur : $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getArticle({required int id}) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseService.baseUrl}/article/get'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'article':
              data['article'] ??
              <String, dynamic>{'title': null, 'content': null},
        };
      } else {
        final msg = (data is Map)
            ? (data['error'] ?? data['message'] ?? 'Une erreur est survenue')
            : 'Erreur serveur ${response.statusCode}';
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur : $e',
      };
    }
  }

  static Future<List<dynamic>> getAllArticles() async {
    try {
      final response = await http.post(
        Uri.parse('${BaseService.baseUrl}/article/getallposts'),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // si le backend renvoie directement une liste
        if (data is List) return data;
        // si le backend emballe la liste dans une clé (data / articles / message)
        if (data is Map) {
          if (data['data'] is List) return data['data'];
          if (data['articles'] is List) return data['articles'];
          if (data['message'] is List) return data['message'];
          for (final v in data.values) {
            if (v is List) return v;
          }
          // pas de liste trouvée -> retourner vide
          return <dynamic>[];
        }
        return <dynamic>[];
      } else {
        final err = (data is Map)
            ? data['error'] ?? data['message']
            : 'Erreur serveur ${response.statusCode}';
        throw Exception(err);
      }
    } catch (e) {
      throw Exception('Erreur de connexion au serveur : $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getComments({
    required int articleId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseService.baseUrl}/comment/getbyarticle'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'article_id': articleId}),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data is List) {
          return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
        if (data is Map) {
          if (data['comments'] is List) {
            return (data['comments'] as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          }
          if (data['data'] is List) {
            return (data['data'] as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          }
          for (final v in data.values) {
            if (v is List) {
              return v.map((e) => Map<String, dynamic>.from(e as Map)).toList();
            }
          }
        }
        return <Map<String, dynamic>>[];
      } else {
        final err = (data is Map)
            ? data['error'] ?? data['message'] ?? 'Erreur serveur'
            : 'Erreur serveur ${response.statusCode}';
        throw Exception(err);
      }
    } catch (e) {
      throw Exception('Erreur récupération commentaires : $e');
    }
  }
}
