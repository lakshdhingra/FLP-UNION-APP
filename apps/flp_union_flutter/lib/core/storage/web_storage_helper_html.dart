// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

abstract class WebStorageHelper {
  static String? getItem(String key) {
    try {
      return html.window.localStorage[key];
    } catch (_) {
      return null;
    }
  }

  static void setItem(String key, String value) {
    try {
      html.window.localStorage[key] = value;
    } catch (_) {}
  }

  static void removeItem(String key) {
    try {
      html.window.localStorage.remove(key);
    } catch (_) {}
  }
}
