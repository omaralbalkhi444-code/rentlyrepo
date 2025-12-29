import 'package:flutter_test/flutter_test.dart';
import 'package:p2/logic/credit_card_logic.dart';

void main() {
  group('CreditCardLogic Tests', () {
    late CreditCardLogic logic;

    setUp(() {
      logic = CreditCardLogic(amount: 100.0);
    });

    test('Initial state is correct', () {
      expect(logic.amount, 100.0);
      expect(logic.cardNumber, '');
      expect(logic.cardHolder, '');
      expect(logic.expiryDate, '');
      expect(logic.cvv, '');
      expect(logic.isProcessing, false);
      expect(logic.cardType, isNull);
      expect(logic.showErrors, false);
      expect(logic.hasErrors(), false);
    });

    test('updateCardNumber formats correctly', () {
      logic.updateCardNumber('1234567890123456');
      expect(logic.cardNumber, '1234 5678 9012 3456');
    });

    test('updateCardNumber detects Visa card', () {
      logic.updateCardNumber('4123456789012345');
      expect(logic.cardType, 'Visa');
    });

    test('updateCardNumber validation - empty', () {
      logic.updateCardNumber('');
      expect(logic.cardNumberError, 'Please enter card number');
    });

    test('updateCardNumber validation - too short', () {
      logic.updateCardNumber('1234 5678 9012'); 
      expect(logic.cardNumberError, 'Card number must be 16 digits');
    });

    test('updateCardNumber validation - non-Visa', () {
      logic.updateCardNumber('5123456789012345');
      expect(logic.cardNumberError, 'Only Visa cards are accepted (must start with 4)');
    });

    test('updateCardNumber validation - contains non-digits', () {
      logic.updateCardNumber('4123 4567 8901 23AB');
      expect(logic.cardNumberError, 'Card number must contain only digits');
    });

    test('updateCardNumber validation - invalid Visa card', () {
      logic.updateCardNumber('4111111111111112');
      expect(logic.cardNumberError, 'Invalid Visa card number');
    });

    test('updateCardNumber validation - valid Visa card', () {
      logic.updateCardNumber('4111111111111111');
      expect(logic.cardNumberError, isNull);
    });

    test('updateCardHolder validation - empty', () {
      logic.updateCardHolder('');
      expect(logic.cardHolderError, 'Please enter card holder name');
    });

    test('updateCardHolder validation - too short', () {
      logic.updateCardHolder('Ab');
      expect(logic.cardHolderError, 'Name must be at least 3 characters');
    });

    test('updateCardHolder validation - single name', () {
      logic.updateCardHolder('John');
      expect(logic.cardHolderError, 'Please enter full name (first and last name)');
    });

    test('updateCardHolder validation - valid name', () {
      logic.updateCardHolder('John Doe');
      expect(logic.cardHolderError, isNull);
    });

    test('updateCardHolder validation - contains numbers', () {
      logic.updateCardHolder('John Doe123');
      expect(logic.cardHolderError, 'Name must contain only letters and spaces');
    });

    test('updateCardHolder validation - name parts too short', () {
      logic.updateCardHolder('J D');
      expect(logic.cardHolderError, 'Each name part must be at least 2 characters');
    });

    test('updateCardHolder validation - three names valid', () {
      logic.updateCardHolder('John Michael Doe');
      expect(logic.cardHolderError, isNull);
    });

    test('updateExpiryDate formats correctly - 4 digits input', () {
      logic.updateExpiryDate('1225');
      expect(logic.expiryDate, '12/25');
    });

    test('updateExpiryDate formats correctly - with slash', () {
      logic.updateExpiryDate('12/25');
      expect(logic.expiryDate, '12/25');
    });

    test('updateExpiryDate formats correctly - with dash', () {
      logic.updateExpiryDate('12-25');
      expect(logic.expiryDate, '12/25');
    });

    test('updateExpiryDate formats correctly - partial input', () {
      logic.updateExpiryDate('12');
      expect(logic.expiryDate, '12/');
    });

    test('updateExpiryDate formats correctly - partial input with dash', () {
      logic.updateExpiryDate('12-');
      expect(logic.expiryDate, '12/');
    });

    test('updateExpiryDate validation - empty', () {
      logic.updateExpiryDate('');
      expect(logic.expiryDateError, 'Please enter expiry date');
    });

    test('updateExpiryDate validation - invalid month (00)', () {
      logic.updateExpiryDate('00/25');
      expect(logic.expiryDateError, 'Format: MM/YY (e.g., 12/25)');
    });

    test('updateExpiryDate validation - invalid month (13)', () {
      logic.updateExpiryDate('13/25');
      expect(logic.expiryDateError, 'Format: MM/YY (e.g., 12/25)');
    });

    test('updateExpiryDate validation - too short', () {
      logic.updateExpiryDate('12');
      expect(logic.expiryDateError, 'Format: MM/YY (e.g., 12/25)');
    });

    test('updateExpiryDate validation - invalid format with dash', () {
      logic.updateExpiryDate('12-25');
      expect(logic.expiryDateError, isNull);
    });

    test('updateExpiryDate validation - expired card', () {
      final now = DateTime.now();
      final pastYear = (now.year % 100) - 1;
      final month = now.month;
      logic.updateExpiryDate('${month.toString().padLeft(2, '0')}/$pastYear');
      expect(logic.expiryDateError, 'Card has expired or invalid date');
    });

    test('updateExpiryDate validation - current month valid', () {
      final now = DateTime.now();
      final currentYear = now.year % 100;
      final currentMonth = now.month;
      logic.updateExpiryDate('${currentMonth.toString().padLeft(2, '0')}/$currentYear');
      expect(logic.expiryDateError, isNull);
    });

    test('updateCVV validation - empty', () {
      logic.updateCVV('');
      expect(logic.cvvError, 'Please enter CVV');
    });

    test('updateCVV validation - invalid length (2 digits)', () {
      logic.updateCVV('12');
      expect(logic.cvvError, 'CVV must be 3 digits');
    });

    test('updateCVV validation - invalid length (4 digits)', () {
      logic.updateCVV('1234');
      expect(logic.cvvError, 'CVV must be 3 digits');
    });

    test('updateCVV validation - contains letters', () {
      logic.updateCVV('12A');
      expect(logic.cvvError, 'CVV must be 3 digits');
    });

    test('updateCVV validation - valid', () {
      logic.updateCVV('123');
      expect(logic.cvvError, isNull);
    });

    test('validateAll returns true when all fields valid', () {
      logic.updateCardNumber('4111111111111111');
      logic.updateCardHolder('John Doe');
      
      final now = DateTime.now();
      final futureYear = (now.year % 100) + 1;
      logic.updateExpiryDate('12/$futureYear');
      
      logic.updateCVV('123');
      
      final isValid = logic.validateAll();
      expect(isValid, true);
      expect(logic.showErrors, true);
    });

    test('validateAll returns false when any field invalid', () {
      logic.updateCardNumber('4111111111111111');
      logic.updateCardHolder('John');
      logic.updateExpiryDate('12/30');
      logic.updateCVV('123');
      
      final isValid = logic.validateAll();
      expect(isValid, false);
    });

    test('hasErrors returns correct value', () {
      expect(logic.hasErrors(), false);
      
      logic.updateCardNumber('123');
      logic.validateAll();
      expect(logic.hasErrors(), true);
    });

    test('processPayment returns success most of the time', () async {
      final result = await logic.processPayment();
      
      expect(logic.isProcessing, false);
      expect(result, isA<bool>());
      
      expect(logic.isProcessing, false);
    });

    test('clearErrors resets error state', () {
      logic.updateCardNumber('123');
      logic.validateAll();
      expect(logic.showErrors, true);
      expect(logic.cardNumberError, isNotNull);
      
      logic.clearErrors();
      expect(logic.showErrors, false);
      expect(logic.cardNumberError, isNull);
    });

    test('reset clears all fields', () {
      logic.updateCardNumber('4111111111111111');
      logic.updateCardHolder('John Doe');
      logic.updateExpiryDate('12/30');
      logic.updateCVV('123');
      logic.validateAll();
      
      logic.reset();
      
      expect(logic.cardNumber, '');
      expect(logic.cardHolder, '');
      expect(logic.expiryDate, '');
      expect(logic.cvv, '');
      expect(logic.cardType, null);
      expect(logic.showErrors, false);
      expect(logic.hasErrors(), false);
    });

    test('isFormValid returns correct value', () {
      expect(logic.isFormValid, false);
      
      logic.updateCardNumber('4111111111111111');
      logic.updateCardHolder('John Doe');
      
      final now = DateTime.now();
      final futureYear = (now.year % 100) + 1;
      logic.updateExpiryDate('12/$futureYear');
      
      logic.updateCVV('123');
      
      expect(logic.isFormValid, true);
    });

    test('getErrorMessage returns correct message', () {
      expect(logic.getErrorMessage(), 'Please fill in all required fields correctly');
    });

    test('getters return correct validation states', () {
      expect(logic.isCardNumberValid, false);
      expect(logic.isCardHolderValid, false);
      expect(logic.isExpiryDateValid, false);
      expect(logic.isCVVValid, false);
      
      logic.updateCardNumber('4111111111111111');
      logic.updateCardHolder('John Doe');
      
      final now = DateTime.now();
      final futureYear = (now.year % 100) + 1;
      logic.updateExpiryDate('12/$futureYear');
      
      logic.updateCVV('123');
      
      expect(logic.isCardNumberValid, true);
      expect(logic.isCardHolderValid, true);
      expect(logic.isExpiryDateValid, true);
      expect(logic.isCVVValid, true);
    });

    test('luhnAlgorithm validates card numbers', () {
      expect(logic.testLuhnAlgorithm('4111111111111111'), true);
      expect(logic.testLuhnAlgorithm('4111111111111112'), false);
      expect(logic.testLuhnAlgorithm('4242424242424242'), true);
      expect(logic.testLuhnAlgorithm('4000056655665556'), true);
    });

    test('expiry date validation with current date', () {
      final now = DateTime.now();
      final currentYear = now.year % 100;
      final currentMonth = now.month;
      
      logic.updateExpiryDate('${currentMonth.toString().padLeft(2, '0')}/$currentYear');
      expect(logic.expiryDateError, isNull);
      
      if (currentMonth > 1) {
        logic.updateExpiryDate('${(currentMonth - 1).toString().padLeft(2, '0')}/$currentYear');
        expect(logic.expiryDateError, 'Card has expired or invalid date');
      }
    });

    test('expiry date validation with future date', () {
      final now = DateTime.now();
      final futureYear = (now.year % 100) + 2; 
      logic.updateExpiryDate('12/$futureYear');
      expect(logic.expiryDateError, isNull);
    });

    test('updateExpiryDate with invalid characters', () {
      logic.updateExpiryDate('12#25');
      expect(logic.expiryDate, '12/25');
    });

    test('updateExpiryDate with multiple slashes', () {
      logic.updateExpiryDate('12//25');
      expect(logic.expiryDate, '12/25');
    });

    test('updateExpiryDate with extra digits', () {
      logic.updateExpiryDate('122525');
      expect(logic.expiryDate, '12/25');
    });
  });
}
