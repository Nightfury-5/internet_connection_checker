// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckConnectionOnceCubit extends Cubit<bool?> {
  CheckConnectionOnceCubit()
      : super(
          null,
        );

  void updateStatus(bool status) {
    emit(status);
  }
}
