// Dart Packages

// Flutter Packages

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

// Project imports:
import 'package:internet_connection_checker_example/blocs/custom_response_internet_cubit/custom_response_internet_cubit.dart';

// This Package

class CustomResponseInternetCheckerPage extends StatefulWidget {
  const CustomResponseInternetCheckerPage({super.key});

  @override
  State<CustomResponseInternetCheckerPage> createState() =>
      _CustomResponseInternetCheckerPageState();
}

class _CustomResponseInternetCheckerPageState
    extends State<CustomResponseInternetCheckerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Success Criteria'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'This example shows how to use custom success criteria to check '
                'the internet connection status.\n\n'
                'In this example, the success criteria is that the response '
                'status code should be 404.',
                textAlign: TextAlign.center,
              ),
              const Divider(
                height: 48.0,
                thickness: 2.0,
              ),
              const Text('Connection Status:'),
              BlocBuilder<CustomResponseInternetCubit,
                  InternetConnectionStatus?>(
                builder: (context, state) {
                  return state == null
                      ? const CircularProgressIndicator.adaptive()
                      : Text(
                          state.toString(),
                          style: Theme.of(context).textTheme.headlineSmall,
                        );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
