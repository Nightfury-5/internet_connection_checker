// Dart Packages
import 'dart:async';

// Flutter Packages
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

// This Package

class CustomURIs extends StatefulWidget {
  const CustomURIs({super.key});

  @override
  State<CustomURIs> createState() => _CustomURIsState();
}

class _CustomURIsState extends State<CustomURIs> {
  InternetConnectionStatus? _connectionStatus;
  late StreamSubscription<InternetConnectionStatus> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = InternetConnectionChecker.createInstance(
      customCheckOptions: [
        AddressCheckOption(uri: Uri.parse('https://icanhazip.com')),
        AddressCheckOption(
          uri: Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
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
