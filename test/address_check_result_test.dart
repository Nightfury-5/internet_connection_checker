import 'package:shitty_connection_checker/internet_connection_checker.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

void main() {
  test(
    'should verify toString() method',
    () {
      // Setup - Arrange
      final InternetAddress tInternetAddress = InternetAddress('1.1.1.1');
      const int DEFAULT_PORT = 43;
      const Duration DEFAULT_TIMEOUT = Duration(seconds: 10);
      const bool isSuccess = true;
      final AddressCheckOptions tOptions = AddressCheckOptions(
        tInternetAddress,
        port: DEFAULT_PORT,
        timeout: DEFAULT_TIMEOUT,
      );

      final AddressCheckResult tResult =
          AddressCheckResult(tOptions, isSuccess);
      // Action - Act

      // Result - Assert
      expect(tResult.toString(), 'AddressCheckResult($tOptions, $isSuccess)');
    },
  );
}
