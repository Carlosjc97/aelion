import 'package:flutter_test/flutter_test.dart';
import 'package:edaptia/l10n/app_localizations_en.dart';
import 'package:edaptia/l10n/app_localizations_es.dart';

void main() {
  test('i18n keys exist (smoke)', () {
    final en = AppLocalizationsEn();
    final es = AppLocalizationsEs();
    expect(en.takePlacementQuiz.isNotEmpty, true);
    expect(es.takePlacementQuiz.isNotEmpty, true);
    expect(es.depthMedium, 'intermedia');
  });
}

