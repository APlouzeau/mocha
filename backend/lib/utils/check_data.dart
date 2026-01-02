class CheckDataUtils {
  static bool isValidFields(List<dynamic> dataFields) {
    for (var field in dataFields) {
      if (field == null || (field is String && field.trim().isEmpty)) {
        return false;
      }
    }
    return true;
  }

  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }
}
