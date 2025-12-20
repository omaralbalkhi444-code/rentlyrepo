import 'package:flutter_test/flutter_test.dart';
import 'package:p2/logic/wallet_recharge_logic.dart';

void main() {
  group('WalletRechargeLogic Unit Tests', () {
    
    test('validateAmount returns null for valid amount', () {
      expect(WalletRechargeLogic.validateAmount('100'), isNull);
      expect(WalletRechargeLogic.validateAmount('10'), isNull);
      expect(WalletRechargeLogic.validateAmount('1000000'), isNull);
      expect(WalletRechargeLogic.validateAmount('50.50'), isNull);
    });

    test('validateAmount returns error for empty amount', () {
      expect(WalletRechargeLogic.validateAmount(''), 'Please enter amount');
      expect(WalletRechargeLogic.validateAmount(null), 'Please enter amount');
    });

    test('validateAmount returns error for invalid number', () {
      expect(WalletRechargeLogic.validateAmount('abc'), 'Please enter a valid number');
      expect(WalletRechargeLogic.validateAmount('10.abc'), 'Please enter a valid number');
    });

    test('validateAmount returns error for zero or negative amount', () {
      expect(WalletRechargeLogic.validateAmount('0'), 'Amount must be greater than 0');
      expect(WalletRechargeLogic.validateAmount('-100'), 'Amount must be greater than 0');
    });

    test('validateAmount returns error for amount less than minimum', () {
      expect(WalletRechargeLogic.validateAmount('9'), 'Minimum amount is \$10.0');
      expect(WalletRechargeLogic.validateAmount('5'), 'Minimum amount is \$10.0');
    });

    test('validateAmount returns error for amount more than maximum', () {
      expect(WalletRechargeLogic.validateAmount('1000001'), 'Maximum amount is \$1000000.0');
    });

    test('validatePaymentMethod returns null for valid method', () {
      expect(WalletRechargeLogic.validatePaymentMethod('credit_card'), isNull);
      expect(WalletRechargeLogic.validatePaymentMethod('efawateercom'), isNull);
    });

    test('validatePaymentMethod returns error for empty method', () {
      expect(WalletRechargeLogic.validatePaymentMethod(''), 'Please select a payment method');
      expect(WalletRechargeLogic.validatePaymentMethod(null), 'Please select a payment method');
    });

    test('validatePaymentMethod returns error for invalid method', () {
      expect(WalletRechargeLogic.validatePaymentMethod('invalid'), 'Please select a valid payment method');
    });

    test('canProceedToPayment returns correct values', () {
      expect(WalletRechargeLogic.canProceedToPayment('100', 'credit_card'), true);
      expect(WalletRechargeLogic.canProceedToPayment('10', 'efawateercom'), true);
      expect(WalletRechargeLogic.canProceedToPayment('9', 'credit_card'), false);
      expect(WalletRechargeLogic.canProceedToPayment('100', ''), false);
      expect(WalletRechargeLogic.canProceedToPayment('', 'credit_card'), false);
      expect(WalletRechargeLogic.canProceedToPayment('abc', 'credit_card'), false);
    });

    
    test('parseAmount parses correctly', () {
      expect(WalletRechargeLogic.parseAmount('100'), 100.0);
      expect(WalletRechargeLogic.parseAmount('50.50'), 50.5);
      expect(WalletRechargeLogic.parseAmount('abc'), 0.0);
    });

    test('calculateNewBalance calculates correctly', () {
      expect(WalletRechargeLogic.calculateNewBalance(1000, 200), 1200);
      expect(WalletRechargeLogic.calculateNewBalance(500, 50.5), 550.5);
    });

    test('formatBalance formats correctly', () {
      expect(WalletRechargeLogic.formatBalance(100), '100.00');
      expect(WalletRechargeLogic.formatBalance(50.5), '50.50');
      expect(WalletRechargeLogic.formatBalance(123.456), '123.46');
    });

    test('formatAmount formats correctly', () {
      expect(WalletRechargeLogic.formatAmount(100), '100.00');
      expect(WalletRechargeLogic.formatAmount(50.5), '50.50');
    });

    test('calculateTax calculates correctly', () {
      expect(WalletRechargeLogic.calculateTax(100, 0.1), 10.0);
      expect(WalletRechargeLogic.calculateTax(200, 0.05), 10.0);
    });

    test('calculateTotalAmount calculates correctly', () {
      expect(WalletRechargeLogic.calculateTotalAmount(100, 0.1), 110.0);
      expect(WalletRechargeLogic.calculateTotalAmount(200, 0.05), 210.0);
    });

    
    test('getPaymentMethodInfo returns correct info', () {
      final creditCardInfo = WalletRechargeLogic.getPaymentMethodInfo('credit_card');
      expect(creditCardInfo['name'], 'Credit/Debit Card');
      expect(creditCardInfo['icon'], 'credit_card');

      final efawateercomInfo = WalletRechargeLogic.getPaymentMethodInfo('efawateercom');
      expect(efawateercomInfo['name'], 'eFawateercom');
      expect(efawateercomInfo['icon'], 'account_balance_wallet');
    });

    test('getPaymentMethodInfo returns default for invalid method', () {
      final defaultInfo = WalletRechargeLogic.getPaymentMethodInfo('invalid');
      expect(defaultInfo['name'], 'Credit/Debit Card');
    });

    test('isCreditCardPayment identifies correctly', () {
      expect(WalletRechargeLogic.isCreditCardPayment('credit_card'), true);
      expect(WalletRechargeLogic.isCreditCardPayment('efawateercom'), false);
      expect(WalletRechargeLogic.isCreditCardPayment('invalid'), false);
    });

    test('isEfawateercomPayment identifies correctly', () {
      expect(WalletRechargeLogic.isEfawateercomPayment('efawateercom'), true);
      expect(WalletRechargeLogic.isEfawateercomPayment('credit_card'), false);
      expect(WalletRechargeLogic.isEfawateercomPayment('invalid'), false);
    });


    test('getBalanceStats returns correct stats', () {
      final stats = WalletRechargeLogic.getBalanceStats(1250.75);
      expect(stats['today'], '+ \$25.50');
      expect(stats['thisWeek'], '+ \$350.25');
      expect(stats['lastMonth'], '+ \$1,200.00');
    });

    test('quickAmounts list has correct items', () {
      expect(WalletRechargeLogic.quickAmounts.length, 5);
      expect(WalletRechargeLogic.quickAmounts[0]['amount'], '50');
      expect(WalletRechargeLogic.quickAmounts[4]['amount'], '1000');
    });

    test('getQuickAmountIcon returns correct icon names', () {
      expect(WalletRechargeLogic.getQuickAmountIcon('attach_money'), 'attach_money');
      expect(WalletRechargeLogic.getQuickAmountIcon('money'), 'money');
      expect(WalletRechargeLogic.getQuickAmountIcon('invalid'), 'attach_money');
    });

    test('getQuickAmountColor returns correct hex colors', () {
      expect(WalletRechargeLogic.getQuickAmountColor('primary'), '#8A005D');
      expect(WalletRechargeLogic.getQuickAmountColor('purple'), '#9C27B0');
      expect(WalletRechargeLogic.getQuickAmountColor('invalid'), '#8A005D');
    });

    test('isValidDouble checks correctly', () {
      expect(WalletRechargeLogic.isValidDouble('100'), true);
      expect(WalletRechargeLogic.isValidDouble('50.50'), true);
      expect(WalletRechargeLogic.isValidDouble('abc'), false);
      expect(WalletRechargeLogic.isValidDouble(''), false);
    });

    test('generateTransactionId generates valid ID', () {
      final id = WalletRechargeLogic.generateTransactionId();
      expect(id, startsWith('RECH'));
      expect(id.length, greaterThan(6));
    });

    test('createRechargeRecord creates valid record', () {
      final record = WalletRechargeLogic.createRechargeRecord(
        amount: 100,
        method: 'credit_card',
        transactionId: 'TEST123',
      );

      expect(record['id'], 'TEST123');
      expect(record['amount'], 100);
      expect(record['method'], 'credit_card');
      expect(record['type'], 'deposit');
      expect(record['status'], 'Pending');
    });

    test('isAmountSecure checks correctly', () {
      expect(WalletRechargeLogic.isAmountSecure(10), true);
      expect(WalletRechargeLogic.isAmountSecure(1000000), true);
      expect(WalletRechargeLogic.isAmountSecure(9), false);
      expect(WalletRechargeLogic.isAmountSecure(1000001), false);
    });

    test('isPaymentMethodSecure checks correctly', () {
      expect(WalletRechargeLogic.isPaymentMethodSecure('credit_card'), true);
      expect(WalletRechargeLogic.isPaymentMethodSecure('efawateercom'), true);
      expect(WalletRechargeLogic.isPaymentMethodSecure('invalid'), false);
    });

    test('getErrorMessages returns all error messages', () {
      final errors = WalletRechargeLogic.getErrorMessages();
      expect(errors.length, greaterThan(0));
      expect(errors.containsKey('empty_amount'), true);
      expect(errors.containsKey('invalid_method'), true);
    });

    test('getErrorMessage returns correct message', () {
      expect(WalletRechargeLogic.getErrorMessage('empty_amount'), 'Please enter amount');
      expect(WalletRechargeLogic.getErrorMessage('invalid_amount'), 'Please enter a valid number');
      expect(WalletRechargeLogic.getErrorMessage('unknown'), 'An error occurred');
    });

    
    test('Constants have correct values', () {
      expect(WalletRechargeLogic.minRechargeAmount, 10.0);
      expect(WalletRechargeLogic.maxRechargeAmount, 1000000.0);
      expect(WalletRechargeLogic.defaultBalance, 1250.75);
    });

    test('paymentMethods list has correct items', () {
      expect(WalletRechargeLogic.paymentMethods.length, 2);
      expect(WalletRechargeLogic.paymentMethods[0]['id'], 'credit_card');
      expect(WalletRechargeLogic.paymentMethods[1]['id'], 'efawateercom');
    });

    test('importantInfo list has correct items', () {
      expect(WalletRechargeLogic.importantInfo.length, 4);
      expect(WalletRechargeLogic.importantInfo[0], 'Minimum recharge amount: \$10');
      expect(WalletRechargeLogic.importantInfo[3], '24/7 customer support');
    });
  });
}
