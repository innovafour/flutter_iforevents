// Stub implementation for non-web platforms
class WebStorage {
  static String? getItem(String key) {
    return null;
  }

  static void setItem(String key, String value) {
    // No-op for non-web platforms
  }
}
