import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddExpense extends StatefulWidget {
  const AddExpense({super.key, required this.onAddExpense});

  final void Function(Expense expense, String? firebaseId) onAddExpense;

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
      return; // Exit if validation fails
    }
    
    // Date is always set to current date by default, so no need to check for null

    try {
      final url = Uri.https(
        'flutter-aaad7-default-rtdb.firebaseio.com',
        'expenses.json',
      );

      final expenseData = {
        'title': _titleController.text.trim(),
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'date': _selectedDate.toIso8601String(),
        'category': _selectedCategory.name,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(expenseData),
      );

      if (response.statusCode == 200) {
        // Success - show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense saved successfully!')),
        );
        
        // Get Firebase ID from response
        final responseData = json.decode(response.body);
        final firebaseId = responseData['name']; // Firebase returns generated ID as 'name'
        
        // Save the expense locally as well using Firebase ID
        widget.onAddExpense(
          Expense.fromFirebase(
            id: firebaseId,
            title: _titleController.text.trim(),
            amount: double.parse(_amountController.text),
            date: _selectedDate,
            category: _selectedCategory,
          ),
          firebaseId,
        );
      } else {
        // Error - show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving expense: ${response.statusCode}')),
        );
        
        // Save locally without Firebase ID on error
        widget.onAddExpense(
          Expense(
            title: _titleController.text.trim(),
            amount: double.parse(_amountController.text),
            date: _selectedDate,
            category: _selectedCategory,
          ),
          null,
        );
      }
    } catch (e) {
      // Network or other error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving expense: $e')),
      );
      
      // Save locally without Firebase ID on error
      widget.onAddExpense(
        Expense(
          title: _titleController.text.trim(),
          amount: double.parse(_amountController.text),
          date: _selectedDate,
          category: _selectedCategory,
        ),
        null,
      );
    }
    
    Navigator.pop(context);
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
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                maxLength: 50,
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
              const SizedBox(height: 16),
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
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                  ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      formatter.format(_selectedDate),
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
          const SizedBox(height: 16),
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

final formatter = DateFormat('dd/MM/yyyy');