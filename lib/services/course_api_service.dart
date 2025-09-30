import 'dart:convert';

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class CourseApiService {
  /// Base URL for the API. Uses API_BASE_URL from .env.
  static String get _baseUrl {
    final raw = dotenv.env['API_BASE_URL']?.trim();
    if (raw == null || raw.isEmpty) {
      // In release mode, it's an error to not have the API_BASE_URL configured.
      assert(!kReleaseMode, 'API_BASE_URL must be set in release mode');
      return 'http://localhost:8787'; // Fallback for local development
    }
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  static Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  /// Generates a course outline by calling the /outline Firebase Function.
  ///
  /// Returns a map containing the `source` ('cache' or 'fresh') and the `outline` list.
  static Future<Map<String, dynamic>> generateOutline({
    required String topic,
    String depth = 'medium', // Default depth
    String lang = 'en',
  }) async {
    final trimmedTopic = topic.trim();
    if (trimmedTopic.isEmpty) {
      throw ArgumentError('Topic cannot be empty.');
    }

    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();

    final response = await http.post(
      _uri('/outline'),
      headers: {
        'Content-Type': 'application/json',
        if (idToken != null) 'Authorization': 'Bearer $idToken',
        // Pass user ID for observability
        if (user != null) 'X-User-Id': user.uid,
      },
      body: jsonEncode({
        'topic': trimmedTopic,
        'depth': depth,
        'lang': lang,
      }),
    );

    if (response.statusCode != 200) {
      final detail = response.body.isNotEmpty ? response.body : 'No details';
      throw Exception(
          'Failed to generate outline (${response.statusCode}): $detail');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    } else {
      throw Exception('Invalid response format from server.');
    }
  }
}
