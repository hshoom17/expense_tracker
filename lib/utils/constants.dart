class AppConstants {
  // Firebase Configuration
  static const String firebaseBaseUrl = 'flutter-aaad7-default-rtdb.firebaseio.com';
  static const String expensesEndpoint = 'expenses.json';
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String displayDateFormat = 'd MMM y';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double chartHeight = 140.0;
  
  // Animation Durations
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration snackBarShortDuration = Duration(seconds: 2);
  
  // Validation Limits
  static const int maxTitleLength = 50;
  static const double minAmount = 0.01;
  
  // Chart Constants
  static const double barWidth = 20.0;
  static const double horizontalInterval = 20.0;
}
