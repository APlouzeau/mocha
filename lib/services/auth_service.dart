import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_service.dart';

class AuthService extends BaseService {
  static Future<Map<String, dynamic>> register({
    required String nickName,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseService.baseUrl}/auth/register'),
        body: jsonEncode({
          'nickName': nickName,
          'email': email,
          'password': password,
          'passwordConfirm': passwordConfirm,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Une erreur est survenue',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion : $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseService.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Identifiants incorrects',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion : $e'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? nickName,
    String? email,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${BaseService.baseUrl}/auth/update-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (nickName != null) 'nickName': nickName,
          if (email != null) 'email': email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': data['user'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Une erreur est survenue',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion : $e'};
    }
  }
}
