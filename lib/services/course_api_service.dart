import 'dart:convert';
import 'dart:math' as math;

import 'package:aelion/services/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio para consumir el endpoint /outline.
/// Usa Flutter/Firebase Auth para adjuntar credenciales y aplica reintentos.
class CourseApiService {
  CourseApiService._();

  static const _timeout = Duration(seconds: 25);

  static Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  /// Llama a `/outline` con topic, depth y lang.
  /// Devuelve un Map con `source` ('cache'|'fresh') y `outline` (List).
  static Future<Map<String, dynamic>> generateOutline({
    required String topic,
    String depth = 'medium',
    String lang = 'en',
    Duration timeout = _timeout,
    int maxRetries = 3,
  }) async {
    final trimmedTopic = topic.trim();
    if (trimmedTopic.isEmpty) {
      throw ArgumentError('Topic cannot be empty.');
    }

    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();

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

        if (res.statusCode == 200) {
          final decoded = jsonDecode(res.body);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
          throw const FormatException('Invalid response format from server.');
        }

        if (res.statusCode == 429 ||
            (res.statusCode >= 500 && res.statusCode < 600)) {
          attempt++;
          if (attempt > maxRetries) {
            final detail = res.body.isNotEmpty ? res.body : 'No details';
            throw Exception(
              'Failed after retries (${res.statusCode}): $detail',
            );
          }
          final delayMs = _backoffWithJitterMs(attempt);
          await Future.delayed(Duration(milliseconds: delayMs));
          continue;
        }

        final detail = res.body.isNotEmpty ? res.body : 'No details';
        throw Exception('Failed to generate outline (${res.statusCode}): $detail');
      } catch (error) {
        lastError = error;
        attempt++;
        if (attempt > maxRetries) {
          rethrow;
        }
        final delayMs = _backoffWithJitterMs(attempt);
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }

    throw Exception('Failed to generate outline. Last error: $lastError');
  }

  static int _backoffWithJitterMs(int attempt) {
    const base = 400;
    const cap = 3000;
    final expo = base * math.pow(2, attempt - 1).toInt();
    final jitter = math.Random().nextInt(250);
    return math.min(cap, expo + jitter);
  }
}
