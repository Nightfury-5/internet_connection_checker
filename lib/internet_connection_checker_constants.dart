part of 'internet_connection_checker.dart';

// You can use [InternetConnectionCheckerConstants] like this:
// ```dart
// final DEFAULT_TIMEOUT = Constants.DEFAULT_TIMEOUT;
// ```
///
class InternetConnectionCheckerConstants {
  /// Default timeout duration (5 seconds) for checking connectivity.
  // ignore: constant_identifier_names
  static const Duration DEFAULT_TIMEOUT = Duration(seconds: 2);

  /// Default interval (5 seconds) between consecutive connectivity checks.
  // ignore: constant_identifier_names
  static const Duration DEFAULT_INTERVAL = Duration(seconds: 2);

  /// Default threshold duration to consider a connection as "slow".
  // ignore: constant_identifier_names
  static const Duration DEFAULT_SLOW_CONNECTION_THRESHOLD = Duration(
    seconds: 2,
  );

  /// URLs used for connectivity checks.

  /// URL 1
  // ignore: constant_identifier_names
  static const String URL_1 = 'https://one.one.one.one';

  /// URL 2
  // ignore: constant_identifier_names
  static const String URL_2 = 'https://jsonplaceholder.typicode.com/albums/1';

  /// URL 3
  // ignore: constant_identifier_names
  static const String URL_3 = 'https://fakestoreapi.com/products/1';

  /// URL 4
  // ignore: constant_identifier_names
  static const String URL_4 = 'https://icanhazip.com/';

  /// Default list of addresses to check connectivity against.
  // ignore: non_constant_identifier_names
  static final List<AddressCheckOption> DEFAULT_ADDRESSES =
      List<AddressCheckOption>.unmodifiable(<AddressCheckOption>[
    AddressCheckOption(uri: Uri.parse(URL_1)),
    AddressCheckOption(uri: Uri.parse(URL_2)),
    AddressCheckOption(uri: Uri.parse(URL_3)),
    AddressCheckOption(uri: Uri.parse(URL_4)),
  ]);
}
