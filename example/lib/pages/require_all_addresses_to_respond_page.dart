import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:internet_connection_checker_example/blocs/require_all_addresses_to_respond_cubit/require_all_addresses_to_respond_cubit.dart';

/// A Flutter UI to demonstrate the usage of `RequireAllAddressesToRespondCubit`.
///
/// This widget shows the real-time internet connection status using the cubit.
class RequireAllAddressesToRespondPage extends StatelessWidget {
  const RequireAllAddressesToRespondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internet Connection Status'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'This page demonstrates the use of the RequireAllAddressesToRespondCubit.\n\n'
                'The cubit monitors the internet connection status and ensures all addresses are reachable.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Current Connection Status:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              BlocBuilder<RequireAllAddressesToRespondCubit,
                  InternetConnectionStatus?>(
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
