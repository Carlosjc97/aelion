import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aelion/services/recent_search_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('caps recent searches per user at 35 entries', () async {
    final storage = RecentSearchStorage.instance;

    for (var i = 0; i < 40; i++) {
      await storage.add(
        userId: 'user-1',
        topic: 'topic $i',
        language: 'en',
      );
    }

    final entries = await storage.readForUser('user-1');
    expect(entries.length, 35);
    expect(entries.first.topic, 'topic 39');
    expect(entries.last.topic, 'topic 5');
  });

  test('reinserted topic promotes entry and dedupes case-insensitively',
      () async {
    final storage = RecentSearchStorage.instance;

    await storage.add(
      userId: 'user-2',
      topic: 'Machine Learning',
      language: 'en',
    );

    await storage.add(
      userId: 'user-2',
      topic: '  machine learning  ',
      language: 'es',
    );

    final entries = await storage.readForUser('user-2');
    expect(entries.length, 1);
    expect(entries.first.topic, 'machine learning');
  });
}
