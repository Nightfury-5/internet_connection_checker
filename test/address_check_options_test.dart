import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/src/response.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

void main() {
  group('AddressCheckOption', () {
    test('toString() returns correct string representation', () {
      final AddressCheckOption options = AddressCheckOption(
        uri: Uri.parse('https://example.com'),
        timeout: const Duration(seconds: 5),
      );

      const String expectedString = 'AddressCheckOption(\n'
          '  uri: https://example.com,\n'
          '  timeout: 0:00:05.000000,\n'
          '  headers: {}\n'
          ')';

      expect(options.toString(), expectedString);
    });

    group('headers', () {
      test('are empty if not set', () {
        final AddressCheckOption options = AddressCheckOption(
          uri: Uri.parse('https://example.com'),
        );

        expect(options.headers, <dynamic, dynamic>{});
      });

      test('are set correctly', () {
        const Map<String, String> headers = <String, String>{'key': 'value'};

        final AddressCheckOption options = AddressCheckOption(
          uri: Uri.parse('https://example.com'),
          headers: headers,
        );

        expect(options.headers, headers);
      });
    });

    group('responseStatusFn', () {
      test('is equal to defaultResponseStatusFn if not set', () {
        final AddressCheckOption options1 = AddressCheckOption(
          uri: Uri.parse('https://example.com'),
        );

        expect(
          options1.responseStatusFn,
          equals(AddressCheckOption.defaultResponseStatusFn),
        );
      });

      test('is set correctly', () {
        bool customResponseStatusFn(http.Response response) => true;

        final AddressCheckOption options1 = AddressCheckOption(
          uri: Uri.parse('https://example.com'),
          responseStatusFn: customResponseStatusFn,
        );

        expect(options1.responseStatusFn, equals(customResponseStatusFn));
        expect(
          options1.responseStatusFn,
          isNot(equals(AddressCheckOption.defaultResponseStatusFn)),
        );
      });
    });

    group('defaultResponseStatusFn', () {
      test('can be overriden', () {
        final AddressCheckOption options = AddressCheckOption(
          uri: Uri.parse('https://example.com'),
        );

        AddressCheckOption.defaultResponseStatusFn =
            (Response response) => true;

        expect(
          options.responseStatusFn,
          isNot(equals(AddressCheckOption.defaultResponseStatusFn)),
        );
      });

      test('override is used', () {
        bool customResponseStatusFn(http.Response response) => true;

        AddressCheckOption.defaultResponseStatusFn = customResponseStatusFn;

        final AddressCheckOption options = AddressCheckOption(
          uri: Uri.parse('https://example.com'),
        );

        expect(options.responseStatusFn, equals(customResponseStatusFn));
      });
    });
  });
}
