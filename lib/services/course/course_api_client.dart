import 'dart:convert';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Shared HTTP client with retry/backoff policies for Edaptia course APIs.
class CourseApiClient {
  CourseApiClient._();

  static http.Client httpClient = http.Client();

  static const Duration defaultTimeout = Duration(seconds: 25);

  static Future<http.Response> get({
    required Uri uri,
    Duration timeout = defaultTimeout,
    int maxRetries = 1,
    Set<int> additionalSuccessCodes = const <int>{},
    Map<String, String>? headers,
  }) async {
    return _requestWithRetry(
      () async {
        final authHeaders = await _buildAuthHeaders();
        final mergedHeaders = {
          'Accept': 'application/json',
          ...authHeaders,
          if (headers != null) ...headers,
        };
        return httpClient.get(uri, headers: mergedHeaders);
      },
      uri: uri,
      timeout: timeout,
      maxRetries: maxRetries,
      additionalSuccessCodes: additionalSuccessCodes,
    );
  }

  static Future<http.Response> postJson({
    required Uri uri,
    required Map<String, dynamic> body,
    Duration timeout = defaultTimeout,
    int maxRetries = 1,
    Set<int> additionalSuccessCodes = const <int>{},
    Map<String, String>? headers,
  }) async {
    final payload = jsonEncode(body);
    return _requestWithRetry(
      () async {
        final authHeaders = await _buildAuthHeaders();
        final mergedHeaders = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...authHeaders,
          if (headers != null) ...headers,
        };
        return httpClient.post(uri, headers: mergedHeaders, body: payload);
      },
      uri: uri,
      timeout: timeout,
      maxRetries: maxRetries,
      additionalSuccessCodes: additionalSuccessCodes,
    );
  }

  static Future<http.Response> _requestWithRetry(
    Future<http.Response> Function() requestFn, {
    required Uri uri,
    required Duration timeout,
    required int maxRetries,
    required Set<int> additionalSuccessCodes,
  }) async {
    int attempt = 0;
    Object? lastError;
    while (attempt <= maxRetries) {
      try {
        final response = await requestFn().timeout(timeout);
        final status = response.statusCode;
        if ((status >= 200 && status < 300) ||
            additionalSuccessCodes.contains(status)) {
          return response;
        }

        if (status == 429 || (status >= 500 && status < 600)) {
          attempt++;
          if (attempt > maxRetries) {
            _throwWithDetails(uri, response);
          }
          await Future.delayed(Duration(milliseconds: _backoffWithJitterMs(attempt)));
          continue;
        }

        _throwWithDetails(uri, response);
      } catch (error) {
        lastError = error;
        attempt++;
        if (attempt > maxRetries) {
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: _backoffWithJitterMs(attempt)));
      }
    }

    throw Exception('Request to ${uri.path} failed. Last error: $lastError');
  }

  static Future<Map<String, String>> _buildAuthHeaders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      return {
        if (idToken != null) 'Authorization': 'Bearer $idToken',
        if (user != null) 'X-User-Id': user.uid,
      };
    } catch (_) {
      return const {};
    }
  }

  static void _throwWithDetails(Uri uri, http.Response response) {
    final detail = response.body.isNotEmpty ? response.body : 'No details';
    throw Exception(
      'Request to ${uri.path} failed (${response.statusCode}): $detail',
    );
  }

  static int _backoffWithJitterMs(int attempt) {
    const base = 400;
    const cap = 3000;
    final expo = base * math.pow(2, attempt - 1).toInt();
    final jitter = math.Random().nextInt(250);
    return math.min(cap, expo + jitter);
  }
}
