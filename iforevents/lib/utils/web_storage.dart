// Web-specific storage implementation
import 'package:web/web.dart' as html;

class WebStorage {
  static String? getItem(String key) {
    return html.window.localStorage.getItem(key);
  }

  static void setItem(String key, String value) {
    html.window.localStorage.setItem(key, value);
  }
}
