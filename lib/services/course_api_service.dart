import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio para consumir el endpoint /outline.
/// - Usa API_BASE_URL desde .env.public
/// - En release: NO permite localhost (falla explícitamente)
/// - En dev: puede usar emulador si USE_FUNCTIONS_EMULATOR=true
/// - Soporta Auth con Firebase (Bearer idToken)
/// - Reintentos con backoff en 429/5xx
class CourseApiService {
  CourseApiService._();

  /// Determina la base URL a usar.
  /// Prioridad:
  /// 1) API_BASE_URL de .env.public (recomendado para prod y CI)
  /// 2) Si en dev USE_FUNCTIONS_EMULATOR=true, arma URL del emulador
  /// 3) (Solo dev) Fallback localhost:8787 para compat con `server/`
  static String get _baseUrl {
    final envUrl = dotenv.env['API_BASE_URL']?.trim();

    // Si hay env explícita:
    if (envUrl != null && envUrl.isNotEmpty) {
      final sanitized =
          envUrl.endsWith('/') ? envUrl.substring(0, envUrl.length - 1) : envUrl;

      // Bloquear localhost en release
      if (kReleaseMode &&
          (sanitized.contains('localhost') || sanitized.contains('127.0.0.1'))) {
        throw StateError(
          'API_BASE_URL no puede apuntar a localhost/127.0.0.1 en release.',
        );
      }
      return sanitized;
    }

    // Si no hay env explícita y estamos en release → error controlado
    if (kReleaseMode) {
      throw StateError(
        'API_BASE_URL debe estar configurado en release (assets/env/.env.public).',
      );
    }

    // Dev: ¿usar emulador?
    final useEmu = (dotenv.env['USE_FUNCTIONS_EMULATOR'] ?? '').toLowerCase() == 'true';
    if (useEmu) {
      final project = (dotenv.env['FIREBASE_PROJECT_ID'] ?? '').trim();
      // Host por plataforma (Android Emulator usa 10.0.2.2)
      final host = (dotenv.env['FUNCTIONS_EMULATOR_HOST'] ?? 'localhost').trim();
      final port = (dotenv.env['FUNCTIONS_EMULATOR_PORT'] ?? '5001').trim();
      if (project.isEmpty) {
        throw StateError(
          'FIREBASE_PROJECT_ID requerido cuando USE_FUNCTIONS_EMULATOR=true.',
        );
      }
      return 'http://$host:$port/$project/us-east4';
    }

    // Dev: fallback a server local legacy (solo para compatibilidad)
    return 'http://localhost:8787';
  }

  static Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  /// Llama a /outline con topic, depth y lang.
  /// Devuelve un Map con `source` ('cache'|'fresh') y `outline` (List).
  static Future<Map<String, dynamic>> generateOutline({
    required String topic,
    String depth = 'medium',
    String lang = 'en',
    Duration timeout = const Duration(seconds: 25),
    int maxRetries = 3,
  }) async {
    final trimmedTopic = topic.trim();
    if (trimmedTopic.isEmpty) {
      throw ArgumentError('Topic cannot be empty.');
    }

    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();

    // Intentos con backoff exponencial para 429/5xx
    int attempt = 0;
    Object? lastError;
    while (attempt <= maxRetries) {
      try {
        final res = await http
            .post(
              _uri('/outline'),
              headers: {
                'Content-Type': 'application/json',
                if (idToken != null) 'Authorization': 'Bearer $idToken',
                if (user != null) 'X-User-Id': user.uid,
                'Accept': 'application/json',
              },
              body: jsonEncode({
                'topic': trimmedTopic,
                'depth': depth,
                'lang': lang,
              }),
            )
            .timeout(timeout);

        // OK
        if (res.statusCode == 200) {
          final decoded = jsonDecode(res.body);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
          throw const FormatException('Invalid response format from server.');
        }

        // Errores reintentarbles
        if (res.statusCode == 429 || (res.statusCode >= 500 && res.statusCode < 600)) {
          attempt++;
          if (attempt > maxRetries) {
            final detail = res.body.isNotEmpty ? res.body : 'No details';
            throw Exception(
              'Failed after retries (${res.statusCode}): $detail',
            );
          }
          // Backoff exponencial con jitter
          final delayMs = _backoffWithJitterMs(attempt);
          await Future.delayed(Duration(milliseconds: delayMs));
          continue;
        }

        // Errores no reintentarbles
        final detail = res.body.isNotEmpty ? res.body : 'No details';
        throw Exception('Failed to generate outline (${res.statusCode}): $detail');
      } catch (e) {
        lastError = e;
        attempt++;
        if (attempt > maxRetries) {
          rethrow;
        }
        // Backoff ante excepciones de red/timeout
        final delayMs = _backoffWithJitterMs(attempt);
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }

    // No debería llegar aquí
    throw Exception('Failed to generate outline. Last error: $lastError');
  }

  /// Backoff exponencial con jitter (ms).
  static int _backoffWithJitterMs(int attempt) {
    // base 400ms, cap ~3s
    final base = 400;
    final cap = 3000;
    final expo = base * math.pow(2, attempt - 1).toInt();
    final jitter = math.Random().nextInt(250); // +/- 250ms
    return math.min(cap, expo + jitter);
  }
}
