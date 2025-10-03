import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_tracker/models/expense.dart';

class ExpensesSummary extends StatelessWidget {
  const ExpensesSummary({
    super.key,
    required this.expenses,
  });

  final List<Expense> expenses;

  double get _totalExpenses {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<Category, double> get _categoryTotals {
    final Map<Category, double> totals = {};
    
    for (final expense in expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    
    return totals;
  }

  List<BarChartGroupData> get _barChartGroups {
    final categoryTotals = _categoryTotals;
    final totalAmount = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    
    if (totalAmount == 0) {
      return [];
    }

    return categoryTotals.entries.map((entry) {
      final category = entry.key;
      final amount = entry.value;
      
      return BarChartGroupData(
        x: category.index,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: category.color,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Header with total expenses
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 32,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Expenses',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${_totalExpenses.toStringAsFixed(2)}',
                      style: textTheme.headlineMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Expense count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${expenses.length}',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Bar chart with icons
          if (expenses.isNotEmpty) ...[
            SizedBox(
              height: 140,
              child: BarChart(
                BarChartData(
                  barGroups: _barChartGroups,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 80,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < Category.values.length) {
                            final category = Category.values[value.toInt()];
                            final categoryTotals = _categoryTotals;
                            final amount = categoryTotals[category] ?? 0.0;
                            
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  category.icon,
                                  color: category.color,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  category.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: category.color,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '\$${amount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: category.color,
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colorScheme.outline.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                ),
              ),
            ),
          ] else ...[
            // Empty state
            Column(
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  size: 48,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'No expenses to display',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
