// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class CheckConnectionOnceCubit extends Cubit<InternetConnectionStatus?> {
  CheckConnectionOnceCubit()
      : super(
          null,
        );

  void updateStatus(InternetConnectionStatus status) {
    emit(status);
  }
}
