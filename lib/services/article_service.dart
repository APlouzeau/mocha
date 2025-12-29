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
      return {
        'success': true,
        'data': data, 
      };
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

  static Future<Map<String, dynamic>> getArticle({
    required int id,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseService.baseUrl}/article/get'),
        body: jsonEncode({
          'id': id,
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

  static Future<Map<String, dynamic>> getAllArticles() async {
    try {
      final response = await http.post(
        Uri.parse('${BaseService.baseUrl}/article/getallposts'),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Articles récupérés avec succès',
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