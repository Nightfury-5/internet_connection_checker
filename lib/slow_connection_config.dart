part of 'internet_connection_checker.dart';

/// Configuration options for detecting slow internet connections.
///
/// The `SlowConnectionConfig` class allows you to specify settings for
/// detecting slow internet connections. This includes whether to enable slow
/// connection detection and the threshold duration that defines a "slow"
/// connection.
///
/// *Example Usage:*
///
/// ```dart
/// final config = SlowConnectionConfig(
///   enableToCheckForSlowConnection: true,
///   slowConnectionThreshold: Duration(seconds: 3),
/// );
/// ```
class SlowConnectionConfig extends Equatable {
  /// Creates an instance of `SlowConnectionConfig`.
  ///
  /// The [enableToCheckForSlowConnection] parameter specifies whether the
  /// slow connection detection should be enabled. It defaults to `false`.
  /// The [slowConnectionThreshold] parameter defines the threshold duration
  /// that qualifies a connection as "slow". It defaults to `2` seconds.
  ///
  /// *Example:*
  ///
  /// ```dart
  /// final config = SlowConnectionConfig(
  ///   enableToCheckForSlowConnection: true,
  ///   slowConnectionThreshold: Duration(seconds: 5),
  /// );
  /// ```
  const SlowConnectionConfig({
    this.enableToCheckForSlowConnection = false,
    this.slowConnectionThreshold =
        InternetConnectionChecker.DEFAULT_SLOW_CONNECTION_THRESHOLD,
  });

  /// Whether to enable slow connection detection.
  ///
  /// If `true`, the checker will consider the connection as "slow" if the
  /// response time exceeds the specified [slowConnectionThreshold].
  /// If `false`, slow connection detection is disabled.
  final bool enableToCheckForSlowConnection;

  /// The threshold duration that defines a "slow" connection.
  ///
  /// A connection is considered slow if the response time
  /// exceeds this duration.
  /// The default threshold is `2` seconds.
  final Duration slowConnectionThreshold;

  /// Properties to compare instances of `SlowConnectionConfig`.
  ///
  /// This list is used by `Equatable` to determine whether two instances
  /// of this class are considered equal.
  @override
  List<Object?> get props => <Object?>[
        enableToCheckForSlowConnection,
        slowConnectionThreshold,
      ];

  /// A custom string representation for debugging purposes.
  ///
  /// When you print an instance of `SlowConnectionConfig`, this
  /// method will provide a readable format of its values.
  @override
  String toString() {
    return '''SlowConnectionConfig(enableToCheckForSlowConnection: $enableToCheckForSlowConnection, slowConnectionThreshold: $slowConnectionThreshold)''';
  }
}
