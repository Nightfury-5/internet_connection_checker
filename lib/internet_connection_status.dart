part of 'internet_connection_checker.dart';

/// Represents the status of the data connection.
// ignore: comment_references
/// Returned by [InternetConnectionChecker.connectionStatus]
enum InternetConnectionStatus {
  /// connected to internet
  connected,

  /// disconnected from internet
  disconnected,

  /// slow internet
  slow,
}
