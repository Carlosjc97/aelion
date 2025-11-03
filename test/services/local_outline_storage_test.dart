import 'dart:convert';

import 'package:edaptia/services/local_outline_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists and reads the last outline payload', () async {
    final storage = LocalOutlineStorage.instance;
    final payload = <String, dynamic>{
      'outline': [
        {'title': 'Module 1', 'lessons': []},
      ],
      'source': 'fresh',
      'cacheExpiresAt': DateTime.now().millisecondsSinceEpoch,
    };

    await storage.save(topic: 'Dart', payload: payload);
    final stored = await storage.read();

    expect(stored, isNotNull);
    expect(stored!.topic, 'Dart');
    expect(stored.source, 'fresh');
    expect(stored.outline, hasLength(1));
    expect(stored.outline.first['title'], 'Module 1');
  });

  test('ignores invalid payloads without outline list', () async {
    final storage = LocalOutlineStorage.instance;
    await storage.save(topic: 'Invalid', payload: {'source': 'fresh'});
    final stored = await storage.read();
    expect(stored, isNull);
  });

  test('stores multiple outlines and keeps recent first', () async {
    final storage = LocalOutlineStorage.instance;
    for (var i = 0; i < 3; i++) {
      final payload = <String, dynamic>{
        'outline': [
          {'title': 'Module $i', 'lessons': []},
        ],
        'source': 'fresh',
        'band': i == 0 ? 'beginner' : 'intermediate',
        'cacheExpiresAt': DateTime.now().millisecondsSinceEpoch,
      };
      await storage.save(topic: 'Topic $i', payload: payload);
    }

    final all = await storage.readAll();
    expect(all, hasLength(3));
    expect(all.first.topic, 'Topic 2');
    expect(all.last.topic, 'Topic 0');
  });

  test('compresses history payload and prunes heavy fields', () async {
    final storage = LocalOutlineStorage.instance;
    final largeText = List<String>.filled(4000, 'x').join();
    final payload = <String, dynamic>{
      'outline': [
        {
          'title': 'Module',
          'lessons': [
            {'title': 'Lesson', 'body': largeText},
          ],
        },
      ],
      'source': 'fresh',
      'rawOutline': largeText,
    };

    await storage.save(topic: 'Heavy', payload: payload);

    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString('outlineHistory.v1');

    expect(historyString, isNotNull);
    expect(historyString!.startsWith('gz:'), isTrue);

    final stored = await storage.read();
    expect(stored, isNotNull);
    expect(stored!.rawResponse.containsKey('rawOutline'), isFalse);
  });

  test('drops outlines older than retention window', () async {
    final storage = LocalOutlineStorage.instance;
    final prefs = await SharedPreferences.getInstance();
    final oldPayload = <String, dynamic>{
      'outline': [
        {'title': 'Old module', 'lessons': []},
      ],
      'source': 'cache',
    };

    final oldEntry = <String, dynamic>{
      'topic': 'Legacy',
      'savedAt': DateTime.now()
          .subtract(const Duration(days: 60))
          .toIso8601String(),
      'source': 'cache',
      'payload': oldPayload,
    };

    prefs.setString('outlineHistory.v1', jsonEncode([oldEntry]));

    await storage.save(
      topic: 'Fresh',
      payload: <String, dynamic>{
        'outline': [
          {'title': 'New module', 'lessons': []},
        ],
        'source': 'fresh',
      },
    );

    final all = await storage.readAll();
    expect(all.any((outline) => outline.topic == 'Legacy'), isFalse);
  });

  test('deduplicates outlines by topic and band', () async {
    final storage = LocalOutlineStorage.instance;
    final payload = <String, dynamic>{
      'outline': [
        {'title': 'Module'},
      ],
      'source': 'fresh',
      'band': 'beginner',
    };

    await storage.save(topic: 'Dart', payload: payload);
    await storage.save(topic: 'Dart', payload: payload);

    final all = await storage.readAll();
    expect(all, hasLength(1));
  });
}

