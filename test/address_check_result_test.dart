import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Main entry point for the test suite.
void main() {
  // Grouping tests related to AddressCheckResult.
  group('AddressCheckResult', () {
    /// Test case to check if the constructor correctly sets properties.
    test('should correctly set properties via constructor', () {
      // Arrange: Initialize URI, option, and success flag.
      final uri = Uri.parse('https://example.com');
      final option = AddressCheckOption(uri: uri);
      const isSuccess = true;

      // Act: Create an instance of AddressCheckResult with the given
      // option and success flag.
      final result = AddressCheckResult(option, isSuccess: isSuccess);

      // Assert: Verify that the instance properties are set correctly.
      expect(result.option, option);
      expect(result.isSuccess, isSuccess);
    });

    /// Test case to check if two instances with the same properties
    /// are considered equal.
    test('should consider two instances equal if their properties are the same',
        () {
      // Arrange: Initialize URI, option, and success flag.
      final uri = Uri.parse('https://example.com');
      final option = AddressCheckOption(uri: uri);
      const isSuccess = true;

      // Create two instances of AddressCheckResult with the same
      // option and success flag.
      final result1 = AddressCheckResult(option, isSuccess: isSuccess);
      final result2 = AddressCheckResult(option, isSuccess: isSuccess);

      // Act & Assert: Verify that the instances are equal and have the
      // same hashCode.
      expect(result1, result2);
      expect(result1.hashCode, result2.hashCode);
    });

    /// Test case to check if two instances with different properties are
    /// not considered equal.
    test('should consider two instances not equal if their properties differ',
        () {
      // Arrange: Initialize different URIs, option, and success flags.
      final uri1 = Uri.parse('https://example.com');
      final uri2 = Uri.parse('https://example.org');
      final option1 = AddressCheckOption(uri: uri1);
      final option2 =
          AddressCheckOption(uri: uri2, timeout: const Duration(seconds: 10));
      const isSuccess1 = true;
      const isSuccess2 = false;

      // Create three instances of AddressCheckResult with varying options
      // and success flags.
      final result1 = AddressCheckResult(option1, isSuccess: isSuccess1);
      final result2 = AddressCheckResult(option2, isSuccess: isSuccess2);
      final result3 = AddressCheckResult(option1, isSuccess: isSuccess2);

      // Act & Assert: Verify that instances with different properties are
      // not equal and have different hashCodes.
      expect(result1, isNot(result2));
      expect(result1.hashCode, isNot(result2.hashCode));

      expect(result1, isNot(result3));
      expect(result1.hashCode, isNot(result3.hashCode));
    });

    /// Test case to verify the string representation of an instance
    /// with a successful check.
    test('should return correct string representation', () {
      // Arrange: Initialize URI, options, and success flag.
      final uri = Uri.parse('https://example.com');
      final option =
          AddressCheckOption(uri: uri, timeout: const Duration(seconds: 10));
      final result = AddressCheckResult(option, isSuccess: true);

      // Act: Get the string representation of the result instance.
      final resultString = result.toString();

      // Assert: Verify that the string representation is correct.
      expect(
        resultString,
        'AddressCheckResult(option: $option, isSuccess: true)',
      );
    });

    /// Test case to verify the string representation of an instance
    /// with a failed check.
    test('should return correct string representation for failed check', () {
      // Arrange: Initialize URI, options, and success flag.
      final uri = Uri.parse('https://example.com');
      final option = AddressCheckOption(uri: uri);
      final result = AddressCheckResult(option, isSuccess: false);

      // Act: Get the string representation of the result instance.
      final resultString = result.toString();

      // Assert: Verify that the string representation correctly
      // indicates a failed check.
      expect(
        resultString,
        'AddressCheckResult(option: $option, isSuccess: false)',
      );
    });
  });
}
