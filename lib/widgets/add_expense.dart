import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/utils/constants.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Category _selectedCategory = Category.food;

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: now,
    );

    setState(() {
      _selectedDate = pickedDate ?? _selectedDate;
    });
  }

  void _submitExpenseData() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Create expense object
      final expense = Expense(
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        category: _selectedCategory,
      );

      // Add expense through provider (handles Firebase sync)
      await context.read<ExpenseProvider>().addExpense(expense);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense saved successfully!')),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving expense: $e')),
        );
      }
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Expense'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppConstants.defaultPadding,
          AppConstants.defaultPadding,
          AppConstants.defaultPadding,
          MediaQuery.of(context).viewInsets.bottom + AppConstants.defaultPadding,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: AppConstants.defaultPadding),
              TextFormField(
                controller: _titleController,
                maxLength: AppConstants.maxTitleLength,
                decoration: const InputDecoration(
                  label: Text('Title'),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text('Amount'),
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount < AppConstants.minAmount) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat(AppConstants.dateFormat).format(_selectedDate),
                        ),
                        IconButton(
                          onPressed: _presentDatePicker,
                          icon: const Icon(
                            Icons.calendar_month,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Row(
                children: [
                  DropdownButton(
                    value: _selectedCategory,
                    items: Category.values
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Icon(
                                  category.icon,
                                  color: category.color,
                                ),
                                const SizedBox(width: 8),
                                Text(category.name.toUpperCase()),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submitExpenseData,
                    child: const Text('Save Expense'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}