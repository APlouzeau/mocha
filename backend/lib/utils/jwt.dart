import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../models/user.dart';
import 'package:dotenv/dotenv.dart';

class JwtUtils {
  static String generateToken(User user) {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    final secret = env['JWT_SECRET'] ?? 'default_secret';
    final expiration = Duration(hours: 2);
    final jwt = JWT({
      'id': user.id,
      'nickName': user.nickName,
      'email': user.email,
      'roleId': user.roleId,
    }, issuer: 'mocha_backend');
    return jwt.sign(SecretKey(secret), expiresIn: expiration);
  }

  static int? verifyToken(String token) {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    final secret = env['JWT_SECRET'] ?? 'default_secret';
    try {
      final jwt = JWT.verify(token, SecretKey(secret));
      return jwt.payload['id'] as int?;
    } catch (e) {
      return null;
    }
  }

  static JWT? verifyTokenFull(String token) {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    final secret = env['JWT_SECRET'] ?? 'default_secret';
    try {
      return JWT.verify(token, SecretKey(secret));
    } catch (e) {
      return null;
    }
  }
}
