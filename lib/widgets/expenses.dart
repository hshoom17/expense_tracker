// Main Expenses Screen - Displays all expenses with summary and navigation
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/theme_provider.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/widgets/add_expense.dart';
import 'package:expense_tracker/widgets/expenses_summary.dart';
import 'package:expense_tracker/widgets/monthly_expenses_screen.dart';
import 'package:expense_tracker/services/monthly_expense_service.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  // State variables
  bool _isInitialized = false;
  
  // Sample data for demonstration
  final List<Expense> _registeredExpenses = [
    // Current month expenses
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
    Expense(
      title: 'Coffee',
      amount: 5.50,
      date: DateTime.now().subtract(const Duration(days: 2)),
      category: Category.food,
    ),
    Expense(
      title: 'Bus ticket',
      amount: 3.20,
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: Category.travel,
    ),
    
    // Last month expenses
    Expense(
      title: 'Grocery shopping',
      amount: 85.30,
      date: DateTime(DateTime.now().year, DateTime.now().month - 1, 15),
      category: Category.food,
    ),
    Expense(
      title: 'Movie tickets',
      amount: 25.00,
      date: DateTime(DateTime.now().year, DateTime.now().month - 1, 20),
      category: Category.leisure,
    ),
    Expense(
      title: 'Gas',
      amount: 45.00,
      date: DateTime(DateTime.now().year, DateTime.now().month - 1, 10),
      category: Category.travel,
    ),
    Expense(
      title: 'Office supplies',
      amount: 32.50,
      date: DateTime(DateTime.now().year, DateTime.now().month - 1, 5),
      category: Category.work,
    ),
    Expense(
      title: 'Restaurant',
      amount: 28.75,
      date: DateTime(DateTime.now().year, DateTime.now().month - 1, 25),
      category: Category.food,
    ),
    Expense(
      title: 'Flight ticket',
      amount: 150.00,
      date: DateTime(DateTime.now().year, DateTime.now().month - 1, 12),
      category: Category.travel,
    ),
    
    // Two months ago expenses
    Expense(
      title: 'Online course',
      amount: 99.99,
      date: DateTime(DateTime.now().year, DateTime.now().month - 2, 8),
      category: Category.work,
    ),
    Expense(
      title: 'Gym membership',
      amount: 40.00,
      date: DateTime(DateTime.now().year, DateTime.now().month - 2, 1),
      category: Category.leisure,
    ),
    Expense(
      title: 'Uber rides',
      amount: 35.60,
      date: DateTime(DateTime.now().year, DateTime.now().month - 2, 15),
      category: Category.travel,
    ),
    Expense(
      title: 'Takeout',
      amount: 22.40,
      date: DateTime(DateTime.now().year, DateTime.now().month - 2, 20),
      category: Category.food,
    ),
    Expense(
      title: 'Concert tickets',
      amount: 75.00,
      date: DateTime(DateTime.now().year, DateTime.now().month - 2, 18),
      category: Category.leisure,
    ),
    
    // Three months ago expenses
    Expense(
      title: 'Software license',
      amount: 120.00,
      date: DateTime(DateTime.now().year, DateTime.now().month - 3, 3),
      category: Category.work,
    ),
    Expense(
      title: 'Weekend trip',
      amount: 200.00,
      date: DateTime(DateTime.now().year, DateTime.now().month - 3, 10),
      category: Category.travel,
    ),
    Expense(
      title: 'Dinner out',
      amount: 45.80,
      date: DateTime(DateTime.now().year, DateTime.now().month - 3, 22),
      category: Category.food,
    ),
    Expense(
      title: 'Netflix subscription',
      amount: 15.99,
      date: DateTime(DateTime.now().year, DateTime.now().month - 3, 1),
      category: Category.leisure,
    ),
  ];

  // Lifecycle methods
  @override
  void initState() {
    super.initState();
    _initializeMonthlyData();
  }

  // Initialization methods
  void _initializeMonthlyData() async {
    if (!_isInitialized) {
      // Calculate and save monthly totals for the fake data
      await MonthlyExpenseService.calculateAndSaveMonthlyTotals(_registeredExpenses);
      _isInitialized = true;
    }
  }

  // UI Action methods
  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => AddExpense(onAddExpense: _addExpense),
    );
  }

  // Expense management methods
  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
    });
    
    // Calculate and save monthly totals
    MonthlyExpenseService.calculateAndSaveMonthlyTotals(_registeredExpenses);
  }

  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.remove(expense);
    });

    
    
    // Show SnackBar with undo functionality
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
  }

  void _addExpenseBack(Expense expense, int originalIndex) {
    setState(() {
      // Insert at the original position, but clamp to valid range
      final insertIndex = originalIndex.clamp(0, _registeredExpenses.length);
      _registeredExpenses.insert(insertIndex, expense);
    });
    
    // Recalculate monthly totals
    MonthlyExpenseService.calculateAndSaveMonthlyTotals(_registeredExpenses);
  }

  // Clear all expenses with confirmation
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
              // Clear monthly expenses when all expenses are cleared
              MonthlyExpenseService.clearMonthlyExpenses();
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

  // UI Build method
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
          if (_registeredExpenses.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _clearAllExpenses,
              tooltip: 'Clear All Expenses',
            ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MonthlyExpensesScreen(),
                ),
              );
            },
            tooltip: 'View monthly expenses summary and individual expenses by month',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openAddExpenseOverlay,
            tooltip: 'Add new expense',
          ),
        ],
      ),
      body: 
      width < 600 ? Column(
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