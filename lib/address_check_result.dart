part of 'internet_connection_checker.dart';

/// Represents the result of an internet connection check.
///
/// This class encapsulates the outcome of an internet connection check
/// performed with a specific [AddressCheckOption].
class AddressCheckResult {
  /// Creates an [AddressCheckResult] instance.
  ///
  /// Represents the result of an internet connection check.
  ///
  /// This class encapsulates the outcome of an internet connection check
  /// performed with a specific [AddressCheckOption].
  AddressCheckResult({
    required this.option,
    required this.isSuccess,
  });

  /// The option used to check internet connection for this result.
  final AddressCheckOption option;

  /// The result of the internet connection check for the given [option].
  ///
  /// If `true`, then HEAD request to the given [option] was successful.
  /// Otherwise, it was unsuccessful.
  final bool isSuccess;

  @override
  String toString() {
    return 'AddressCheckResult(\n'
        '  option: ${option.toString().replaceAll('\n', '\n  ')},\n'
        '  isSuccess: $isSuccess\n'
        ')';
  }
}
