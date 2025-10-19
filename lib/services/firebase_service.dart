import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/utils/constants.dart';

class FirebaseService {
  static const String _baseUrl = AppConstants.firebaseBaseUrl;
  static const String _expensesEndpoint = AppConstants.expensesEndpoint;

  /// Fetch all expenses from Firebase
  static Future<List<Expense>> fetchExpenses() async {
    try {
      final url = Uri.https(_baseUrl, _expensesEndpoint);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);
        
        if (data == null) {
          return [];
        }

        final List<Expense> expenses = [];
        
        data.forEach((firebaseId, expenseData) {
          if (expenseData is Map<String, dynamic>) {
            try {
              final expense = Expense.fromFirebase(
                id: firebaseId,
                title: expenseData['title'] ?? '',
                amount: (expenseData['amount'] as num).toDouble(),
                date: DateTime.parse(expenseData['date'] ?? DateTime.now().toIso8601String()),
                category: Category.values.firstWhere(
                  (category) => category.name == expenseData['category'],
                  orElse: () => Category.food,
                ),
              );
              expenses.add(expense);
            } catch (e) {
              // Skip invalid expense data
              print('Error parsing expense: $e');
            }
          }
        });

        // Sort by date (newest first)
        expenses.sort((a, b) => b.date.compareTo(a.date));
        return expenses;
      } else {
        throw Exception('Failed to fetch expenses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while fetching expenses: $e');
    }
  }

  /// Add a new expense to Firebase
  static Future<String> addExpense(Expense expense) async {
    try {
      final url = Uri.https(_baseUrl, _expensesEndpoint);

      final expenseData = {
        'title': expense.title,
        'amount': expense.amount,
        'date': expense.date.toIso8601String(),
        'category': expense.category.name,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(expenseData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['name']; // Firebase returns generated ID as 'name'
      } else {
        throw Exception('Failed to add expense: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while adding expense: $e');
    }
  }

  /// Delete an expense from Firebase
  static Future<void> deleteExpense(String firebaseId) async {
    try {
      final url = Uri.https(_baseUrl, 'expenses/$firebaseId.json');

      final response = await http.delete(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete expense: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while deleting expense: $e');
    }
  }

  /// Check if an expense exists in Firebase by ID
  static Future<bool> expenseExists(String firebaseId) async {
    try {
      final url = Uri.https(_baseUrl, 'expenses/$firebaseId.json');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data != null;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
