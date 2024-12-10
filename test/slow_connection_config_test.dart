import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Main entry point for the test suite.
void main() {
  // Grouping tests related to SlowConnectionConfig.
  group('SlowConnectionConfig', () {
    /// Test case to check if the default values are correctly set.
    test('should have correct default values', () {
      // Act: Create an instance of SlowConnectionConfig with default values.
      const config = SlowConnectionConfig();

      // Assert: Verify that the default properties are set correctly.
      expect(config.enableToCheckForSlowConnection, false);
      expect(config.slowConnectionThreshold, const Duration(seconds: 2));
    });

    /// Test case to verify that custom values can be correctly initialized.
    test('should initialize with custom values', () {
      // Arrange: Define custom values for the properties.
      const customThreshold = Duration(milliseconds: 500);

      // Act: Create an instance of SlowConnectionConfig with custom values.
      const config = SlowConnectionConfig(
        enableToCheckForSlowConnection: true,
        slowConnectionThreshold: customThreshold,
      );

      // Assert: Verify that the custom properties are set correctly.
      expect(config.enableToCheckForSlowConnection, true);
      expect(config.slowConnectionThreshold, customThreshold);
    });

    /// Test case to check if two instances with the same properties are
    /// considered equal.
    test('should support equality comparison', () {
      // Arrange: Create two instances of SlowConnectionConfig with the
      // same properties.
      const config1 = SlowConnectionConfig(
        enableToCheckForSlowConnection: true,
        slowConnectionThreshold: Duration(milliseconds: 500),
      );

      const config2 = SlowConnectionConfig(
        enableToCheckForSlowConnection: true,
        slowConnectionThreshold: Duration(milliseconds: 500),
      );

      // Assert: Verify that the instances are equal.
      expect(config1, config2);
    });

    /// Test case to check if two instances with different properties are
    /// not considered equal.
    test('should support inequality comparison', () {
      // Arrange: Create two instances of SlowConnectionConfig with
      // different properties.
      const config1 = SlowConnectionConfig(
        enableToCheckForSlowConnection: true,
        slowConnectionThreshold: Duration(milliseconds: 500),
      );

      const config2 = SlowConnectionConfig(
        slowConnectionThreshold: Duration(milliseconds: 1000),
      );

      // Assert: Verify that the instances are not equal.
      expect(config1, isNot(config2));
    });

    /// Test case to verify the string representation of an instance
    /// with default values.
    test(
        '''should return correct string representation when default values are used''',
        () {
      // Arrange: Create an instance of SlowConnectionConfig with
      // default values.
      const config = SlowConnectionConfig();

      // Act: Get the string representation of the config instance.
      final configString = config.toString();

      // Assert: Verify that the string representation is correct.
      expect(
        configString,
        '''SlowConnectionConfig(enableToCheckForSlowConnection: false, slowConnectionThreshold: 0:00:02.000000)''',
      );
    });

    /// Test case to verify the string representation of an instance
    /// with custom values.
    test(
        '''should return correct string representation when custom values are used''',
        () {
      // Arrange: Create an instance of SlowConnectionConfig with custom values.
      const config = SlowConnectionConfig(
        enableToCheckForSlowConnection: true,
        slowConnectionThreshold: Duration(seconds: 5),
      );

      // Act: Get the string representation of the config instance.
      final configString = config.toString();

      // Assert: Verify that the string representation is correct.
      expect(
        configString,
        '''SlowConnectionConfig(enableToCheckForSlowConnection: true, slowConnectionThreshold: 0:00:05.000000)''',
      );
    });
  });
}
