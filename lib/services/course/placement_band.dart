enum PlacementBand { basic, intermediate, advanced }

const Map<String, PlacementBand> _bandLookup = {
  'basic': PlacementBand.basic,
  'beginner': PlacementBand.basic,  // Alias for backward compatibility
  'intermediate': PlacementBand.intermediate,
  'advanced': PlacementBand.advanced,
};

const Map<PlacementBand, String> _bandToDepth = {
  PlacementBand.basic: 'intro',
  PlacementBand.intermediate: 'medium',
  PlacementBand.advanced: 'deep',
};

const Map<String, PlacementBand> _depthToBand = {
  'intro': PlacementBand.basic,
  'medium': PlacementBand.intermediate,
  'deep': PlacementBand.advanced,
};

PlacementBand placementBandFromString(String raw) {
  final normalized = raw.trim().toLowerCase();
  return _bandLookup[normalized] ?? PlacementBand.basic;
}

String placementBandToString(PlacementBand band) {
  switch (band) {
    case PlacementBand.basic:
      return 'basic';
    case PlacementBand.intermediate:
      return 'intermediate';
    case PlacementBand.advanced:
      return 'advanced';
  }
}

String depthForBand(PlacementBand band) => _bandToDepth[band] ?? 'intro';

PlacementBand bandForDepth(String depth) =>
    _depthToBand[depth] ?? PlacementBand.basic;

PlacementBand placementBandForScore(num score) {
  final normalized = score.isFinite ? score.toInt().clamp(0, 100) : 0;
  if (normalized >= 80) {
    return PlacementBand.advanced;
  }
  if (normalized >= 50) {
    return PlacementBand.intermediate;
  }
  return PlacementBand.basic;
}

PlacementBand? tryPlacementBandFromString(String? raw) {
  if (raw == null) {
    return null;
  }
  final normalized = raw.trim().toLowerCase();
  return _bandLookup[normalized];
}
