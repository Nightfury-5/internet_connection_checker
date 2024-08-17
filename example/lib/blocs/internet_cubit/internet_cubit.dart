// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetCubit extends Cubit<InternetConnectionStatus?> {
  late final StreamSubscription<InternetConnectionStatus> _subscription;

  InternetCubit() : super(null) {
    _subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      emit(status);
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
