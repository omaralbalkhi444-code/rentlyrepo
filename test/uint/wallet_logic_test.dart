import 'package:flutter_test/flutter_test.dart';
import 'package:p2/logic/wallet_logic.dart';

void main() {
  group('WalletLogic Unit Tests', () {
    final sampleTransactions = [
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
        'status': 'Completed',
      },
    ];

  
    test('getTotalDeposits calculates correctly', () {
      expect(WalletLogic.getTotalDeposits(sampleTransactions), 700.00);
    });

    test('getTotalWithdrawals calculates correctly', () {
      expect(WalletLogic.getTotalWithdrawals(sampleTransactions), 100.00);
    });

    test('getAverageDeposit calculates correctly', () {
      expect(WalletLogic.getAverageDeposit(sampleTransactions), 350.00);
    });

    test('getTransactionCount returns correct count', () {
      expect(WalletLogic.getTransactionCount(sampleTransactions), 3);
    });

    test('calculateNewBalance for deposit', () {
      expect(WalletLogic.calculateNewBalance(1000, 200, true), 1200);
    });

    test('calculateNewBalance for withdrawal', () {
      expect(WalletLogic.calculateNewBalance(1000, 200, false), 800);
    });

    test('canWithdraw returns true for sufficient balance', () {
      expect(WalletLogic.canWithdraw(1000, 500), true);
    });

    test('canWithdraw returns false for insufficient balance', () {
      expect(WalletLogic.canWithdraw(100, 500), false);
    });

    test('canWithdraw returns false for zero amount', () {
      expect(WalletLogic.canWithdraw(1000, 0), false);
    });

    test('isValidAmount returns true for valid amount', () {
      expect(WalletLogic.isValidAmount(100), true);
      expect(WalletLogic.isValidAmount(0.01), true);
      expect(WalletLogic.isValidAmount(1000000), true);
    });

    test('isValidAmount returns false for invalid amount', () {
      expect(WalletLogic.isValidAmount(0), false);
      expect(WalletLogic.isValidAmount(-100), false);
      expect(WalletLogic.isValidAmount(1000001), false);
    });

    test('formatBalance formats correctly', () {
      expect(WalletLogic.formatBalance(100), '100.00');
      expect(WalletLogic.formatBalance(100.5), '100.50');
      expect(WalletLogic.formatBalance(100.123), '100.12');
    });

   
    test('createTransaction generates correct deposit', () {
      final transaction = WalletLogic.createTransaction(
        type: 'deposit',
        amount: 300,
        method: 'Credit Card',
      );

      expect(transaction['type'], 'deposit');
      expect(transaction['amount'], 300);
      expect(transaction['method'], 'Credit Card');
      expect(transaction['color'], 'green');
      expect(transaction['status'], 'Completed');
      expect(transaction['id'], isNotNull);
    });

    test('createTransaction generates correct withdrawal', () {
      final transaction = WalletLogic.createTransaction(
        type: 'withdrawal',
        amount: 200,
        method: 'Cash',
      );

      expect(transaction['type'], 'withdrawal');
      expect(transaction['amount'], 200);
      expect(transaction['method'], 'Cash');
      expect(transaction['color'], 'red');
      expect(transaction['status'], 'Completed');
    });

    test('generateTransactionId generates valid ID', () {
      final id = WalletLogic.generateTransactionId();
      expect(id, startsWith('TXN'));
      expect(id.length, greaterThan(3));
    });

    test('addTransaction adds new transaction', () {
      final newTransaction = {
        'id': 'TXN004',
        'type': 'deposit',
        'amount': 400.00,
      };

      final updated = WalletLogic.addTransaction(sampleTransactions, newTransaction);
      
      expect(updated.length, 4);
      expect(updated[0]['id'], 'TXN004');
      expect(updated[0]['amount'], 400.00);
    });

    test('validateDeposit returns null for valid deposit', () {
      expect(WalletLogic.validateDeposit(100, 'Credit Card'), isNull);
    });

    test('validateDeposit returns error for zero amount', () {
      expect(WalletLogic.validateDeposit(0, 'Credit Card'), 'Amount must be greater than 0');
    });

    test('validateDeposit returns error for negative amount', () {
      expect(WalletLogic.validateDeposit(-100, 'Credit Card'), 'Amount must be greater than 0');
    });

    test('validateDeposit returns error for large amount', () {
      expect(WalletLogic.validateDeposit(1000001, 'Credit Card'), 'Maximum deposit amount is \$1,000,000');
    });

    test('validateDeposit returns error for empty method', () {
      expect(WalletLogic.validateDeposit(100, ''), 'Please select a payment method');
    });

    test('validateWithdrawal returns null for valid withdrawal', () {
      expect(WalletLogic.validateWithdrawal(100, 'Cash', 500), isNull);
    });

    test('validateWithdrawal returns error for insufficient balance', () {
      expect(WalletLogic.validateWithdrawal(600, 'Cash', 500), 'Insufficient balance');
    });

    test('validateWithdrawal returns error for large amount', () {
      expect(WalletLogic.validateWithdrawal(6000, 'Cash', 10000), 'Maximum withdrawal amount is \$5,000 per transaction');
    });

    test('validateWithdrawal returns error for empty method', () {
      expect(WalletLogic.validateWithdrawal(100, '', 500), 'Please select a withdrawal method');
    });

  
    test('getDailyStats calculates correctly', () {
      final stats = WalletLogic.getDailyStats(sampleTransactions);
      expect(stats['todayDeposits'], 500.00);
      expect(stats['todayWithdrawals'], 100.00);
    });

    test('getMonthlyStats calculates correctly', () {
      
      final stats = WalletLogic.getMonthlyStats(sampleTransactions);
      expect(stats, isNotNull);
      expect(stats['monthlyDeposit'], isA<double>());
      expect(stats['monthlyWithdrawal'], isA<double>());
    });

    
    test('filterByType returns only deposits', () {
      final deposits = WalletLogic.filterByType(sampleTransactions, 'deposit');
      expect(deposits.length, 2);
      expect(deposits.every((t) => t['type'] == 'deposit'), true);
    });

    test('filterByType returns only withdrawals', () {
      final withdrawals = WalletLogic.filterByType(sampleTransactions, 'withdrawal');
      expect(withdrawals.length, 1);
      expect(withdrawals.every((t) => t['type'] == 'withdrawal'), true);
    });

    test('filterByMethod returns correct transactions', () {
      final creditCard = WalletLogic.filterByMethod(sampleTransactions, 'Credit Card');
      expect(creditCard.length, 1);
      expect(creditCard[0]['method'], 'Credit Card');
    });

  
    test('sortByDate sorts descending by default', () {
      final sorted = WalletLogic.sortByDate(sampleTransactions);
      expect(sorted[0]['date'], '2025-12-01');
      expect(sorted[2]['date'], '2025-11-28');
    });

    test('sortByDate sorts ascending when specified', () {
      final sorted = WalletLogic.sortByDate(sampleTransactions, ascending: true);
      expect(sorted[0]['date'], '2025-11-28');
      expect(sorted[2]['date'], '2025-12-01');
    });

    test('sortByAmount sorts descending by default', () {
      final sorted = WalletLogic.sortByAmount(sampleTransactions);
      expect(sorted[0]['amount'], 500.00);
      expect(sorted[2]['amount'], 100.00);
    });

    test('sortByAmount sorts ascending when specified', () {
      final sorted = WalletLogic.sortByAmount(sampleTransactions, ascending: true);
      expect(sorted[0]['amount'], 100.00);
      expect(sorted[2]['amount'], 500.00);
    });

  
    test('Empty transactions list handling', () {
      expect(WalletLogic.getTotalDeposits([]), 0.0);
      expect(WalletLogic.getTotalWithdrawals([]), 0.0);
      expect(WalletLogic.getAverageDeposit([]), 0.0);
      expect(WalletLogic.getTransactionCount([]), 0);
    });

    test('Transaction with custom ID', () {
      final transaction = WalletLogic.createTransaction(
        type: 'deposit',
        amount: 300,
        method: 'Credit Card',
        customId: 'CUSTOM123',
      );

      expect(transaction['id'], 'CUSTOM123');
    });

    test('Icon mapping for deposit methods', () {
      expect(WalletLogic.createTransaction(type: 'deposit', amount: 100, method: 'Credit Card')['icon'], 'credit_card');
      expect(WalletLogic.createTransaction(type: 'deposit', amount: 100, method: 'Bank Transfer')['icon'], 'account_balance');
      expect(WalletLogic.createTransaction(type: 'deposit', amount: 100, method: 'Click')['icon'], 'touch_app');
    });

    test('Icon mapping for withdrawal methods', () {
      expect(WalletLogic.createTransaction(type: 'withdrawal', amount: 100, method: 'Cash')['icon'], 'money');
      expect(WalletLogic.createTransaction(type: 'withdrawal', amount: 100, method: 'Bank Transfer')['icon'], 'account_balance');
    });
  });
}
