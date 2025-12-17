
import 'package:flutter_test/flutter_test.dart';
import 'package:p2/logic/create_account_logic.dart';

void main() {
  group('CreateAccountLogic Unit Tests', () {
    
    test('Email validation works correctly', () {
     
      expect(CreateAccountLogic.validateEmail('test@example.com'), isNull);
      expect(CreateAccountLogic.validateEmail('user.name@domain.co'), isNull);
    
      expect(CreateAccountLogic.validateEmail(''), 'Please enter your email');
      expect(CreateAccountLogic.validateEmail('   '), 'Please enter your email');
      expect(CreateAccountLogic.validateEmail('invalid'), 'Invalid email address');
      expect(CreateAccountLogic.validateEmail('user@'), 'Invalid email address');
      expect(CreateAccountLogic.validateEmail('@domain.com'), 'Invalid email address');
    });
    
    test('Password validation works correctly', () {
     
      expect(CreateAccountLogic.validatePassword('123456'), isNull);
      expect(CreateAccountLogic.validatePassword('password123'), isNull);
      expect(CreateAccountLogic.validatePassword('verylongpassword'), isNull);
      
      expect(CreateAccountLogic.validatePassword(''), 'Please enter your password');
      expect(CreateAccountLogic.validatePassword('   '), 'Please enter your password');
      expect(CreateAccountLogic.validatePassword('123'), 'Password must be at least 6 characters');
      expect(CreateAccountLogic.validatePassword('12345'), 'Password must be at least 6 characters');
    });
    
    test('Username extraction from email', () {
      expect(CreateAccountLogic.extractUsername('user@example.com'), 'user');
      expect(CreateAccountLogic.extractUsername('john.doe@company.com'), 'john.doe');
      expect(CreateAccountLogic.extractUsername('test_user+tag@email.co'), 'test_user+tag');
    });
    
    test('Email format validation', () {
      expect(CreateAccountLogic.isValidEmail('test@example.com'), isTrue);
      expect(CreateAccountLogic.isValidEmail('user@domain.co'), isTrue);
      expect(CreateAccountLogic.isValidEmail('invalid'), isFalse);
      expect(CreateAccountLogic.isValidEmail('user@'), isFalse);
      expect(CreateAccountLogic.isValidEmail('@domain.com'), isFalse);
    });
    
    test('Static methods work without instance', () {
      expect(CreateAccountLogic.validateEmail is Function, isTrue);
      expect(CreateAccountLogic.validatePassword is Function, isTrue);
      expect(CreateAccountLogic.extractUsername is Function, isTrue);
      expect(CreateAccountLogic.isValidEmail is Function, isTrue);
    });
  });
}
