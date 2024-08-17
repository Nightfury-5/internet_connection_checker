import 'package:flutter_test/flutter_test.dart';
import 'package:http/src/base_request.dart';
import 'package:http/src/response.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '__mocks__/test_http_client.dart';

void main() {
  group('InternetConnectionChecker', () {
    group('hasConnection', () {
      test('returns true for valid URIs', () async {
        final InternetConnectionChecker checker = InternetConnectionChecker();
        expect(await checker.hasConnection, true);
      });

      test('returns false for invalid URIs', () async {
        final InternetConnectionChecker checker =
            InternetConnectionChecker.createInstance(
          customCheckOptions: <AddressCheckOption>[
            AddressCheckOption(
              uri: Uri.parse('https://www.example.com/nonexistent-page'),
            ),
          ],
          useDefaultOptions: false,
        );
        expect(await checker.hasConnection, false);
      });

      test('invokes responseStatusFn to determine success', () async {
        const bool expectedStatus = true;
        final InternetConnectionChecker checker =
            InternetConnectionChecker.createInstance(
          customCheckOptions: <AddressCheckOption>[
            AddressCheckOption(
              uri: Uri.parse('https://www.example.com/nonexistent-page'),
              responseStatusFn: (Response response) => expectedStatus,
            ),
          ],
          useDefaultOptions: false,
        );

        expect(await checker.hasConnection, expectedStatus);
      });

      test('sends custom headers on request', () async {
        await TestHttpClient.run((TestHttpClient client) async {
          const bool expectedStatus = true;
          const Map<String, String> expectedHeaders = <String, String>{
            'Authorization': 'Bearer token',
          };

          client.responseBuilder = (BaseRequest req) {
            for (final MapEntry<String, String> header
                in expectedHeaders.entries) {
              final String key = header.key;
              if (!req.headers.containsKey(key) ||
                  req.headers[key] != header.value) {
                return TestHttpClient.createResponse(statusCode: 500);
              }
            }
            return TestHttpClient.createResponse();
          };
          final InternetConnectionChecker checker =
              InternetConnectionChecker.createInstance(
            customCheckOptions: <AddressCheckOption>[
              AddressCheckOption(
                uri: Uri.parse('https://www.example.com'),
                headers: expectedHeaders,
              ),
            ],
            useDefaultOptions: false,
          );

          expect(await checker.hasConnection, expectedStatus);
        });
      });
    });

    test('main constructor returns the same instance', () {
      final InternetConnectionChecker checker = InternetConnectionChecker();
      expect(checker, InternetConnectionChecker());
    });

    test('createInstance constructor returns different instances', () {
      final InternetConnectionChecker checker =
          InternetConnectionChecker.createInstance();
      expect(checker, isNot(InternetConnectionChecker.createInstance()));
    });
  });
}
