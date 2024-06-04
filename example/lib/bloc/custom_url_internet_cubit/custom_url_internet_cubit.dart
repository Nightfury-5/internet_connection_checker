// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class CustomUrlInternetCubit extends Cubit<InternetConnectionStatus?> {
  late final StreamSubscription<InternetConnectionStatus> _subscription;

  CustomUrlInternetCubit() : super(null) {
    _subscription = InternetConnectionChecker.createInstance(
      customCheckOptions: [
        AddressCheckOption(uri: Uri.parse('https://icanhazip.com')),
        AddressCheckOption(
          uri: Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
        ),
      ],
      useDefaultOptions: false,
    ).onStatusChange.listen((status) {
      emit(status);
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
