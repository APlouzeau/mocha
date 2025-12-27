import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/register');
      
      final body = jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      });
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Erreur inconnue'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion: $e'};
    }
  }
}