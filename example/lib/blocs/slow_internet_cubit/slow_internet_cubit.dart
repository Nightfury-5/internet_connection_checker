// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// A `Cubit` that monitors the internet connection status with a focus on slow connections.
///
/// The `SlowInternetCubit` class is designed to monitor the internet connection
/// status using the `InternetConnectionChecker` package, with an emphasis on detecting
/// slow connections. It emits an `InternetConnectionStatus` value, which can indicate
/// whether the device is connected, disconnected, or experiencing a slow connection.
/// The initial state is set to `null`, indicating that the connection status has not been
/// determined yet.
class SlowInternetCubit extends Cubit<InternetConnectionStatus?> {
  /// A subscription to the connection status stream.
  ///
  /// This subscription listens to status changes from the `InternetConnectionChecker` and
  /// updates the cubit's state accordingly. It is configured to specifically check for slow
  /// connections.
  late final StreamSubscription<InternetConnectionStatus> _subscription;

  /// Holds the instance of `InternetConnectionChecker` to be disposed of.
  late final InternetConnectionChecker _checker;

  /// Creates an instance of `SlowInternetCubit`.
  ///
  /// The constructor initializes the cubit with an initial state of `null`.
  /// It sets up a custom `InternetConnectionChecker` instance that is configured to
  /// detect slow internet connections. The `slowConnectionConfig` is set to check for
  /// slow connections with a threshold of 1 second. The connection status is monitored,
  /// and any changes are emitted to the cubit's listeners.

  SlowInternetCubit() : super(null) {
    _checker = InternetConnectionChecker.createInstance(
      slowConnectionConfig: const SlowConnectionConfig(
        enableToCheckForSlowConnection: true,
        slowConnectionThreshold: Duration(seconds: 1),
      ),
    );
    _subscription = _checker.onStatusChange.listen((status) {
      emit(status);
    });
  }

  /// Closes the cubit and cancels the subscription.
  ///
  /// This method cancels the subscription to the connection status stream
  /// and then calls the `super.close()` method to close the cubit. This
  /// ensures that no resources are leaked when the cubit is no longer in use.
  @override
  Future<void> close() {
    _subscription.cancel();
    _checker.dispose();
    return super.close();
  }
}
