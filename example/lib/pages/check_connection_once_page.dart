// Flutter Packages

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

// Project imports:
import 'package:internet_connection_checker_example/bloc/check_connection_once_cubit/check_connection_once_cubit.dart';

class CheckConnectionOncePage extends StatefulWidget {
  const CheckConnectionOncePage({super.key});

  @override
  State<CheckConnectionOncePage> createState() =>
      _CheckConnectionOncePageState();
}

class _CheckConnectionOncePageState extends State<CheckConnectionOncePage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final InternetConnectionStatus status =
        await InternetConnectionChecker().internetStatus;
    if (!mounted) return;
    context.read<CheckConnectionOnceCubit>().updateStatus(status);
  }

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
                  return BlocBuilder<CheckConnectionOnceCubit,
                      InternetConnectionStatus?>(
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
