// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// A `Cubit` that monitors the internet connection status using custom URLs.
///
/// The `CustomUrlInternetCubit` class is designed to check the internet
/// connection status by pinging custom URLs. It uses the
/// `InternetConnectionChecker` package to monitor the connection status and
/// emits an `InternetConnectionStatus` value indicating the current status.
/// The initial state is set to `null`, meaning the status hasn't been checked yet.
class CustomUrlInternetCubit extends Cubit<InternetConnectionStatus?> {
  /// A subscription to the connection status stream.
  ///
  /// This subscription listens to the status changes from the
  /// `InternetConnectionChecker` and updates the cubit's state accordingly.
  late final StreamSubscription<InternetConnectionStatus> _subscription;

  /// Holds the instance of `InternetConnectionChecker` to be disposed of.
  late final InternetConnectionChecker _checker;

  /// Creates an instance of `CustomUrlInternetCubit`.
  ///
  /// The constructor initializes the cubit with an initial state of `null`.
  /// It sets up a custom `InternetConnectionChecker` instance that checks
  /// the connection against two specific URLs. The connection status is
  /// monitored, and any changes are emitted to the cubit's listeners.
  CustomUrlInternetCubit() : super(null) {
    _checker = InternetConnectionChecker.createInstance(
      addresses: [
        AddressCheckOption(
            uri: Uri.parse('https://api.github.com/users/octocat')),
        AddressCheckOption(
          uri: Uri.parse('https://api.agify.io/?name=michael'),
        ),
      ],
    );
    _subscription = _checker.onStatusChange.listen((status) {
      emit(status);
    });
  }

  /// Closes the cubit and cancels the subscription.
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
