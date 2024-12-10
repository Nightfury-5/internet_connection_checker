import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:internet_connection_checker_example/blocs/internet_cubit/internet_cubit.dart';

/// A `StatelessWidget` that listens to the internet connection status using a `StreamSubscription`.
///
/// The `ConnectionStreamListenerPage` class is a `StatelessWidget` that demonstrates
/// how to continuously listen for changes in the internet connection status using a
/// `StreamSubscription`. The current connection status is displayed in real-time as it changes.
class ConnectionStreamListenerPage extends StatelessWidget {
  const ConnectionStreamListenerPage({super.key});

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
              // BlocBuilder listens to the InternetCubit to reflect the current connection status
              BlocBuilder<InternetCubit, InternetConnectionStatus?>(
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
