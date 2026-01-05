

import 'dart:math';

class WalletLogic {

  static double getTotalDeposits(List<Map<String, dynamic>> transactions) {
    return transactions
        .where((t) => t['type'] == 'deposit')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));
  }

  static double getTotalWithdrawals(List<Map<String, dynamic>> transactions) {
    return transactions
        .where((t) => t['type'] == 'withdrawal')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));
  }

  static int getTransactionCount(List<Map<String, dynamic>> transactions) {
    return transactions.length;
  }

  static bool canWithdraw(double currentBalance, double amount) {
    return currentBalance >= amount && amount > 0;
  }

  static bool isValidAmount(double amount) {
    return amount > 0 && amount <= 1000000; 
  }

  static String formatBalance(double amount) {
    return amount.toStringAsFixed(2);
  }

  static String? validateDeposit(double amount, String method) {
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (amount > 1000000) {
      return 'Maximum deposit amount is \$1,000,000';
    }
    if (method.isEmpty) {
      return 'Please select a payment method';
    }
    return null;
  }

  static String? validateWithdrawal(double amount, String method, double currentBalance) {
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (amount > currentBalance) {
      return 'Insufficient balance';
    }
    if (amount > 5000) {
      return 'Maximum withdrawal amount is \$5,000 per transaction';
    }
    if (method.isEmpty) {
      return 'Please select a withdrawal method';
    }
    return null;
  }

  static List<Map<String, dynamic>> filterByDateRange(
    List<Map<String, dynamic>> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    return transactions.where((transaction) {
      final dateStr = transaction['date'] as String;
      final parts = dateStr.split('-');
      if (parts.length != 3) return false;
      
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final transactionDate = DateTime(year, month, day);
      
      return transactionDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             transactionDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  static List<Map<String, dynamic>> filterByType(
    List<Map<String, dynamic>> transactions,
    String type,
  ) {
    return transactions.where((t) => t['type'] == type).toList();
  }

  static List<Map<String, dynamic>> filterByMethod(
    List<Map<String, dynamic>> transactions,
    String method,
  ) {
    return transactions.where((t) => t['method'] == method).toList();
  }

  
  static List<Map<String, dynamic>> sortByDate(
    List<Map<String, dynamic>> transactions,
    {bool ascending = false}
  ) {
    final sorted = List<Map<String, dynamic>>.from(transactions);
    sorted.sort((a, b) {
      final dateA = _parseDate(a['date'] as String);
      final dateB = _parseDate(b['date'] as String);
      final timeA = _parseTime(a['time'] as String);
      final timeB = _parseTime(b['time'] as String);
      
      final dateTimeA = DateTime(dateA.year, dateA.month, dateA.day, timeA.hour, timeA.minute);
      final dateTimeB = DateTime(dateB.year, dateB.month, dateB.day, timeB.hour, timeB.minute);
      
      return ascending
          ? dateTimeA.compareTo(dateTimeB)
          : dateTimeB.compareTo(dateTimeA);
    });
    return sorted;
  }

  static List<Map<String, dynamic>> sortByAmount(
    List<Map<String, dynamic>> transactions,
    {bool ascending = false}
  ) {
    final sorted = List<Map<String, dynamic>>.from(transactions);
    sorted.sort((a, b) {
      final amountA = a['amount'] as double;
      final amountB = b['amount'] as double;
      return ascending
          ? amountA.compareTo(amountB)
          : amountB.compareTo(amountA);
    });
    return sorted;
  }

  static DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  static DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return DateTime(0, 0, 0, int.parse(parts[0]), int.parse(parts[1]));
  }
}
