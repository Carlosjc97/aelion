import 'package:aelion/services/recent_outlines_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  RecentOutlineMetadata entry(int index) {
    final topic = 'Topic $index';
    final language = index.isEven ? 'en' : 'es';
    final band = index % 3 == 0 ? 'beginner' : index % 3 == 1 ? 'intermediate' : 'advanced';
    final depth = index % 2 == 0 ? 'intro' : 'medium';
    final id = RecentOutlineMetadata.buildId(
      topic: topic,
      language: language,
      band: band,
      depth: depth,
    );
    return RecentOutlineMetadata(
      id: id,
      topic: topic,
      language: language,
      band: band,
      depth: depth,
      savedAt: DateTime(2024, 1, index + 1),
    );
  }

  test('upsert removes duplicates and promotes the most recent entry', () async {
    final storage = RecentOutlinesStorage.instance;
    final first = entry(0);
    final second = entry(1);

    await storage.upsert(first);
    await storage.upsert(second);

    var all = await storage.readAll();
    expect(all, hasLength(2));
    expect(all.first.id, second.id);

    final updatedFirst = first.copyWith(savedAt: DateTime(2024, 2, 1));
    await storage.upsert(updatedFirst);

    all = await storage.readAll();
    expect(all, hasLength(2));
    expect(all.first.id, updatedFirst.id);
    expect(all.first.savedAt, updatedFirst.savedAt);
  });

  test('upsert maintains only the 35 most recent entries', () async {
    final storage = RecentOutlinesStorage.instance;

    for (var i = 0; i < 40; i++) {
      await storage.upsert(entry(i));
    }

    final all = await storage.readAll();
    expect(all, hasLength(35));
    final ids = all.map((entry) => entry.id).toList(growable: false);

    // The earliest inserted entries should have been evicted.
    expect(ids.contains(entry(0).id), isFalse);
    expect(ids.contains(entry(1).id), isFalse);
    expect(ids.contains(entry(4).id), isFalse);

    // The most recent entry should be at the top.
    expect(all.first.id, entry(39).id);
  });
}
