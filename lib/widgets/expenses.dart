import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/theme_provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/widgets/add_expense.dart';
import 'package:expense_tracker/widgets/expenses_summary.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  @override
  void initState() {
    super.initState();
    // Initialize expenses from Firebase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().initializeExpenses();
    });
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => AddExpense(),
    );
  }

  void _removeExpense(Expense expense) {
    final expenseProvider = context.read<ExpenseProvider>();
    final isFromFirebase = expenseProvider.isFirebaseExpense(expense);
    final expenseIndex = expenseProvider.expenses.indexOf(expense);
    
    // Remove the expense
    expenseProvider.removeExpense(expense);
    
    // Show SnackBar with undo functionality (only for local expenses)
    if (!isFromFirebase) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${expense.title} deleted'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              expenseProvider.addExpenseBack(expense, expenseIndex);
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

  void _clearAllExpenses() {
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
              context.read<ExpenseProvider>().clearAllExpenses();
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
          Consumer<ExpenseProvider>(
            builder: (context, expenseProvider, child) {
              return IconButton(
                icon: Icon(expenseProvider.isLoading ? Icons.refresh : Icons.refresh),
                onPressed: expenseProvider.isLoading ? null : () => expenseProvider.fetchExpenses(),
                tooltip: 'Refresh Expenses',
              );
            },
          ),
          Consumer<ExpenseProvider>(
            builder: (context, expenseProvider, child) {
              return expenseProvider.hasExpenses
                  ? IconButton(
                      icon: const Icon(Icons.delete_forever),
                      onPressed: _clearAllExpenses,
                      tooltip: 'Clear All Expenses',
                    )
                  : const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openAddExpenseOverlay,
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          // Show error if any
          if (expenseProvider.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(expenseProvider.error!),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }

          // Show loading indicator only when loading and no expenses
          if (expenseProvider.isLoading && !expenseProvider.hasExpenses) {
            return const Center(child: CircularProgressIndicator());
          }

          // Main content
          return width < 600 
              ? Column(
                  children: [
                    ExpensesSummary(expenses: expenseProvider.expenses),
                    Expanded(
                      child: ExpensesList(
                        expenses: expenseProvider.expenses,
                        onRemoveExpense: _removeExpense,
                      ),
                    ),
                  ],
                ) 
              : Row(
                  children: [
                    Expanded(
                      child: ExpensesSummary(expenses: expenseProvider.expenses),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ExpensesList(
                        expenses: expenseProvider.expenses,
                        onRemoveExpense: _removeExpense,
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}