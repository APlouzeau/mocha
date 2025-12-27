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

      final nickName = data['nickName'] as String?;
      final email = data['email'] as String?;
      final password = data['password'] as String?;
      
      if (!CheckDataUtils.isValidFields([nickName, email, password])) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Tous les champs sont requis.'}),
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
          body: jsonEncode({'error': 'Email déjà utilisé'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final hashedPassword = PasswordUtils.hashPassword(password!);

      final result = await conn.execute(
        'INSERT INTO users (nick_name, email, password_hash) VALUES (\$1, \$2, \$3) RETURNING id, nick_name, email, role_id, created_at',
        parameters: [nickName, email, hashedPassword],
      );

      final userRow = result.first;
      final user = User(
        id: userRow[0] as int,
        nickName: userRow[1] as String,
        email: userRow[2] as String,
        passwordHash: hashedPassword,
        roleId: userRow[3] as int,
        createdAt: userRow[4] as DateTime,
      );

      final token = JwtUtils.generateToken(user);

      return Response.ok(
        jsonEncode({
          'message': 'Utilisateur enregistré avec succès',
          'token': token,
          'user': user.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in /register: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Échec de l\'inscription : ${e.toString()}'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.post('/login', (Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final email = data['email'] as String?;
      final password = data['password'] as String?;
      
      if (!CheckDataUtils.isValidFields([email, password])) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Tous les champs sont requis'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final conn = db.connection;
      final existingUser = await conn.execute(
        'SELECT id, password_hash, nick_name, role_id FROM users WHERE email = \$1',
        parameters: [email],
      );
      
      if (existingUser.isEmpty) {
        return Response(401,
          body: jsonEncode({'error': 'Identifiant ou mot de passe incorrect'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final userPasswordCheck = PasswordUtils.verifyPassword(
        password!,
        existingUser.first[1] as String,
      );
      
      if (!userPasswordCheck) {
        return Response(401,
          body: jsonEncode({'error': 'Identifiant ou mot de passe incorrect'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final user = User(
        id: existingUser.first[0] as int,
        nickName: existingUser.first[2] as String,
        email: email!,
        passwordHash: existingUser.first[1] as String,
        roleId: existingUser.first[3] as int,
        createdAt: DateTime.now(),
      );
        email: email!,
        passwordHash: existingUser.first[1] as String,
        createdAt: DateTime.now(),
      );

      final token = JwtUtils.generateToken(user);

      return Response.ok(
        jsonEncode({
          'message': 'Connexion réussie',
          'token': token,
          'user': user.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in /login: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erreur lors de la connexion'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  return router;
}