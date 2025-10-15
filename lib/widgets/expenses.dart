import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/theme_provider.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/widgets/add_expense.dart';
import 'package:expense_tracker/widgets/expenses_summary.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  bool _isLoading = false;
  final Set<String> _firebaseExpenseIds = {};

  final List<Expense> _registeredExpenses = [
    Expense(
      title: 'Flutter course',
      amount: 60.00,
      date: DateTime.now(),
      category: Category.work,
    ),
    Expense(
      title: 'Cinema',
      amount: 15.50,
      date: DateTime.now(),
      category: Category.leisure,
    ),
    Expense(
      title: 'Transport',
      amount: 10.00,
      date: DateTime.now(),
      category: Category.travel,
    ),
    Expense(
      title: 'Food',
      amount: 30.00,
      date: DateTime.now(),
      category: Category.food,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.https(
        'flutter-aaad7-default-rtdb.firebaseio.com',
        'expenses.json',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);
        
        if (data != null) {
          final List<Expense> firebaseExpenses = [];
          
          data.forEach((firebaseId, expenseData) {
            if (expenseData is Map<String, dynamic>) {
              // Check if expense already exists locally to avoid duplicates
              final existingExpense = _registeredExpenses.any((expense) => 
                expense.title == expenseData['title'] &&
                expense.amount == (expenseData['amount'] as num).toDouble() &&
                expense.date.toIso8601String() == expenseData['date']
              );
              
              if (!existingExpense) {
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
                firebaseExpenses.add(expense);
                _firebaseExpenseIds.add(firebaseId);
              }
            }
          });

          if (firebaseExpenses.isNotEmpty) {
            setState(() {
              _registeredExpenses.addAll(firebaseExpenses);
              // Sort by date (newest first)
              _registeredExpenses.sort((a, b) => b.date.compareTo(a.date));
            });
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching expenses: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching expenses: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteExpenseFromFirebase(String firebaseId) async {
    try {
      final url = Uri.https(
        'flutter-aaad7-default-rtdb.firebaseio.com',
        'expenses/$firebaseId.json',
      );

      final response = await http.delete(url);

      if (response.statusCode == 200) {
        _firebaseExpenseIds.remove(firebaseId);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting from Firebase: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting from Firebase: $e')),
        );
      }
    }
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => AddExpense(onAddExpense: _addExpense),
    );
  }

  void _addExpense(Expense expense, String? firebaseId) {
    setState(() {
      _registeredExpenses.add(expense);
      if (firebaseId != null) {
        _firebaseExpenseIds.add(firebaseId);
      }
    });
  }

  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    final isFromFirebase = _firebaseExpenseIds.contains(expense.id);
    
    setState(() {
      _registeredExpenses.remove(expense);
    });

    // Delete from Firebase if the expense came from Firebase
    if (isFromFirebase) {
      _deleteExpenseFromFirebase(expense.id);
    }
    
    // Show SnackBar with undo functionality (only for local expenses)
    if (!isFromFirebase) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${expense.title} deleted'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              _addExpenseBack(expense, expenseIndex);
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${expense.title} deleted'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _addExpenseBack(Expense expense, int originalIndex) {
    setState(() {
      // Insert at the original position, but clamp to valid range
      final insertIndex = originalIndex.clamp(0, _registeredExpenses.length);
      _registeredExpenses.insert(insertIndex, expense);
    });
  }

  void _clearAllExpenses() {
    if (_registeredExpenses.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Expenses'),
        content: const Text('Are you sure you want to delete all expenses? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _registeredExpenses.clear();
              });
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All expenses cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: colorScheme.inversePrimary,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              );
            },
          ),
          IconButton(
            icon: Icon(_isLoading ? Icons.refresh : Icons.refresh),
            onPressed: _isLoading ? null : _fetchExpenses,
            tooltip: 'Refresh Expenses',
          ),
          if (_registeredExpenses.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _clearAllExpenses,
              tooltip: 'Clear All Expenses',
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openAddExpenseOverlay,
          ),
        ],
      ),
      body: _isLoading && _registeredExpenses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : width < 600 
              ? Column(
                  children: [
                    // Integrated Expenses Summary with Chart
                    ExpensesSummary(expenses: _registeredExpenses),
                    Expanded(
                      child: ExpensesList(
                        expenses: _registeredExpenses,
                        onRemoveExpense: _removeExpense,
                      ),
                    ),
                  ],
                ) 
              : Row(
                  children: [
                    Expanded(
                      child: ExpensesSummary(expenses: _registeredExpenses),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ExpensesList(
                        expenses: _registeredExpenses,
                        onRemoveExpense: _removeExpense,
                      ),
                    ),
                  ],
                ),
    );
  }
}