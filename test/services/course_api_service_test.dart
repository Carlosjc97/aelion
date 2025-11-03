import 'package:edaptia/services/course_api_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CourseApiService.tryPlacementBandFromString', () {
    test('returns null for unknown bands', () {
      expect(CourseApiService.tryPlacementBandFromString('unknown'), isNull);
    });

    test('parses known bands case-insensitively', () {
      expect(CourseApiService.tryPlacementBandFromString('Beginner'), PlacementBand.beginner);
      expect(CourseApiService.tryPlacementBandFromString('INTERMEDIATE'), PlacementBand.intermediate);
      expect(CourseApiService.tryPlacementBandFromString('advanced'), PlacementBand.advanced);
    });
  });
}


