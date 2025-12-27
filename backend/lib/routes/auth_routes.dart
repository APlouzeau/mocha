import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database/db.dart';
import '../models/user.dart';
import '../utils/password.dart';
import '../utils/jwt.dart';
import '../utils/check_data.dart';

Router authRoutes(Database db) {
  final router = Router();
  
  router.post('/register', (Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final username = data['username'] as String?;
      final email = data['email'] as String?;
      final password = data['password'] as String?;
      
      if (!CheckDataUtils.isValidFields([username, email, password])) {
        return Response.badRequest(
          body: jsonEncode({'error': 'All fields are required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final conn = db.connection;
      final existingUser = await conn.execute(
        'SELECT id FROM users WHERE email = \$1',
        parameters: [email],
      );
      
      if (existingUser.isNotEmpty) {
        return Response(409,
          body: jsonEncode({'error': 'Email already in use'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final hashedPassword = PasswordUtils.hashPassword(password!);

      final result = await conn.execute(
        'INSERT INTO users (username, email, password_hash) VALUES (\$1, \$2, \$3) RETURNING id, username, email, created_at',
        parameters: [username, email, hashedPassword],
      );

      final userRow = result.first;
      final user = User(
        id: userRow[0] as int,
        username: userRow[1] as String,
        email: userRow[2] as String,
        passwordHash: hashedPassword,
        createdAt: userRow[3] as DateTime,
      );

      final token = JwtUtils.generateToken(user);

      return Response.ok(
        jsonEncode({
          'message': 'User registered successfully',
          'token': token,
          'user': user.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in /register: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Registration failed: ${e.toString()}'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.post('/login', (Request request) async {
    return Response.ok('Login route - TODO');
  });

  return router;
}