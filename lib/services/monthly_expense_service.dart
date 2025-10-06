import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/monthly_expense.dart';
import 'dart:convert';

class MonthlyExpenseService {
  static const String _monthlyExpensesKey = 'monthly_expenses';

  // Calculate and save monthly totals from a list of expenses
  static Future<void> calculateAndSaveMonthlyTotals(List<Expense> expenses) async {
    try {
      // Group expenses by month/year
      final Map<String, List<Expense>> monthlyGroups = {};
      
      for (final expense in expenses) {
        final key = '${expense.date.year}-${expense.date.month}';
        monthlyGroups[key] = [...(monthlyGroups[key] ?? []), expense];
      }

      // Calculate totals for each month
      final List<MonthlyExpense> monthlyExpenses = [];
      
      for (final entry in monthlyGroups.entries) {
        final expenses = entry.value;
        final firstExpense = expenses.first;
        final month = firstExpense.date.month;
        final year = firstExpense.date.year;
        
        // Calculate totals
        final totalAmount = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
        final expenseCount = expenses.length;
        
        // Calculate category totals
        final Map<String, double> categoryTotals = {};
        for (final expense in expenses) {
          final categoryName = expense.category.name;
          categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0) + expense.amount;
        }

        monthlyExpenses.add(MonthlyExpense(
          month: month,
          year: year,
          totalAmount: totalAmount,
          expenseCount: expenseCount,
          categoryTotals: categoryTotals,
        ));
      }

      // Sort by year and month (newest first)
      monthlyExpenses.sort((a, b) {
        if (a.year != b.year) return b.year.compareTo(a.year);
        return b.month.compareTo(a.month);
      });

      // Save to SharedPreferences
      await _saveMonthlyExpenses(monthlyExpenses);
    } catch (e) {
      debugPrint('Error calculating monthly totals: $e');
    }
  }

  // Load monthly expenses from SharedPreferences
  static Future<List<MonthlyExpense>> loadMonthlyExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final monthlyData = prefs.getStringList(_monthlyExpensesKey) ?? [];
      
      return monthlyData
          .map((json) => MonthlyExpense.fromMap(jsonDecode(json)))
          .toList();
    } catch (e) {
      debugPrint('Error loading monthly expenses: $e');
      return [];
    }
  }

  // Save monthly expenses to SharedPreferences
  static Future<void> _saveMonthlyExpenses(List<MonthlyExpense> monthlyExpenses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final monthlyData = monthlyExpenses
          .map((expense) => jsonEncode(expense.toMap()))
          .toList();
      
      await prefs.setStringList(_monthlyExpensesKey, monthlyData);
    } catch (e) {
      debugPrint('Error saving monthly expenses: $e');
    }
  }

  // Clear all monthly expenses
  static Future<void> clearMonthlyExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_monthlyExpensesKey);
    } catch (e) {
      debugPrint('Error clearing monthly expenses: $e');
    }
  }

  // Get monthly expense for a specific month/year
  static Future<MonthlyExpense?> getMonthlyExpense(int year, int month) async {
    try {
      final monthlyExpenses = await loadMonthlyExpenses();
      try {
        return monthlyExpenses.firstWhere(
          (expense) => expense.year == year && expense.month == month,
        );
      } catch (e) {
        return null;
      }
    } catch (e) {
      debugPrint('Error getting monthly expense: $e');
      return null;
    }
  }
}
