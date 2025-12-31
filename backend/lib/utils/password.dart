import 'package:bcrypt/bcrypt.dart';

class PasswordUtils {
  static String hashPassword(String plainPassword) {
    return BCrypt.hashpw(plainPassword, BCrypt.gensalt(logRounds: 12));
  }

  static bool verifyPassword(String plainPassword, String hashedPassword) {
    try {
      return BCrypt.checkpw(plainPassword, hashedPassword);
    } catch (e) {
      return false;
    }
  }
}