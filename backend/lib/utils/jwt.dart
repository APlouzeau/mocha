import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../models/user.dart';
import 'package:dotenv/dotenv.dart';

class JwtUtils {
    static String generateToken(User user) {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    final secret = env['JWT_SECRET'] ?? 'default_secret';
    final expiration = Duration(hours: 2);
    final jwt = JWT(
      {
        'id': user.id,
        'nickName': user.nickName,
        'email': user.email,
        'roleId': user.roleId,
      },
      issuer: 'mocha_backend',
    );
    return jwt.sign(SecretKey(secret), expiresIn: expiration);
    }

    static JWT? verifyToken(String token) {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    final secret = env['JWT_SECRET'] ?? 'default_secret';
    try {
      final jwt = JWT.verify(token, SecretKey(secret));
      return jwt;
    } catch (e) {
      return null;
    }
  }
}