import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edaptia/services/course/models.dart';

/// Cache persistente para módulos adaptativos generados
/// Similar a LocalOutlineStorage pero para el flujo adaptativo
class AdaptiveModuleCache {
  AdaptiveModuleCache._();

  static final AdaptiveModuleCache instance = AdaptiveModuleCache._();

  static const _keyPrefix = 'adaptive_module_cache_';
  static const Duration _retentionWindow = Duration(days: 7);

  String _buildKey({
    required String topic,
    required String language,
    required String band,
    required int moduleNumber,
  }) {
    final normalized = topic.trim().toLowerCase();
    final langNorm = language.trim().toLowerCase();
    final bandNorm = band.trim().toLowerCase();
    return '$_keyPrefix${normalized}_${langNorm}_${bandNorm}_m$moduleNumber';
  }

  /// Guarda un módulo en cache
  Future<void> saveModule({
    required String topic,
    required String language,
    required String band,
    required AdaptiveModuleOut module,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _buildKey(
        topic: topic,
        language: language,
        band: band,
        moduleNumber: module.moduleNumber,
      );

      final data = {
        'module': module.toJson(),
        'savedAt': DateTime.now().toIso8601String(),
        'topic': topic,
        'language': language,
        'band': band,
      };

      await prefs.setString(key, jsonEncode(data));
    } catch (e) {
      // Fail silently - cache is optional
      debugPrint('[AdaptiveModuleCache] Error saving module: $e');
    }
  }

  /// Carga un módulo desde cache
  Future<AdaptiveModuleOut?> loadModule({
    required String topic,
    required String language,
    required String band,
    required int moduleNumber,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _buildKey(
        topic: topic,
        language: language,
        band: band,
        moduleNumber: moduleNumber,
      );

      final raw = prefs.getString(key);
      if (raw == null) return null;

      final data = jsonDecode(raw) as Map<String, dynamic>;
      final savedAtStr = data['savedAt'] as String?;

      // Verificar si expiró
      if (savedAtStr != null) {
        final savedAt = DateTime.tryParse(savedAtStr);
        if (savedAt != null) {
          final age = DateTime.now().difference(savedAt);
          if (age > _retentionWindow) {
            // Cache expirado, eliminar
            await prefs.remove(key);
            return null;
          }
        }
      }

      final moduleData = data['module'] as Map<String, dynamic>;
      return AdaptiveModuleOut.fromJson(moduleData);
    } catch (e) {
      debugPrint('[AdaptiveModuleCache] Error loading module: $e');
      return null;
    }
  }

  /// Limpia todos los módulos cacheados (útil para testing)
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final moduleKeys = keys.where((k) => k.startsWith(_keyPrefix));
      for (final key in moduleKeys) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('[AdaptiveModuleCache] Error clearing cache: $e');
    }
  }
}
