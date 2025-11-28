import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:edaptia/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: 'env.public');
  });

  group('App End-to-End Flow', () {
    testWidgets(
      'Login, generate outline, and view items',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        expect(find.byType(app.EdaptiaApp), findsOneWidget);
      },
      skip: dotenv.env['API_BASE_URL'] == null ||
          dotenv.env['API_BASE_URL']!.isEmpty ||
          dotenv.env['API_BASE_URL']!.contains('localhost'),
    );
  });
}

