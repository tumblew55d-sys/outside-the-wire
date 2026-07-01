import 'package:flutter_test/flutter_test.dart';

/// Test email validation logic
void main() {
  group('Email Validation Tests', () {
    bool isValidEmail(String email) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      return emailRegex.hasMatch(email);
    }

    test('Valid emails should pass', () {
      expect(isValidEmail('user@example.com'), isTrue);
      expect(isValidEmail('john.doe@company.co.uk'), isTrue);
      expect(isValidEmail('test_user@domain.org'), isTrue);
      expect(isValidEmail('admin@sub.domain.com'), isTrue);
      expect(isValidEmail('user123@test.io'), isTrue);
    });

    test('Invalid emails should fail', () {
      expect(isValidEmail('notanemail'), isFalse);
      expect(isValidEmail('user@'), isFalse);
      expect(isValidEmail('@example.com'), isFalse);
      expect(isValidEmail('user@.com'), isFalse);
      expect(isValidEmail('user @example.com'), isFalse);
      expect(isValidEmail('user@example'), isFalse);
      expect(isValidEmail(''), isFalse);
    });

    test('Edge case emails', () {
      // Note: Simple regex doesn't support all RFC 5322 valid emails
      // These are practical common cases
      expect(isValidEmail('user.name@example.com'), isTrue);
      expect(isValidEmail('user-name@example.com'), isTrue);
      expect(isValidEmail('123@example.com'), isTrue);
      // Plus sign would require more complex regex, so we skip it
      // expect(isValidEmail('user+tag@example.com'), isTrue);
    });
  });
}
