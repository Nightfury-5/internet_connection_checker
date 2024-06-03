// Dart Packages
import 'dart:async';

// Flutter Packages
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

// This Package

class CustomSuccessCriteria extends StatefulWidget {
  const CustomSuccessCriteria({super.key});

  @override
  State<CustomSuccessCriteria> createState() => _CustomSuccessCriteriaState();
}

class _CustomSuccessCriteriaState extends State<CustomSuccessCriteria> {
  InternetConnectionStatus? _connectionStatus;
  late StreamSubscription<InternetConnectionStatus> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = InternetConnectionChecker.createInstance(
      customCheckOptions: [
        AddressCheckOption(
          uri: Uri.parse('https://img.shields.io/pub/'),
          responseStatusFn: (response) {
            return response.statusCode == 404;
          },
        ),
      ],
      useDefaultOptions: false,
    ).onStatusChange.listen((status) {
      setState(() {
        _connectionStatus = status;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

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
              _connectionStatus == null
                  ? const CircularProgressIndicator.adaptive()
                  : Text(
                      _connectionStatus.toString(),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
