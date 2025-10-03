import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expenses_list/expense_item.dart';


class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key, 
    required this.expenses,
    required this.onRemoveExpense,
  });

  final List<Expense> expenses;
  final void Function(Expense expense) onRemoveExpense;

  @override
  Widget build(BuildContext context) {

    if (expenses.isEmpty) {
      return const Center(
        child: Text('No expenses found'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: expenses.length,
      itemBuilder: (ctx, index) {
        final expense = expenses[index];
        return Dismissible(
          key: ValueKey(expense.id),
          onDismissed: (direction) {
            onRemoveExpense(expense);
          },
          background: Container(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.25),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.error,
              size: 30,
            ),
          ),
          child: ExpenseItem(expense),
        );
      },
    );
  }
}   
