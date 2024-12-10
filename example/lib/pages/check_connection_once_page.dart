// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

// Project imports:
import 'package:internet_connection_checker_example/blocs/check_connection_once_cubit/check_connection_once_cubit.dart';

/// A `StatefulWidget` that checks the internet connection status once upon initialization.
///
/// The `CheckConnectionOncePage` class is a `StatefulWidget` that demonstrates
/// how to check the internet connection status a single time when the widget
/// is initialized. It does not actively listen for changes in connection status
/// after the initial check.
class CheckConnectionOncePage extends StatefulWidget {
  const CheckConnectionOncePage({super.key});

  @override
  State<CheckConnectionOncePage> createState() =>
      _CheckConnectionOncePageState();
}

class _CheckConnectionOncePageState extends State<CheckConnectionOncePage> {
  /// Initializes the state of the widget and checks the internet connection status once.
  ///
  /// The `initState` method calls the `_init` method to check the internet
  /// connection status using `InternetConnectionChecker`. It then updates the
  /// `CheckConnectionOnceCubit` with the result of the check.
  @override
  void initState() {
    super.initState();
    _init();
  }

  /// Checks the internet connection status and updates the cubit.
  ///
  /// The `_init` method uses the `InternetConnectionChecker` package to check
  /// whether the device is connected to the internet. It then updates the
  /// `CheckConnectionOnceCubit` with the connection status. This check is done
  /// only once when the widget is initialized.
  ///
  /// If the widget is not mounted after the connection check completes, it
  /// prevents the cubit from being updated.
  Future<void> _init() async {
    final bool isConnected =
        await InternetConnectionChecker.instance.hasConnection;
    if (!mounted) return;
    context.read<CheckConnectionOnceCubit>().updateStatus(isConnected);
  }

  /// Builds the UI of the `CheckConnectionOncePage`.
  ///
  /// The `build` method constructs a simple UI that displays a message explaining
  /// that the connection status is only checked once, and shows the result of
  /// the connection status check. The result is displayed using a `BlocBuilder`
  /// that listens to the state of the `CheckConnectionOnceCubit`.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listen Once'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'This page illustrates how to listen for the internet connection '
                'status ONLY once.\n\n'
                'The status is validated once when the widget is initialized.\n\n'
                'Any changes to the internet connection status will not be '
                'reflected in this scenario.',
                textAlign: TextAlign.center,
              ),
              const Divider(
                height: 48.0,
                thickness: 2.0,
              ),
              const Text('Connection Status:'),
              Builder(
                builder: (context) {
                  return BlocBuilder<CheckConnectionOnceCubit, bool?>(
                    builder: (context, state) {
                      return state == null
                          ? const CircularProgressIndicator.adaptive()
                          : Text(
                              state.toString(),
                              style: Theme.of(context).textTheme.headlineSmall,
                            );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
