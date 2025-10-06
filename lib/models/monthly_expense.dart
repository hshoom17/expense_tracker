import 'package:intl/intl.dart';

class MonthlyExpense {
  MonthlyExpense({
    required this.month,
    required this.year,
    required this.totalAmount,
    required this.expenseCount,
    required this.categoryTotals,
  });

  final int month;
  final int year;
  final double totalAmount;
  final int expenseCount;
  final Map<String, double> categoryTotals; // category name -> amount

  String get monthName {
    return DateFormat('MMMM').format(DateTime(year, month));
  }

  String get yearMonth {
    return DateFormat('MMM y').format(DateTime(year, month));
  }

  String get fullDate {
    return DateFormat('MMMM y').format(DateTime(year, month));
  }

  // Convert to/from Map for SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'year': year,
      'totalAmount': totalAmount,
      'expenseCount': expenseCount,
      'categoryTotals': categoryTotals,
    };
  }

  factory MonthlyExpense.fromMap(Map<String, dynamic> map) {
    return MonthlyExpense(
      month: map['month'] ?? 0,
      year: map['year'] ?? 0,
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      expenseCount: map['expenseCount'] ?? 0,
      categoryTotals: Map<String, double>.from(map['categoryTotals'] ?? {}),
    );
  }

  // Create a copy with updated values
  MonthlyExpense copyWith({
    int? month,
    int? year,
    double? totalAmount,
    int? expenseCount,
    Map<String, double>? categoryTotals,
  }) {
    return MonthlyExpense(
      month: month ?? this.month,
      year: year ?? this.year,
      totalAmount: totalAmount ?? this.totalAmount,
      expenseCount: expenseCount ?? this.expenseCount,
      categoryTotals: categoryTotals ?? this.categoryTotals,
    );
  }
}
