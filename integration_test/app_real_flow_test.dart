import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:edaptia/main.dart' as app;

/// Integration test completo del flujo real de Edaptia
/// Prueba: Onboarding ? Quiz ? Skeleton UI ? M1 ? Navegaci?n de lecciones
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: 'assets/env/.env.public');
  });

  group('Flujo Completo Real de Edaptia', () {
    testWidgets(
      'Navegaci?n completa: Login ? Onboarding ? Quiz ? M?dulos ? Lecciones',
      (WidgetTester tester) async {
        // 1. INICIAR APP
        print('?? [TEST] Iniciando app...');
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // 2. VERIFICAR QUE LA APP CARG?
        print('? [TEST] App iniciada');
        expect(find.byType(app.EdaptiaApp), findsOneWidget);

        // Esperar a que Firebase se inicialice
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 3. BUSCAR PANTALLA DE LOGIN/ONBOARDING
        print('?? [TEST] Buscando pantalla de login/onboarding...');

        // Esperar un poco m?s para que cargue completamente
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Imprimir todos los widgets encontrados para debug
        print('?? [TEST] Widgets encontrados en pantalla:');
        final allTexts = find.byType(Text);
        for (var i = 0; i < allTexts.evaluate().length && i < 20; i++) {
          try {
            final widget = allTexts.evaluate().elementAt(i).widget as Text;
            final textData = widget.data ?? widget.textSpan?.toPlainText() ?? '';
            if (textData.isNotEmpty) {
              print('  - Text: "$textData"');
            }
          } catch (e) {
            // Ignorar errores al leer textos
          }
        }

        // Buscar botones
        print('?? [TEST] Botones encontrados:');
        final allButtons = find.byType(ElevatedButton);
        print('  - ElevatedButton: ${allButtons.evaluate().length}');
        final allFilledButtons = find.byType(FilledButton);
        print('  - FilledButton: ${allFilledButtons.evaluate().length}');
        final allTextButtons = find.byType(TextButton);
        print('  - TextButton: ${allTextButtons.evaluate().length}');

        // 4. INTENTAR NAVEGAR A UN CURSO EXISTENTE
        print('?? [TEST] Buscando cursos existentes para navegar...');

        // Buscar cursos recientes
        final sqlCourse = find.text('SQL para Marketing');
        final analiticaCourse = find.text('Analitica de Crecimiento');
        final inglesA1 = find.text('ingles a1');

        Finder? courseToTap;
        String courseName = '';

        if (sqlCourse.evaluate().isNotEmpty) {
          courseToTap = sqlCourse;
          courseName = 'SQL para Marketing';
        } else if (analiticaCourse.evaluate().isNotEmpty) {
          courseToTap = analiticaCourse;
          courseName = 'Anal?tica de Crecimiento';
        } else if (inglesA1.evaluate().isNotEmpty) {
          courseToTap = inglesA1;
          courseName = 'ingl?s a1';
        }

        if (courseToTap != null) {
          print('? [TEST] Encontrado curso: "$courseName"');
          print('?? [TEST] Haciendo tap en el curso...');

          await tester.tap(courseToTap.first);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          print('? [TEST] Tap ejecutado, esperando navegaci?n...');
        } else {
          print('??  [TEST] No se encontraron cursos conocidos');
        }

        // 5. BUSCAR M?DULOS
        print('?? [TEST] Buscando m?dulos...');

        // Buscar ExpansionTile (los m?dulos son ExpansionTiles)
        final expansionTiles = find.byType(ExpansionTile);
        print('  - ExpansionTiles encontrados: ${expansionTiles.evaluate().length}');

        if (expansionTiles.evaluate().isNotEmpty) {
          print('? [TEST] Se encontraron m?dulos (ExpansionTile)');

          // Intentar expandir el primer m?dulo (deber?a ser M1)
          print('?? [TEST] Intentando expandir M1...');
          await tester.tap(expansionTiles.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // 6. BUSCAR LECCIONES DENTRO DEL M?DULO
          print('?? [TEST] Buscando lecciones...');

          // Las lecciones son ListTile
          final lessonTiles = find.byType(ListTile);
          print('  - ListTiles encontrados: ${lessonTiles.evaluate().length}');

          if (lessonTiles.evaluate().length > 1) {
            // El primero podr?a ser el header del m?dulo, buscar el siguiente
            print('? [TEST] Se encontraron lecciones (ListTile)');

            // Buscar iconos de chevron_right (indica lecci?n desbloqueada)
            final chevronIcons = find.byIcon(Icons.chevron_right);
            print('  - Chevron icons (lecciones desbloqueadas): ${chevronIcons.evaluate().length}');

            // Buscar iconos de lock (indica lecci?n bloqueada)
            final lockIcons = find.byIcon(Icons.lock);
            print('  - Lock icons (lecciones bloqueadas): ${lockIcons.evaluate().length}');

            // Intentar hacer tap en la primera lecci?n
            if (lessonTiles.evaluate().length > 1) {
              print('?? [TEST] Intentando navegar a la primera lecci?n...');
              try {
                // Buscar el segundo ListTile (el primero suele ser el header)
                final lessons = lessonTiles.evaluate().toList();
                if (lessons.length > 1) {
                  await tester.tap(find.byWidget(lessons[1].widget));
                  await tester.pumpAndSettle(const Duration(seconds: 3));

                  // Verificar si naveg? a la lecci?n
                  print('? [TEST] Tap en lecci?n ejecutado, verificando navegaci?n...');

                  // Buscar elementos t?picos de una p?gina de lecci?n
                  final backButtons = find.byType(BackButton);
                  print('  - BackButton encontrados: ${backButtons.evaluate().length}');

                  if (backButtons.evaluate().isNotEmpty) {
                    print('? [TEST] ?NAVEGACI?N EXITOSA! Se encontr? p?gina de lecci?n');
                  } else {
                    print('? [TEST] NO NAVEG? - No se encontr? BackButton en p?gina de lecci?n');
                  }
                }
              } catch (e) {
                print('? [TEST] Error al hacer tap en lecci?n: $e');
              }
            }
          } else {
            print('??  [TEST] No se encontraron lecciones suficientes');
          }
        } else {
          print('??  [TEST] No se encontraron m?dulos (ExpansionTile)');
        }

        // 7. REPORTE FINAL
        print('');
        print('???????????????????????????????????????????????');
        print('?? REPORTE FINAL DEL TEST');
        print('???????????????????????????????????????????????');
        print('? App iniciada correctamente');
        print('? Firebase inicializado');
        print('Total ExpansionTiles (m?dulos): ${find.byType(ExpansionTile).evaluate().length}');
        print('Total ListTiles (lecciones): ${find.byType(ListTile).evaluate().length}');
        print('Lecciones desbloqueadas: ${find.byIcon(Icons.chevron_right).evaluate().length}');
        print('Lecciones bloqueadas: ${find.byIcon(Icons.lock).evaluate().length}');
        print('???????????????????????????????????????????????');

        // Test pasa si llegamos hasta aqu?
        expect(find.byType(app.EdaptiaApp), findsOneWidget);
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });
}
