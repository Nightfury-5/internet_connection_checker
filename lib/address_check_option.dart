part of 'internet_connection_checker.dart';

/// A Callback Function to decide whether the request succeeded or not.
typedef ResponseStatusFn = bool Function(http.Response response);

/// Options for checking the internet connectivity to an address.
///
/// This class provides a way to specify options for checking the connectivity
/// of an address. It includes the URI to check and the timeout duration for
/// the HEAD request.
///
/// *Usage Example:*
///
/// ```dart
/// final options = AddressCheckOption(
///   uri: Uri.parse('https://example.com'),
///   timeout: Duration(seconds: 5),
/// );
/// ```
class AddressCheckOption {
  /// Creates an [AddressCheckOption] instance.
  ///
  /// Options for checking the internet connectivity to an address.
  ///
  /// This class provides a way to specify options for checking the connectivity
  /// of an address. It includes the URI to check and the timeout duration for
  /// the HEAD request.
  ///
  /// *Usage Example:*
  ///
  /// ```dart
  /// final options = AddressCheckOption(
  ///   uri: Uri.parse('https://example.com'),
  ///   timeout: Duration(seconds: 5),
  ///   headers: {
  ///      'Authorization': 'Bearer token',
  ///   },
  /// );
  /// ```
  ///
  /// *With custom `responseStatusFn` callback:*
  ///
  /// ```dart
  /// final options = AddressCheckOption(
  ///   uri: Uri.parse('https://example.com'),
  ///   timeout: Duration(seconds: 5),
  ///   headers: {
  ///      'Authorization': 'Bearer token',
  ///   },
  ///   responseStatusFn: (response) {
  ///     return response.statusCode >= 200 && response.statusCode < 300,
  ///   },
  /// );
  /// ```
  AddressCheckOption({
    required this.uri,
    this.timeout = const Duration(seconds: 3),
    this.headers = const {},
    ResponseStatusFn? responseStatusFn,
  }) : responseStatusFn = responseStatusFn ?? defaultResponseStatusFn;

  /// The default [responseStatusFn]. Success is considered if the status code
  /// is `200`.
  ///
  /// Update this in the `main` function to change the default
  /// behaviour for all [uri] checks.
  ///
  /// *Usage Example:*
  ///
  /// ```dart
  /// void main() {
  ///   AddressCheckOption.defaultResponseStatusFn = (response) {
  ///     return response.statusCode >= 200 && response.statusCode < 300;
  ///   };
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  static ResponseStatusFn defaultResponseStatusFn = (response) {
    return response.statusCode == 200;
  };

  /// URI to check for connectivity. A HEAD request will be made to this URI.
  ///
  /// Make sure that the cache-control header is set to `no-cache` on the server
  /// side. Otherwise, the HEAD request will be cached and the result will be
  /// incorrect.
  ///
  /// For `web` platform, make sure that the URI is _CORS_ enabled. To check if
  /// requests are being blocked, open the **Network tab** in your browser's
  /// developer tools and see if the request is being blocked by _CORS_.
  final Uri uri;

  /// The duration after the HEAD request should be timed out.
  ///
  /// Defaults to 3 seconds.
  final Duration timeout;

  /// A map of additional headers to send with the request.
  final Map<String, String> headers;

  /// A custom callback function to decide whether the request succeeded or not.
  ///
  /// It is useful if your [uri] returns `non-200` status code.
  ///
  /// *Usage Example:*
  ///
  /// ```dart
  /// responseStatusFn: (response) {
  ///   return response.statusCode >= 200 && response.statusCode < 300;
  /// }
  /// ```
  final ResponseStatusFn responseStatusFn;

  @override
  String toString() {
    return 'AddressCheckOption(\n'
        '  uri: $uri,\n'
        '  timeout: $timeout,\n'
        '  headers: $headers\n'
        ')';
  }
}
