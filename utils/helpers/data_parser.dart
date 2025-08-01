class DataParser {
  /// 🔹 **Helper to parse `double` values safely**
  static double parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// 🔹 **Helper to parse `int` values safely**
  static int parseInt(dynamic value, {int defaultValue = 1}) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// 🔹 **Validate image URL**
  static String validateImageUrl(dynamic value) {
    if (value == null || value.toString().trim().isEmpty || value == "null") {
      return "assets/images/no_image.png";
    }
    return value.toString();
  }
}
