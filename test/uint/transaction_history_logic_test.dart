import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2/logic/transaction_history_logic.dart';

void main() {
  group('TransactionHistoryLogic Tests', () {
    late List<Map<String, dynamic>> sampleTransactions;
    late TransactionHistoryLogic logic;

    setUp(() {
      sampleTransactions = [
        {
          'id': 'TXN001',
          'type': 'deposit',
          'amount': 200.00,
          'date': '2025-12-01',
          'time': '17:19',
          'method': 'Credit Card',
          'icon': 'credit_card',
          'color': 'green',
          'status': 'Completed',
        },
        {
          'id': 'TXN002',
          'type': 'withdrawal',
          'amount': 100.00,
          'date': '2025-12-01',
          'time': '14:30',
          'method': 'Cash',
          'icon': 'money',
          'color': 'red',
          'status': 'Completed',
        },
        {
          'id': 'TXN003',
          'type': 'deposit',
          'amount': 500.00,
          'date': '2025-11-28',
          'time': '11:45',
          'method': 'Click',
          'icon': 'wallet',
          'color': 'green',
          'status': 'Processing',
        },
        {
          'id': 'TXN004',
          'type': 'withdrawal',
          'amount': 50.00,
          'date': '2025-11-25',
          'time': '09:15',
          'method': 'Bank Transfer',
          'icon': 'account_balance',
          'color': 'red',
          'status': 'Failed',
        },
      ];

      logic = TransactionHistoryLogic(transactions: sampleTransactions);
    });

    test('Initializes with correct values', () {
      expect(logic.transactions, sampleTransactions);
      expect(logic.filter, 'All');
    });

    test('Initializes with custom filter', () {
      final customLogic = TransactionHistoryLogic(
        transactions: sampleTransactions,
        filter: 'Deposits',
      );
      expect(customLogic.filter, 'Deposits');
    });

    test('filteredTransactions returns all when filter is All', () {
      expect(logic.filteredTransactions.length, 4);
    });

    test('filteredTransactions returns only deposits', () {
      logic.setFilter('Deposits');
      expect(logic.filteredTransactions.length, 2);
      expect(logic.filteredTransactions.every((t) => t['type'] == 'deposit'), true);
    });

    test('filteredTransactions returns only withdrawals', () {
      logic.setFilter('Withdrawals');
      expect(logic.filteredTransactions.length, 2);
      expect(logic.filteredTransactions.every((t) => t['type'] == 'withdrawal'), true);
    });

    test('isFilterActive returns correct value', () {
      expect(logic.isFilterActive('All'), true);
      expect(logic.isFilterActive('Deposits'), false);
      
      logic.setFilter('Deposits');
      expect(logic.isFilterActive('Deposits'), true);
      expect(logic.isFilterActive('All'), false);
    });

    test('totalDeposits calculates correctly', () {
      expect(logic.totalDeposits, 700.00);
    });

    test('totalWithdrawals calculates correctly', () {
      expect(logic.totalWithdrawals, 150.00);
    });

    test('currentBalance calculates correctly', () {
      expect(logic.currentBalance, 550.00);
    });

    test('transactionCount returns correct count', () {
      expect(logic.transactionCount, 4);
    });

    test('filteredTransactionCount returns correct count', () {
      expect(logic.filteredTransactionCount, 4);
      
      logic.setFilter('Deposits');
      expect(logic.filteredTransactionCount, 2);
      
      logic.setFilter('Withdrawals');
      expect(logic.filteredTransactionCount, 2);
    });

    test('filterDisplayName returns correct name', () {
      expect(logic.filterDisplayName, 'All Transactions');
      
      logic.setFilter('Deposits');
      expect(logic.filterDisplayName, 'All Deposits');
      
      logic.setFilter('Withdrawals');
      expect(logic.filterDisplayName, 'All Withdrawals');
    });

    test('dailyStats calculates correctly', () {
      final stats = logic.dailyStats;
      expect(stats['highestDailyDeposit'], 500.00);
      expect(stats['highestDailyWithdrawal'], 100.00);
    });

    test('monthlyStats calculates correctly', () {
      final stats = logic.monthlyStats;
      expect(stats.containsKey('2025-12_deposit'), true);
      expect(stats.containsKey('2025-11_deposit'), true);
      expect(stats.containsKey('2025-12_withdrawal'), true);
      expect(stats.containsKey('2025-11_withdrawal'), true);
    });

    test('getSummary returns correct summary', () {
      final summary = logic.getSummary();
      expect(summary['totalTransactions'], 4);
      expect(summary['totalDeposits'], 700.00);
      expect(summary['totalWithdrawals'], 150.00);
      expect(summary['currentBalance'], 550.00);
    });

    test('getTransactionsByMethod returns correct transactions', () {
      final creditCardTransactions = logic.getTransactionsByMethod('Credit Card');
      expect(creditCardTransactions.length, 1);
      expect(creditCardTransactions[0]['id'], 'TXN001');
    });

    test('getTransactionsByStatus returns correct transactions', () {
      final completedTransactions = logic.getTransactionsByStatus('Completed');
      expect(completedTransactions.length, 2);
      
      final processingTransactions = logic.getTransactionsByStatus('Processing');
      expect(processingTransactions.length, 1);
    });

    
    test('sortByDate sorts descending by default', () {
      final sorted = logic.sortByDate();
      expect(sorted[0]['id'], 'TXN001');
      expect(sorted[3]['id'], 'TXN004');
    });

    test('sortByDate sorts ascending when specified', () {
      final sorted = logic.sortByDate(ascending: true);
      expect(sorted[0]['id'], 'TXN004');
      expect(sorted[3]['id'], 'TXN001');
    });

    test('sortByAmount sorts descending by default', () {
      final sorted = logic.sortByAmount();
      expect(sorted[0]['amount'], 500.00);
      expect(sorted[3]['amount'], 50.00);
    });

    test('sortByStatus sorts completed first by default', () {
      logic.setFilter('All');
      final sorted = logic.sortByStatus();
      expect(sorted[0]['status'], 'Completed');
      expect(sorted[1]['status'], 'Completed');
    });

    
    test('searchTransactions finds by ID', () {
      final results = logic.searchTransactions('TXN001');
      expect(results.length, 1);
      expect(results[0]['id'], 'TXN001');
    });

    test('searchTransactions finds by method', () {
      final results = logic.searchTransactions('Credit');
      expect(results.length, 1);
      expect(results[0]['method'], 'Credit Card');
    });

    test('searchTransactionsByAmount returns correct range', () {
      final results = logic.searchTransactionsByAmount(100, 300);
      expect(results.length, 2);
      expect(results.every((t) => t['amount'] >= 100 && t['amount'] <= 300), true);
    });

    
    test('getTransactionDetails returns correct transaction', () {
      final details = logic.getTransactionDetails('TXN001');
      expect(details['id'], 'TXN001');
      expect(details['amount'], 200.00);
    });

    test('getTransactionDetails returns empty for non-existent ID', () {
      final details = logic.getTransactionDetails('NONEXISTENT');
      expect(details.isEmpty, true);
    });

    test('getTransactionAmount returns correct amount', () {
      expect(logic.getTransactionAmount('TXN001'), 200.00);
      expect(logic.getTransactionAmount('NONEXISTENT'), 0.0);
    });

    test('getTransactionType returns correct type', () {
      expect(logic.getTransactionType('TXN001'), 'deposit');
      expect(logic.getTransactionType('TXN002'), 'withdrawal');
    });

    test('getTransactionStatus returns correct status', () {
      expect(logic.getTransactionStatus('TXN001'), 'Completed');
      expect(logic.getTransactionStatus('TXN003'), 'Processing');
    });

    
    test('hasTransactions returns true when there are transactions', () {
      expect(logic.hasTransactions(), true);
    });

    test('hasTransactions returns false when empty', () {
      final emptyLogic = TransactionHistoryLogic(transactions: []);
      expect(emptyLogic.hasTransactions(), false);
    });

    test('hasFilteredTransactions returns correct value', () {
      expect(logic.hasFilteredTransactions(), true);
      
      logic.setFilter('Deposits');
      expect(logic.hasFilteredTransactions(), true);
      
      final emptyLogic = TransactionHistoryLogic(transactions: []);
      expect(emptyLogic.hasFilteredTransactions(), false);
    });

    test('isTransactionValid returns true for valid transaction', () {
      final validTransaction = {
        'id': 'TEST',
        'type': 'deposit',
        'amount': 100.0,
        'date': '2025-01-01',
        'time': '12:00',
        'method': 'Test',
        'status': 'Completed',
      };
      expect(logic.isTransactionValid(validTransaction), true);
    });

    test('isTransactionValid returns false for invalid transaction', () {
      final invalidTransaction = {
        'id': 'TEST',
        'type': 'deposit',
    
      };
      expect(logic.isTransactionValid(invalidTransaction), false);
    });

    test('validateTransaction returns empty list for valid transaction', () {
      final validTransaction = {
        'id': 'TEST',
        'type': 'deposit',
        'amount': 100.0,
        'date': '2025-01-01',
        'time': '12:00',
        'method': 'Test',
        'status': 'Completed',
      };
      expect(logic.validateTransaction(validTransaction).isEmpty, true);
    });

    test('validateTransaction returns errors for invalid transaction', () {
      final invalidTransaction = {
        'id': 'TEST',
        'type': 'invalid',
        'amount': -100,
      };
      final errors = logic.validateTransaction(invalidTransaction);
      expect(errors.length, greaterThan(0));
      expect(errors.contains('Amount must be greater than 0'), true);
      expect(errors.contains('Type must be deposit or withdrawal'), true);
    });

    test('formatBalance formats correctly', () {
      expect(logic.formatBalance(123.456), '123.46');
      expect(logic.formatBalance(100), '100.00');
    });

    test('formatAmount formats correctly', () {
      expect(logic.formatAmount(123.456), '123.46');
    });

    test('formatDate formats correctly', () {
      expect(logic.formatDate('2025-12-01'), '1/12/2025');
    });

    test('formatDateTime formats correctly', () {
      expect(logic.formatDateTime('2025-12-01', '17:19'), '1/12/2025 at 17:19');
    });

 
    test('getStatusColor returns correct color', () {
      expect(logic.getStatusColor('Completed'), Colors.green);
      expect(logic.getStatusColor('Processing'), Colors.orange);
      expect(logic.getStatusColor('Failed'), Colors.red);
      expect(logic.getStatusColor('Unknown'), Colors.grey);
    });

    test('getStatusIcon returns correct icon', () {
      expect(logic.getStatusIcon('Completed'), Icons.check_circle);
      expect(logic.getStatusIcon('Processing'), Icons.timelapse);
      expect(logic.getStatusIcon('Failed'), Icons.error);
    });

    test('getTypeColor returns correct color', () {
      expect(logic.getTypeColor('deposit'), Colors.green);
      expect(logic.getTypeColor('withdrawal'), Colors.red);
    });

    test('getTypeIcon returns correct icon', () {
      expect(logic.getTypeIcon('deposit'), Icons.add_circle);
      expect(logic.getTypeIcon('withdrawal'), Icons.remove_circle);
    });

    test('getTypeDisplayName returns correct name', () {
      expect(logic.getTypeDisplayName('deposit'), 'Wallet Recharge');
      expect(logic.getTypeDisplayName('withdrawal'), 'Cash Withdrawal');
    });

    test('exportToCSV returns correct format', () {
      final csv = logic.exportToCSV();
      expect(csv.length, 4);
      expect(csv[0].containsKey('Transaction ID'), true);
      expect(csv[0].containsKey('Date'), true);
      expect(csv[0].containsKey('Amount'), true);
    });

    
    test('Handles empty transactions list', () {
      final emptyLogic = TransactionHistoryLogic(transactions: []);
      
      expect(emptyLogic.totalDeposits, 0.0);
      expect(emptyLogic.totalWithdrawals, 0.0);
      expect(emptyLogic.currentBalance, 0.0);
      expect(emptyLogic.filteredTransactions.isEmpty, true);
      expect(emptyLogic.hasTransactions(), false);
    });

    test('Handles transactions with only deposits', () {
      final depositsOnly = [
        {'id': 'D1', 'type': 'deposit', 'amount': 100},
        {'id': 'D2', 'type': 'deposit', 'amount': 200},
      ];
      final logic = TransactionHistoryLogic(transactions: depositsOnly);
      
      expect(logic.totalDeposits, 300.0);
      expect(logic.totalWithdrawals, 0.0);
      expect(logic.currentBalance, 300.0);
    });

    test('Handles transactions with only withdrawals', () {
      final withdrawalsOnly = [
        {'id': 'W1', 'type': 'withdrawal', 'amount': 100},
        {'id': 'W2', 'type': 'withdrawal', 'amount': 200},
      ];
      final logic = TransactionHistoryLogic(transactions: withdrawalsOnly);
      
      expect(logic.totalDeposits, 0.0);
      expect(logic.totalWithdrawals, 300.0);
      expect(logic.currentBalance, -300.0);
    });
  });
}
