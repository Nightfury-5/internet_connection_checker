
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

void main() {
  group('AddressCheckResult', () {
    test('toString() returns correct string representation', () {
      final AddressCheckOption option = AddressCheckOption(
        uri: Uri.parse('https://example.com'),
      );
      final AddressCheckResult result = AddressCheckResult(
        option: option,
        isSuccess: true,
      );

      const String expectedString = 'AddressCheckResult(\n'
          '  option: AddressCheckOption(\n'
          '    uri: https://example.com,\n'
          '    timeout: 0:00:03.000000,\n'
          '    headers: {}\n'
          '  ),\n'
          '  isSuccess: true\n'
          ')';

      expect(result.toString(), expectedString);
    });

    test('with different options are not equal', () {
      final AddressCheckOption option1 = AddressCheckOption(
        uri: Uri.parse('https://example.com'),
      );
      final AddressCheckOption option2 = AddressCheckOption(
        uri: Uri.parse('https://example.org'),
        timeout: const Duration(seconds: 5),
      );
      final AddressCheckResult result1 = AddressCheckResult(
        option: option1,
        isSuccess: true,
      );
      final AddressCheckResult result2 = AddressCheckResult(
        option: option2,
        isSuccess: true,
      );

      expect(result1, isNot(equals(result2)));
    });
  });
}
