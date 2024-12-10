import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Main entry point for the test suite.
void main() {
  // Grouping tests related to AddressCheckOption.
  group('AddressCheckOption', () {
    /// Test case to check if the constructor correctly sets properties.
    test('should correctly set properties via constructor', () {
      // Arrange: Initialize URI and timeout values.
      final uri = Uri.parse('https://example.com');
      const timeout = Duration(seconds: 10);

      // Act: Create an instance of AddressCheckOption with the given URI
      // and timeout.
      final option = AddressCheckOption(uri: uri, timeout: timeout);

      // Assert: Verify that the instance properties are set correctly.
      expect(option.uri, uri);
      expect(option.timeout, timeout);
    });

    /// Test case to verify that the timeout defaults to DEFAULT_TIMEOUT
    /// if not provided.
    test('should default timeout to DEFAULT_TIMEOUT if not provided', () {
      // Arrange: Initialize URI value.
      final uri = Uri.parse('https://example.com');

      // Act: Create an instance of AddressCheckOption with the given
      // URI but no timeout.
      final option = AddressCheckOption(uri: uri);

      // Assert: Verify that the timeout defaults to
      // InternetConnectionChecker.DEFAULT_TIMEOUT.
      expect(option.uri, uri);
      expect(option.timeout, InternetConnectionChecker.DEFAULT_TIMEOUT);
    });

    /// Test case to check if two instances with the same
    /// properties are considered equal.
    test('should consider two instances equal if their properties are the same',
        () {
      // Arrange: Initialize URI and timeout values.
      final uri = Uri.parse('https://example.com');
      const timeout = Duration(seconds: 10);

      // Create two instances of AddressCheckOption with the
      // same URI and timeout.
      final option1 = AddressCheckOption(uri: uri, timeout: timeout);
      final option2 = AddressCheckOption(uri: uri, timeout: timeout);

      // Act & Assert: Verify that the instances are equal and
      // have the same hashCode.
      expect(option1, option2);
      expect(option1.hashCode, option2.hashCode);
    });

    /// Test case to check if two instances with different properties
    /// are not considered equal.
    test('should consider two instances not equal if their properties differ',
        () {
      // Arrange: Initialize different URI values and a common timeout.
      final uri1 = Uri.parse('https://example.com');
      final uri2 = Uri.parse('https://example.org');
      const timeout = Duration(seconds: 10);

      // Create two instances of AddressCheckOption with different URIs
      // but the same timeout.
      final option1 = AddressCheckOption(uri: uri1, timeout: timeout);
      final option2 = AddressCheckOption(uri: uri2, timeout: timeout);

      // Act & Assert: Verify that the instances are not equal and have
      // different hashCodes.
      expect(option1, isNot(option2));
      expect(option1.hashCode, isNot(option2.hashCode));
    });

    /// Test case to verify the string representation of an instance
    /// with a custom timeout.
    test('should return correct string representation', () {
      // Arrange: Initialize URI and timeout values.
      final uri = Uri.parse('https://example.com');
      final option =
          AddressCheckOption(uri: uri, timeout: const Duration(seconds: 10));

      // Act: Get the string representation of the option instance.
      final result = option.toString();

      // Assert: Verify that the string representation is correct.
      expect(result, 'AddressCheckOption(uri: $uri, timeout: 0:00:10.000000)');
    });

    /// Test case to verify the string representation of an instance 
    /// with the default timeout.
    test('should return correct string representation with default timeout',
        () {
      // Arrange: Initialize URI value.
      final uri = Uri.parse('https://example.com');
      final option = AddressCheckOption(uri: uri);

      // Act: Get the string representation of the option instance.
      final result = option.toString();

      // Assert: Verify that the string representation correctly 
      // includes the default timeout.
      expect(
        result,
        '''AddressCheckOption(uri: $uri, timeout: ${InternetConnectionChecker.DEFAULT_TIMEOUT})''',
      );
    });
  });
}
