// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/providers/theme_provider.dart';

void main() {
  testWidgets('Expense tracker app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const ExpenseTrackerApp(),
      ),
    );

    // Verify that the app loads with the main title
    expect(find.text('Expense Tracker'), findsOneWidget);
    
    // Verify that the add button is present
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
