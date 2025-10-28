import 'dart:convert';

import 'package:aelion/services/course_api_service.dart';
import 'package:aelion/services/topic_band_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('setBand and getBand persist placement band', () async {
    final cache = TopicBandCache.instance;
    const userId = 'user-1';
    const topic = 'flutter';
    const language = 'en';

    await cache.setBand(
      userId: userId,
      topic: topic,
      language: language,
      band: PlacementBand.intermediate,
    );

    final stored = await cache.getBand(
      userId: userId,
      topic: topic,
      language: language,
    );

    expect(stored, PlacementBand.intermediate);
    final hasStored = await cache.hasBand(
      userId: userId,
      topic: topic,
      language: language,
    );
    expect(hasStored, isTrue);
  });

  test('getBand expires entries after ttl window', () async {
    final cache = TopicBandCache.instance;
    const userId = 'user-1';
    const topic = 'dart';
    const language = 'es';

    final prefs = await SharedPreferences.getInstance();
    final expiredEntry = {
      'user-1|dart|es': {
        'band': 'beginner',
        'savedAt': DateTime.now()
            .subtract(const Duration(days: 40))
            .toIso8601String(),
      },
    };
    await prefs.setString('topicBandCache.v1', jsonEncode(expiredEntry));

    final stored = await cache.getBand(
      userId: userId,
      topic: topic,
      language: language,
    );

    expect(stored, isNull);
    final hasStored = await cache.hasBand(
      userId: userId,
      topic: topic,
      language: language,
    );
    expect(hasStored, isFalse);
  });
}
