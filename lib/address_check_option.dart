part of 'internet_connection_checker.dart';

/// Represents the configuration options for checking the internet connectivity
/// to a specific address.
///
/// The `AddressCheckOption` class allows you to specify the URI to be checked
/// and the timeout duration for the request. The class uses `Equatable` for
/// value comparison, making it easier to manage instances of this class in
/// equality checks and collections.
///
/// *Example Usage:*
///
/// ```dart
/// final options = AddressCheckOption(
///   uri: Uri.parse('https://example.com'),
///   timeout: Duration(seconds: 5),
/// );
/// ```
class AddressCheckOption extends Equatable {
  /// Creates an instance of `AddressCheckOption`.
  ///
  /// The [uri] parameter is required and specifies the address to be checked.
  /// The [timeout] parameter is optional and defaults to `DEFAULT_TIMEOUT` from
  /// the `InternetConnectionChecker` class, which typically represents
  /// a duration of 5 seconds.
  ///
  /// *Example:*
  ///
  /// ```dart
  /// final options = AddressCheckOption(
  ///   uri: Uri.parse('https://example.com'),
  ///   timeout: Duration(seconds: 10), // Optional, defaults to 5 seconds.
  /// );
  /// ```
  const AddressCheckOption({
    required this.uri,
    this.timeout = InternetConnectionChecker.DEFAULT_TIMEOUT,
  });

  /// The URI to be checked for internet connectivity.
  ///
  /// This is the address where a request will be sent to verify internet
  /// connectivity. The request type (e.g., HEAD, GET) and its handling
  /// would be managed elsewhere in the connectivity checking logic.
  final Uri uri;

  /// The duration before the request times out.
  ///
  /// Specifies how long to wait for a response before considering the request
  /// as failed. If not provided, it defaults to `DEFAULT_TIMEOUT`.
  final Duration timeout;

  /// Properties to compare instances of `AddressCheckOption`.
  ///
  /// This list is used by `Equatable` to determine whether two instances
  /// of this class are considered equal.
  @override
  List<Object?> get props => <Object?>[uri, timeout];

  /// A custom string representation for debugging purposes.
  ///
  /// When you print an instance of `AddressCheckOption`, this
  /// method will provide a readable format of its values.
  @override
  String toString() {
    return 'AddressCheckOption(uri: $uri, timeout: $timeout)';
  }
}
