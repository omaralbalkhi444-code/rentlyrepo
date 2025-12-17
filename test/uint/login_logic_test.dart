
import 'package:flutter_test/flutter_test.dart';
import 'package:p2/logic/login_logic.dart';


void main() {
  group('LoginLogic Unit Tests', () {
    
    test('Email validation works correctly', () {
      
      expect(LoginLogic.validateEmail('test@example.com'), isNull);
      expect(LoginLogic.validateEmail('user.name@domain.co'), isNull);
      
      
      expect(LoginLogic.validateEmail(''), 'Please enter your email');
      expect(LoginLogic.validateEmail('   '), 'Please enter your email');
      expect(LoginLogic.validateEmail('invalid'), 'Enter a valid email');
      expect(LoginLogic.validateEmail('user@'), 'Enter a valid email');
      expect(LoginLogic.validateEmail('@domain.com'), 'Enter a valid email');
    });
    
    test('Password validation works correctly', () {
     
      expect(LoginLogic.validatePassword('123456'), isNull);
      expect(LoginLogic.validatePassword('password123'), isNull);
      expect(LoginLogic.validatePassword('verylongpassword'), isNull);
      
      expect(LoginLogic.validatePassword(''), 'Please enter your password');
      expect(LoginLogic.validatePassword('   '), 'Please enter your password');
      expect(LoginLogic.validatePassword('123'), 'Password must be at least 6 characters');
      expect(LoginLogic.validatePassword('12345'), 'Password must be at least 6 characters');
    });
    
    test('Username extraction from email', () {
      expect(LoginLogic.extractUsername('user@example.com'), 'user');
      expect(LoginLogic.extractUsername('john.doe@company.com'), 'john.doe');
      expect(LoginLogic.extractUsername('test_user+tag@email.co'), 'test_user+tag');
    });
    
    test('Static methods work without instance', () {
      
      expect(LoginLogic.validateEmail is Function, isTrue);
      expect(LoginLogic.validatePassword is Function, isTrue);
      expect(LoginLogic.extractUsername is Function, isTrue);
    });
  });
}
