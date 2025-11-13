import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Service for managing user language preferences
class LanguagePreferences {
  static const String _keyLanguageCode = 'app_language_code';

  /// Get the saved language code
  static Future<String?> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguageCode);
  }

  /// Set the language code
  static Future<void> setLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguageCode, languageCode);
  }

  /// Clear the saved language preference
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLanguageCode);
  }

  /// Convert language code to Locale
  static Locale? getLocale(String? languageCode) {
    if (languageCode == null || languageCode.isEmpty) return null;
    return Locale(languageCode);
  }
}
