enum PlacementBand { beginner, intermediate, advanced }

const Map<String, PlacementBand> _bandLookup = {
  'beginner': PlacementBand.beginner,
  'intermediate': PlacementBand.intermediate,
  'advanced': PlacementBand.advanced,
};

const Map<PlacementBand, String> _bandToDepth = {
  PlacementBand.beginner: 'intro',
  PlacementBand.intermediate: 'medium',
  PlacementBand.advanced: 'deep',
};

const Map<String, PlacementBand> _depthToBand = {
  'intro': PlacementBand.beginner,
  'medium': PlacementBand.intermediate,
  'deep': PlacementBand.advanced,
};

PlacementBand placementBandFromString(String raw) {
  final normalized = raw.trim().toLowerCase();
  return _bandLookup[normalized] ?? PlacementBand.beginner;
}

String placementBandToString(PlacementBand band) {
  switch (band) {
    case PlacementBand.beginner:
      return 'beginner';
    case PlacementBand.intermediate:
      return 'intermediate';
    case PlacementBand.advanced:
      return 'advanced';
  }
}

String depthForBand(PlacementBand band) => _bandToDepth[band] ?? 'intro';

PlacementBand bandForDepth(String depth) =>
    _depthToBand[depth] ?? PlacementBand.beginner;

PlacementBand placementBandForScore(num score) {
  final normalized = score.isFinite ? score.toInt().clamp(0, 100) : 0;
  if (normalized >= 80) {
    return PlacementBand.advanced;
  }
  if (normalized >= 50) {
    return PlacementBand.intermediate;
  }
  return PlacementBand.beginner;
}

PlacementBand? tryPlacementBandFromString(String? raw) {
  if (raw == null) {
    return null;
  }
  final normalized = raw.trim().toLowerCase();
  return _bandLookup[normalized];
}
