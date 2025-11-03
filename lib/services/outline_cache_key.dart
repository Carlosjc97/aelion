String buildOutlineCacheId({
  required String topic,
  required String language,
  String? band,
  String? depth,
}) {
  final normalizedTopic = topic.trim().toLowerCase();
  final normalizedLanguage = language.trim().toLowerCase();
  final normalizedVariant =
      (band ?? depth ?? '').trim().toLowerCase();
  return '$normalizedTopic|$normalizedVariant|$normalizedLanguage';
}

