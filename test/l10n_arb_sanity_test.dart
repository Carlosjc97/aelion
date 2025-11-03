import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final arbDir = Directory('lib/l10n');
  final files = arbDir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.arb'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  final placeholderPattern = RegExp(r'\{([a-zA-Z0-9_]+)\}');

  for (final file in files) {
    test('ARB sanity: ${file.uri.pathSegments.last}', () {
      final bytes = file.readAsBytesSync();
      final decoded = utf8.decode(bytes, allowMalformed: false);

      final invalidControls = decoded.runes.where((code) {
        if (code == 0x0A || code == 0x0D || code == 0x09) {
          return false;
        }
        return code < 0x20;
      }).toList();
      expect(
        invalidControls,
        isEmpty,
        reason:
            'File ${file.path} contains control characters: $invalidControls',
      );

      final data = jsonDecode(decoded) as Map<String, dynamic>;
      data.forEach((key, value) {
        if (key.startsWith('@')) {
          return;
        }
        if (value is! String) {
          return;
        }

        final openCount = _countOccurrences(value, '{');
        final closeCount = _countOccurrences(value, '}');
        expect(
          openCount,
          closeCount,
          reason:
              'Mismatched placeholder braces in "$key" within ${file.path}',
        );

        final matches = placeholderPattern
            .allMatches(value)
            .map((match) => match.group(1)!)
            .toSet();
        final metaKey = '@$key';
        final metadata = data[metaKey];

        if (matches.isEmpty) {
          if (metadata is Map && metadata['placeholders'] is Map) {
            final metaPlaceholders =
                (metadata['placeholders'] as Map).keys.toSet();
            expect(
              metaPlaceholders,
              isEmpty,
              reason:
                  'Metadata placeholders declared for "$key" but none used in string.',
            );
          }
          return;
        }

        expect(
          metadata,
          isA<Map<String, dynamic>>(),
          reason: 'Missing metadata for key "$key" in ${file.path}',
        );

        final placeholderMap =
            Map<String, dynamic>.from((metadata as Map)['placeholders'] ?? {});
        final placeholderNames = placeholderMap.keys.toSet();

        expect(
          placeholderNames,
          containsAll(matches),
          reason:
              'Metadata placeholders missing entries for "$key" in ${file.path}',
        );
        expect(
          matches,
          containsAll(placeholderNames),
          reason:
              'Placeholder metadata defines unused names for "$key" in ${file.path}',
        );
      });
    });
  }
}

int _countOccurrences(String input, String needle) {
  var count = 0;
  var index = 0;
  while (true) {
    index = input.indexOf(needle, index);
    if (index == -1) {
      break;
    }
    count++;
    index += needle.length;
  }
  return count;
}
