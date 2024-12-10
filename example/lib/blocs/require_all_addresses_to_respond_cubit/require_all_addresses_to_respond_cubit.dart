// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// A `Cubit` that monitors the internet connection status using custom URLs.
///
/// This class is designed to continuously monitor internet connectivity
/// status by leveraging the `InternetConnectionChecker` package. It provides
/// updates on whether the device is connected to the internet and if all
/// specified addresses are reachable, based on the `requireAllAddressesToRespond`
/// configuration.
///
/// ### Features:
/// - Uses custom URLs for connectivity checks.
/// - Requires all specified addresses to respond successfully for a positive status.
/// - Emits the `InternetConnectionStatus` whenever a change in connectivity is detected.
/// - Ensures proper resource cleanup by disposing of connections and subscriptions when closed.
class RequireAllAddressesToRespondCubit
    extends Cubit<InternetConnectionStatus?> {
  /// A subscription to the connection status stream.
  ///
  /// This subscription listens to the status changes provided by
  /// the `InternetConnectionChecker` and emits those statuses to
  /// the listeners of this cubit.
  late final StreamSubscription<InternetConnectionStatus> _subscription;

  /// Holds the instance of `InternetConnectionChecker` to manage connectivity checks.
  late final InternetConnectionChecker _checker;

  /// Creates an instance of `RequireAllAddressesToRespondCubit`.
  ///
  /// The constructor initializes the cubit with a `null` state,
  /// indicating that no connectivity status has been checked yet.
  /// It also sets up an instance of `InternetConnectionChecker` configured
  /// with `requireAllAddressesToRespond` set to `true`, ensuring that all
  /// addresses specified are reachable to report the internet as available.
  ///
  /// ### Example Usage:
  /// ```dart
  /// final cubit = RequireAllAddressesToRespondCubit();
  /// cubit.stream.listen((status) {
  ///   print('Current Internet Status: \$status');
  /// });
  /// ```
  RequireAllAddressesToRespondCubit() : super(null) {
    _checker = InternetConnectionChecker.createInstance(
      requireAllAddressesToRespond: true,
    );
    _subscription = _checker.onStatusChange.listen((status) {
      emit(status);
    });
  }

  /// Closes the cubit and cleans up resources.
  ///
  /// This method ensures proper cleanup by canceling the connection status
  /// subscription, disposing of the `InternetConnectionChecker` instance,
  /// and finally closing the cubit. Always call this method when the cubit
  /// is no longer needed to avoid resource leaks.
  ///
  /// ### Example:
  /// ```dart
  /// await cubit.close();
  /// ```
  @override
  Future<void> close() {
    _subscription.cancel();
    _checker.dispose(); // Dispose of the InternetConnectionChecker instance
    return super.close();
  }
}
