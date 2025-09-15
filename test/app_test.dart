import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_ia/core/router.dart';
import 'package:learning_ia/features/home/home_view.dart';

void main() {
  testWidgets('boots and renders initial screen', (tester) async {
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: HomeView.routeName,
    ));

    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(HomeView), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
