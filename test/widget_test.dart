// Test básico para la aplicación Lytiks
//
// Para ejecutar los tests:
// flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lytiks/main.dart';

void main() {
  testWidgets('Lytiks app builds without errors', (WidgetTester tester) async {
    // Construir la app y renderizar un frame
    await tester.pumpWidget(const LytiksApp());
    
    // Dar tiempo para que se construya la primera pantalla
    await tester.pump();

    // Verificar que existe el MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Verificar que no hay excepciones durante la construcción
    expect(tester.takeException(), isNull);
  });

  testWidgets('App has correct title', (WidgetTester tester) async {
    // Construir la app
    await tester.pumpWidget(const LytiksApp());
    await tester.pump();

    // Verificar que el MaterialApp tiene el título correcto
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, 'Lytiks');
  });
}
