import 'package:shelf/shelf.dart';
import 'dart:convert';
import 'jwt.dart';

/// Middleware pour vérifier l'authentification JWT
Middleware requireAuth() {
  return (Handler handler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(
          401,
          body: jsonEncode({'error': 'Token d\'authentification requis'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final token = authHeader.substring(7);
      final jwt = JwtUtils.verifyTokenFull(token);

      if (jwt == null) {
        return Response(
          401,
          body: jsonEncode({'error': 'Token invalide ou expiré'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Ajouter les informations de l'utilisateur dans les headers de la requête
      final payload = jwt.payload as Map<String, dynamic>;
      final updatedRequest = request.change(
        headers: {
          ...request.headers,
          'x-user-id': payload['id'].toString(),
          'x-user-role-id': payload['roleId'].toString(),
        },
      );

      return handler(updatedRequest);
    };
  };
}

/// Middleware pour vérifier que l'utilisateur est modérateur (role_id 2) ou administrateur (role_id 3)
Middleware requireModeratorOrAdmin() {
  return (Handler handler) {
    return (Request request) async {
      final roleIdStr = request.headers['x-user-role-id'];

      if (roleIdStr == null) {
        return Response(
          403,
          body: jsonEncode({'error': 'Accès refusé : rôle non vérifié'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final roleId = int.tryParse(roleIdStr);

      if (roleId == null || (roleId != 2 && roleId != 3)) {
        return Response(
          403,
          body: jsonEncode({
            'error':
                'Accès refusé : seuls les modérateurs et administrateurs peuvent effectuer cette action',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return handler(request);
    };
  };
}
