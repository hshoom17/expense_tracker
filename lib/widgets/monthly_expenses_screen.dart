import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/monthly_expense.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/monthly_expense_service.dart';
import 'package:expense_tracker/widgets/expenses_list/expense_item.dart';

class MonthlyExpensesScreen extends StatefulWidget {
  const MonthlyExpensesScreen({super.key});

  @override
  State<MonthlyExpensesScreen> createState() => _MonthlyExpensesScreenState();
}

class _MonthlyExpensesScreenState extends State<MonthlyExpensesScreen> {
  // State variables
  List<MonthlyExpense> _monthlyExpenses = [];
  List<Expense> _allExpenses = [];
  bool _isLoading = true;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _loadMonthlyExpenses();
    _loadAllExpenses();
  }

  // Data loading methods
  Future<void> _loadMonthlyExpenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _monthlyExpenses = await MonthlyExpenseService.loadMonthlyExpenses();
    } catch (e) {
      debugPrint('Error loading monthly expenses: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAllExpenses() async {
    // For now, we'll use the same fake data as the main screen
    // In a real app, you'd load this from a database or service
    _allExpenses = [
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
  }

  // Helper methods
  String _getFormattedDate() {
    try {
      return DateFormat('MMMM y').format(DateTime(_selectedYear, _selectedMonth));
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return 'Invalid Date';
    }
  }

  // Computed properties
  List<MonthlyExpense> get _filteredExpenses {
    try {
      return _monthlyExpenses.where((expense) {
        return expense.year == _selectedYear && expense.month == _selectedMonth;
      }).toList();
    } catch (e) {
      debugPrint('Error filtering monthly expenses: $e');
      return [];
    }
  }

  MonthlyExpense? get _currentMonthExpense {
    final filtered = _filteredExpenses;
    return filtered.isNotEmpty ? filtered.first : null;
  }

  List<Expense> get _selectedMonthExpenses {
    try {
      return _allExpenses.where((expense) {
        return expense.date.year == _selectedYear && expense.date.month == _selectedMonth;
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date, newest first
    } catch (e) {
      debugPrint('Error filtering expenses: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: _buildAppBar(colorScheme),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildMonthYearSelector(colorScheme, textTheme),
                _buildMonthlySummary(colorScheme, textTheme),
                Expanded(child: _buildSelectedMonthExpenses(colorScheme, textTheme)),
              ],
            ),
    );
  }

  // UI Building methods
  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      title: const Text('Monthly Expenses'),
      backgroundColor: colorScheme.inversePrimary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back to main expenses screen',
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadMonthlyExpenses,
          tooltip: 'Refresh monthly data and recalculate totals',
        ),
      ],
    );
  }

  Widget _buildMonthYearSelector(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Tooltip(
                  message: 'Select year to view expenses',
                  child: DropdownButton<int>(
                    value: _selectedYear,
                    isExpanded: true,
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year - index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text('$year'),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null && value > 0) {
                        setState(() {
                          _selectedYear = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Tooltip(
                  message: 'Select month to view expenses',
                  child: DropdownButton<int>(
                    value: _selectedMonth,
                    isExpanded: true,
                    items: List.generate(12, (index) {
                      final month = index + 1;
                      return DropdownMenuItem(
                        value: month,
                        child: Text(DateFormat('MMMM').format(DateTime(2024, month))),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null && value >= 1 && value <= 12) {
                        setState(() {
                          _selectedMonth = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Selected: ${_getFormattedDate()}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${_selectedMonthExpenses.length} expenses',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary(ColorScheme colorScheme, TextTheme textTheme) {
    if (_currentMonthExpense != null) {
      return _buildMonthlySummaryCard(_currentMonthExpense!, colorScheme, textTheme);
    } else {
      return _buildEmptyState(colorScheme, textTheme);
    }
  }

  Widget _buildMonthlySummaryCard(MonthlyExpense expense, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.fullDate,
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${expense.expenseCount} expenses',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '\$${expense.totalAmount.toStringAsFixed(2)}',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          if (expense.categoryTotals.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Category Breakdown',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            ...expense.categoryTotals.entries.map((entry) {
              final category = Category.values.firstWhere(
                (cat) => cat.name == entry.key,
                orElse: () => Category.food,
              );
              final amount = entry.value;
              final percentage = (amount / expense.totalAmount * 100).round();
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      category.icon,
                      color: category.color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category.name.toUpperCase(),
                        style: textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '\$${amount.toStringAsFixed(2)}',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$percentage%',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today,
            size: 48,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses for ${_getFormattedDate()}',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Add some expenses to see monthly summaries',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedMonthExpenses(ColorScheme colorScheme, TextTheme textTheme) {
    final selectedExpenses = _selectedMonthExpenses;

    if (selectedExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses for ${_getFormattedDate()}',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some expenses to see them here',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
            Text(
              'Expenses for ${_getFormattedDate()}',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${selectedExpenses.length} items',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Expenses List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: selectedExpenses.length,
            itemBuilder: (context, index) {
              final expense = selectedExpenses[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ExpenseItem(expense),
              );
            },
          ),
        ),
      ],
    );
  }
}
