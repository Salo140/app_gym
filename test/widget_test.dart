// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:proyecto_pm/main.dart';

void main() {
  testWidgets('muestra rutinas y alterna el tema', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('TRACKWELL'), findsOneWidget);
    expect(find.text('Strength'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);

    final MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);

    await tester.tap(find.byTooltip('Cambiar tema'));
    await tester.pump();

    final MaterialApp updatedApp =
        tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(updatedApp.themeMode, ThemeMode.light);
  });

  testWidgets('no desborda en un ancho movil', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Cambiar tema'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
