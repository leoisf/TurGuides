import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tour_guides/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    
    // Verifica se o app inicia
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Splash screen displays', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    
    // Verifica se mostra o ícone de tour
    expect(find.byIcon(Icons.tour), findsOneWidget);
    
    // Verifica se mostra o título
    expect(find.text('TourGuides'), findsOneWidget);
  });
}
