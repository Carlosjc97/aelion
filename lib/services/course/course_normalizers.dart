const Set<String> _supportedDepths = {'intro', 'medium', 'deep'};
const Set<String> _supportedQuizLanguages = {'en', 'es'};

String normalizeLanguage(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return 'en';
  }
  return trimmed;
}

String normalizeDepth(String raw) {
  final normalized = raw.trim().toLowerCase();
  if (_supportedDepths.contains(normalized)) {
    return normalized;
  }
  throw ArgumentError(
    'Invalid depth "$raw". Supported values: ${_supportedDepths.join(', ')}.',
  );
}

String normalizePlacementLanguage(String raw) {
  final normalized = raw.trim().toLowerCase();
  if (_supportedQuizLanguages.contains(normalized)) {
    return normalized;
  }
  return 'en';
}
