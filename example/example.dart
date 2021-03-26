import 'dart:async';

import 'package:build/internet_connection_checker.dart';

Future<void> main() async {
  // Simple check to see if we have Internet
  print('The statement \'this machine is connected to the Internet\' is: ');
  final bool isConnected = await InternetConnectionChecker().hasConnection!;
  print(
    isConnected.toString(),
  );
  // returns a bool

  // We can also get an enum instead of a bool
  print(
      'Current status: ${await InternetConnectionChecker().connectionStatus}');
  // Prints either DataConnectionStatus.connected
  // or DataConnectionStatus.disconnected

  // This returns the last results from the last call
  // to either hasConnection or connectionStatus
  print('Last results: ${InternetConnectionChecker().lastTryResults}');

  // actively listen for status updates
  StreamSubscription<InternetConnectionStatus> listener =
      InternetConnectionChecker().onStatusChange!.listen(
    (InternetConnectionStatus status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          print('Data connection is available.');
          break;
        case InternetConnectionStatus.disconnected:
          print('You are disconnected from the internet.');
          break;
      }
    },
  );

  // close listener after 30 seconds, so the program doesn't run forever
  await Future<void>.delayed(const Duration(seconds: 30));
  await listener.cancel();
}
