import 'package:edaptia/services/course_api_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CourseApiService.placementBandForScore', () {
    test('returns beginner for scores between 0 and 49', () {
      expect(CourseApiService.placementBandForScore(-5), PlacementBand.beginner);
      expect(CourseApiService.placementBandForScore(0), PlacementBand.beginner);
      expect(CourseApiService.placementBandForScore(49), PlacementBand.beginner);
    });

    test('returns intermediate for scores between 50 and 79', () {
      expect(CourseApiService.placementBandForScore(50), PlacementBand.intermediate);
      expect(CourseApiService.placementBandForScore(68), PlacementBand.intermediate);
      expect(CourseApiService.placementBandForScore(79), PlacementBand.intermediate);
    });

    test('returns advanced for scores between 80 and 100', () {
      expect(CourseApiService.placementBandForScore(80), PlacementBand.advanced);
      expect(CourseApiService.placementBandForScore(94), PlacementBand.advanced);
      expect(CourseApiService.placementBandForScore(150), PlacementBand.advanced);
    });
  });

  group('CourseApiService band depth mapping', () {
    test('maps bands to default depths', () {
      expect(CourseApiService.depthForBand(PlacementBand.beginner), 'intro');
      expect(CourseApiService.depthForBand(PlacementBand.intermediate), 'medium');
      expect(CourseApiService.depthForBand(PlacementBand.advanced), 'deep');
    });

    test('maps depths back to bands', () {
      expect(CourseApiService.bandForDepth('intro'), PlacementBand.beginner);
      expect(CourseApiService.bandForDepth('medium'), PlacementBand.intermediate);
      expect(CourseApiService.bandForDepth('deep'), PlacementBand.advanced);
    });
  });
}

