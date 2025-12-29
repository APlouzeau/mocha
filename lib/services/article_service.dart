import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  // Ajoute cette méthode à la classe ArticleService (ou en tant que fonction utilitaire)
  static Future<void> createArticle(String title, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson == null || userJson.isEmpty) {
      throw UnauthorizedException();
    }
    final token = jsonDecode(userJson)['token'] as String?;
    if (token == null || token.isEmpty) {
      throw UnauthorizedException();
    }

    final base = dotenv.env['API_URL'] ?? 'http://localhost:8080';
    final uri = Uri.parse('$base/articles');

    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'content': content,
      }),
    );

    if (resp.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('Erreur serveur (${resp.statusCode}): ${resp.body}');
    }
  }
}