part of 'internet_connection_checker.dart';

/// Represents the outcome of an internet connection check using a specific
/// [AddressCheckOption].
///
/// The `AddressCheckResult` class encapsulates whether the internet connection
/// check for a given address was successful or not. It is particularly useful
/// when you want to keep track of which `AddressCheckOption` was used and
/// whether the connection attempt was successful.
///
/// *Example Usage:*
///
/// ```dart
/// final result = AddressCheckResult(
///   option: AddressCheckOption(
///     uri: Uri.parse('https://example.com'),
///     timeout: Duration(seconds: 5),
///   ),
///   isSuccess: true,
/// );
/// ```
class AddressCheckResult extends Equatable {
  /// Creates an instance of `AddressCheckResult`.
  ///
  /// The [option] parameter specifies the `AddressCheckOption` used for the
  /// internet connection check, while the [isSuccess] parameter indicates
  /// whether the connection check was successful (`true`) or not (`false`).
  const AddressCheckResult(this.option, {required this.isSuccess});

  /// The `AddressCheckOption` used to check the internet connection.
  ///
  /// This property holds the configuration that was applied during the
  /// internet connection check.
  final AddressCheckOption option;

  /// Indicates whether the internet connection check was successful.
  ///
  /// If `true`, the connection check using the given [option] was successful.
  /// Otherwise, it was unsuccessful.
  final bool isSuccess;

  /// Properties to compare instances of `AddressCheckResult`.
  ///
  /// This list is used by `Equatable` to determine whether two instances
  /// of this class are considered equal.
  @override
  List<Object?> get props => <Object?>[
        option,
        isSuccess,
      ];

  /// A custom string representation for debugging purposes.
  ///
  /// When you print an instance of `AddressCheckResult`, this method will
  /// provide a readable format of its values, including the `options` used
  /// and whether the connection check was successful.
  @override
  String toString() {
    return 'AddressCheckResult(option: $option, isSuccess: $isSuccess)';
  }
}
