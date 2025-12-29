import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../helpers/auth_helper.dart';

class BaseService {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

  static Future<Map<String, String>> authHeaders() async {
    final token = await AuthHelper.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
