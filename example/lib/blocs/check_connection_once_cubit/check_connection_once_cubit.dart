// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

/// A simple `Cubit` that manages the connection status of a device.
///
/// The `CheckConnectionOnceCubit` class is designed to check and update the
/// internet connection status once. It emits a `bool` value indicating
/// whether the device is connected (`true`) or not (`false`).
/// The initial state is set to `null`, meaning the status hasn't been checked yet.
class CheckConnectionOnceCubit extends Cubit<bool?> {
  /// Creates an instance of `CheckConnectionOnceCubit`.
  ///
  /// The constructor initializes the cubit with an initial state of `null`.
  CheckConnectionOnceCubit() : super(null);

  /// Updates the connection status.
  ///
  /// This method takes a `bool` value as an argument, which represents the
  /// connection status of the device (`true` for connected, `false` for
  /// disconnected). The status is then emitted to the cubit's listeners.
  ///
  /// *Parameters:*
  /// - `status`: A `bool` representing the current connection status.
  void updateStatus(bool status) {
    emit(status);
  }
}
