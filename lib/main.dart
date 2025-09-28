import 'package:flutter/material.dart';
import 'package:expense_tracker/widgets/expenses.dart';

void main() {
  runApp(MaterialApp(
    title: 'Expense Tracker',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF10B981), // Emerald
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF0FDF4), // Light green background
    ),
    darkTheme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF34D399), // Emerald 400
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF064E3B), // Dark emerald background
    ),
    themeMode: ThemeMode.system,
    home: const Expenses(),
  ));
}

