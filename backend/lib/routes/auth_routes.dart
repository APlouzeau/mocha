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
      final passwordConfirm = data['passwordConfirm'] as String?;

      if (!CheckDataUtils.isValidFields([
        nickName,
        email,
        password,
        passwordConfirm,
      ])) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Tous les champs sont requis.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (!CheckDataUtils.isValidEmail(email!)) {
        return Response(
          409,
          body: jsonEncode({'error': 'Format d\'email invalide.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (!PasswordUtils.passwordLengthValid(password!)) {
        return Response(
          409,
          body: jsonEncode({
            'error': 'Le mot de passe doit contenir au moins 8 caractères.',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (!PasswordUtils.passwordConfirmationValid(
        password,
        passwordConfirm!,
      )) {
        return Response(
          409,
          body: jsonEncode({
            'error': 'Les mots de passe ne correspondent pas.',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final conn = db.connection;
      final existingUserMail = await conn.execute(
        'SELECT id FROM users WHERE email = \$1',
        parameters: [email],
      );

      if (existingUserMail.isNotEmpty) {
        return Response(
          409,
          body: jsonEncode({'error': 'Email déjà utilisé'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final existingUserNickName = await conn.execute(
        'SELECT id FROM users WHERE nick_name = \$1',
        parameters: [nickName],
      );

      if (existingUserNickName.isNotEmpty) {
        return Response(
          409,
          body: jsonEncode({'error': 'Nom d\'utilisateur déjà utilisé'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final hashedPassword = PasswordUtils.hashPassword(password);

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
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Échec de l\'inscription : ${e.toString()}',
        }),
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
        'SELECT u.id, u.password_hash, u.nick_name, u.role_id, r.role, u.created_at FROM users u JOIN roles r ON u.role_id = r.id WHERE email = \$1',
        parameters: [email],
      );

      if (existingUser.isEmpty) {
        return Response(
          401,
          body: jsonEncode({'error': 'Identifiant ou mot de passe incorrect'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final userPasswordCheck = PasswordUtils.verifyPassword(
        password!,
        existingUser.first[1] as String,
      );

      if (!userPasswordCheck) {
        return Response(
          401,
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
        createdAt: existingUser.first[5] as DateTime,
      );

      final token = JwtUtils.generateToken(user);

      final userResponse = {
        'id': existingUser.first[0] as int,
        'nickName': existingUser.first[2] as String,
        'email': email,
        'role': existingUser.first[4] as String,
        'createdAt': (existingUser.first[5] as DateTime).toIso8601String(),
      };

      return Response.ok(
        jsonEncode({
          'message': 'Connexion réussie',
          'token': token,
          'user': userResponse,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erreur lors de la connexion'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.post('/logout', (Request request) async {
    return Response.ok(
      jsonEncode({'message': 'Déconnexion réussie'}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.put('/update-profile', (Request request) async {
    try {
      // Récupérer le token depuis le header Authorization
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(
          401,
          body: jsonEncode({'error': 'Token manquant'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final token = authHeader.substring(7); // Enlever "Bearer "
      final userId = JwtUtils.verifyToken(token);

      if (userId == null) {
        return Response(
          401,
          body: jsonEncode({'error': 'Token invalide ou expiré'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final nickName = data['nickName'] as String?;
      final email = data['email'] as String?;

      final conn = db.connection;

      final updateFields = <String>[];
      final parameters = <dynamic>[];
      var paramIndex = 1;

      if (nickName != null) {
        updateFields.add('nick_name = \$${paramIndex++}');
        parameters.add(nickName);
      }
      if (email != null) {
        updateFields.add('email = \$${paramIndex++}');
        parameters.add(email);
      }

      if (updateFields.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Aucun champ à mettre à jour'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      parameters.add(userId);

      final updateQuery =
          'UPDATE users SET ${updateFields.join(', ')} WHERE id = \$${paramIndex}';

      print(userId);
      await conn.execute(updateQuery, parameters: parameters);

      return Response.ok(
        jsonEncode({'message': 'Profil mis à jour avec succès'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erreur lors de la mise à jour du profil'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  return router;
}
