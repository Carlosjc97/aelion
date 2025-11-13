import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edaptia/services/api_config.dart';

void main() {
  test('release URLs are absolute and secure', () {
    expect(kReleaseMode, isA<bool>()); // evita warning por import.
    final urls = [
      ApiConfig.outline(),
      ApiConfig.quiz(),
      ApiConfig.placementQuizStart(),
      ApiConfig.placementQuizGrade(),
      ApiConfig.trackSearch(),
      ApiConfig.trending('es'),
    ];
    for (final u in urls) {
      expect(
        u.startsWith('https://us-central1-aelion-c90d2.cloudfunctions.net'),
        true,
      );
      expect(u.contains('http://'), false);
      expect(u.contains('localhost'), false);
    }
  });
}

