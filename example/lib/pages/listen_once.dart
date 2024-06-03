// Flutter Packages
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ListenOnce extends StatefulWidget {
  const ListenOnce({super.key});

  @override
  State<ListenOnce> createState() => _ListenOnceState();
}

class _ListenOnceState extends State<ListenOnce> {
  InternetConnectionStatus? _connectionStatus;

  @override
  void initState() {
    super.initState();
    InternetConnectionChecker().internetStatus.then((status) {
      setState(() {
        _connectionStatus = status;
      });
    });
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
                'This piece of code illustrates how to listen for the internet connection '
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
