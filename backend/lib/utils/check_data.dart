class CheckDataUtils {
    static bool isValidFields(List<dynamic> dataFields) {
        for (var field in dataFields) {
            if (field == null || (field is String && field.trim().isEmpty)) {
                return false;
            }
        }
        return true;
    }
}