// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// A `Cubit` that monitors the internet connection status.
///
/// The `InternetCubit` class is designed to monitor the internet connection
/// status using the `InternetConnectionChecker` package. It emits an
/// `InternetConnectionStatus` value, which indicates whether the device
/// is connected to the internet, disconnected, or experiencing a slow
/// connection. The initial state is set to `null`, indicating that the
/// connection status has not been determined yet.
class InternetCubit extends Cubit<InternetConnectionStatus?> {
  /// A subscription to the connection status stream.
  ///
  /// This subscription listens to the status changes from the
  /// `InternetConnectionChecker` and updates the cubit's state accordingly.
  late final StreamSubscription<InternetConnectionStatus> _subscription;

  /// Holds the instance of `InternetConnectionChecker` to be disposed of.
  late final InternetConnectionChecker _checker;

  /// Creates an instance of `InternetCubit`.
  ///
  /// The constructor initializes the cubit with an initial state of `null`.
  /// It sets up an `InternetConnectionChecker` instance and subscribes to its
  /// `onStatusChange` stream to listen for internet connection status updates.
  /// The appropriate status is then emitted to the cubit's listeners.
  InternetCubit() : super(null) {
    _checker = InternetConnectionChecker.instance;
    _subscription = _checker.onStatusChange.listen((status) {
      emit(status);
    });
  }

  /// Closes the cubit, cancels the subscription, and disposes of the checker.
  ///
  /// This method cancels the subscription to the connection status stream,
  /// disposes of the `InternetConnectionChecker` instance, and then calls
  /// the `super.close()` method to close the cubit. This ensures that no
  /// resources are leaked when the cubit is no longer in use.
  @override
  Future<void> close() {
    _subscription.cancel();
    _checker.dispose(); // Dispose of the InternetConnectionChecker instance
    return super.close();
  }
}
