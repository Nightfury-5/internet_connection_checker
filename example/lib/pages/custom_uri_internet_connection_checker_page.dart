// Dart Packages

// Flutter Packages

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

// Project imports:
import 'package:internet_connection_checker_example/bloc/internet_cubit/internet_cubit.dart';

// This Package

class CustomURIInternetConnectionCheckerPage extends StatelessWidget {
  const CustomURIInternetConnectionCheckerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom URIs'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'This example shows how to use custom URIs to check the internet '
                'connection status.',
                textAlign: TextAlign.center,
              ),
              const Divider(
                height: 48.0,
                thickness: 2.0,
              ),
              const Text('Connection Status:'),
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
