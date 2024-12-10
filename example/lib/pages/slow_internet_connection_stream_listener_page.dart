// Dart Packages

// Flutter Packages

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

// Project imports:
import 'package:internet_connection_checker_example/blocs/slow_internet_cubit/slow_internet_cubit.dart';

/// A `StatelessWidget` that listens to the internet connection status with a focus on slow connections.
///
/// The `SlowInternetConnectionStreamListenerPage` class is a `StatelessWidget` that
/// demonstrates how to continuously listen for changes in the internet connection status
/// using a `StreamSubscription`, with specific attention to detecting slow connections.
/// The current connection status is displayed in real-time as it changes, including
/// indications of slow connections.
class SlowInternetConnectionStreamListenerPage extends StatelessWidget {
  const SlowInternetConnectionStreamListenerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Stream Listener'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'This page illustrates how to listen for the internet connection '
                'status using a StreamSubscription.\n\n'
                'Changes to the internet connection status are listened to and '
                'reflected in this example.',
                textAlign: TextAlign.center,
              ),
              const Divider(
                height: 48.0,
                thickness: 2.0,
              ),
              const Text('Connection Status:'),
              // BlocBuilder listens to the SlowInternetCubit to reflect the current connection status
              BlocBuilder<SlowInternetCubit, InternetConnectionStatus?>(
                builder: (context, connectionStatus) {
                  if (connectionStatus == null) {
                    return const CircularProgressIndicator.adaptive();
                  }
                  return Text(
                    connectionStatus.toString(),
                    style: Theme.of(context).textTheme.headlineSmall,
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
