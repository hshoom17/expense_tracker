import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/firebase_service.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;
  final Set<String> _firebaseExpenseIds = {};

  // Getters
  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasExpenses => _expenses.isNotEmpty;
  
  double get totalExpenses {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<Category, double> get categoryTotals {
    final Map<Category, double> totals = {};
    for (final expense in _expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  /// Initialize expenses by fetching from Firebase
  Future<void> initializeExpenses() async {
    await fetchExpenses();
  }

  /// Fetch expenses from Firebase
  Future<void> fetchExpenses() async {
    _setLoading(true);
    _clearError();

    try {
      final fetchedExpenses = await FirebaseService.fetchExpenses();
      
      // Update local list with fetched expenses
      _expenses = fetchedExpenses;
      
      // Update Firebase IDs set
      _firebaseExpenseIds.clear();
      for (final expense in _expenses) {
        // If expense ID is from Firebase format, add to set
        if (expense.id.length > 20) { // Firebase IDs are typically longer
          _firebaseExpenseIds.add(expense.id);
        }
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch expenses: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new expense (both locally and to Firebase)
  Future<void> addExpense(Expense expense) async {
    try {
      // Add to Firebase first
      final firebaseId = await FirebaseService.addExpense(expense);
      
      // Create expense with Firebase ID
      final expenseWithId = Expense.fromFirebase(
        id: firebaseId,
        title: expense.title,
        amount: expense.amount,
        date: expense.date,
        category: expense.category,
      );
      
      // Add to local list
      _expenses.insert(0, expenseWithId); // Insert at beginning (newest first)
      _firebaseExpenseIds.add(firebaseId);
      
      _clearError();
      notifyListeners();
    } catch (e) {
      // If Firebase fails, add locally without Firebase ID
      _expenses.insert(0, expense);
      _setError('Saved locally. Firebase sync failed: $e');
      notifyListeners();
    }
  }

  /// Remove an expense
  void removeExpense(Expense expense) {
    final isFromFirebase = _firebaseExpenseIds.contains(expense.id);
    
    // Remove from local list
    _expenses.remove(expense);
    if (isFromFirebase) {
      _firebaseExpenseIds.remove(expense.id);
    }
    
    notifyListeners();
    
    // Delete from Firebase if it was a Firebase expense
    if (isFromFirebase) {
      FirebaseService.deleteExpense(expense.id).catchError((e) {
        _setError('Failed to delete from Firebase: $e');
      });
    }
  }

  /// Clear all expenses
  void clearAllExpenses() {
    _expenses.clear();
    _firebaseExpenseIds.clear();
    notifyListeners();
  }

  /// Add expense back (for undo functionality)
  void addExpenseBack(Expense expense, int originalIndex) {
    // Insert at the original position, but clamp to valid range
    final insertIndex = originalIndex.clamp(0, _expenses.length);
    _expenses.insert(insertIndex, expense);
    notifyListeners();
  }

  /// Check if an expense is from Firebase
  bool isFirebaseExpense(Expense expense) {
    return _firebaseExpenseIds.contains(expense.id);
  }

  /// Get expenses by category
  List<Expense> getExpensesByCategory(Category category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  /// Get recent expenses (last N days)
  List<Expense> getRecentExpenses(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _expenses.where((expense) => expense.date.isAfter(cutoffDate)).toList();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
