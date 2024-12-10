// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:internet_connection_checker_example/blocs/check_connection_once_cubit/check_connection_once_cubit.dart';
import 'package:internet_connection_checker_example/blocs/custom_url_internet_cubit/custom_url_internet_cubit.dart';
import 'package:internet_connection_checker_example/blocs/fetch_todos_cubit/fetch_todos_cubit.dart';
import 'package:internet_connection_checker_example/blocs/internet_cubit/internet_cubit.dart';
import 'package:internet_connection_checker_example/blocs/require_all_addresses_to_respond_cubit/require_all_addresses_to_respond_cubit.dart';
import 'package:internet_connection_checker_example/blocs/slow_internet_cubit/slow_internet_cubit.dart';
import 'package:internet_connection_checker_example/pages/auto_refresh_when_network_is_available_page.dart';
import 'package:internet_connection_checker_example/pages/connection_stream_listener_page.dart';
import 'package:internet_connection_checker_example/pages/require_all_addresses_to_respond_page.dart';
import 'package:internet_connection_checker_example/pages/slow_internet_connection_stream_listener_page.dart';
import 'pages/check_connection_once_page.dart';
import 'pages/custom_uri_internet_connection_checker_page.dart';

// Pages

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => InternetCubit(),
        ),
        BlocProvider(
          create: (_) => CustomUrlInternetCubit(),
        ),
        BlocProvider(
          create: (_) => RequireAllAddressesToRespondCubit(),
        ),
        BlocProvider(
          create: (_) => CheckConnectionOnceCubit(),
        ),
        BlocProvider(
          create: (_) => FetchTodosCubit(
            internetCubit: InternetCubit(),
          )..fetchTodos(),
        ),
        BlocProvider(
          create: (_) => SlowInternetCubit(),
        ),
      ],
      child: const MaterialApp(
        title: 'Internet Connection Checker Demo',
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Internet Connection Checker Demo',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ConnectionStreamListenerPage(),
                  ),
                ),
                child: const Text('Listen to Stream'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const CustomURIInternetConnectionCheckerPage(),
                  ),
                ),
                child: const Text('Custom URL Internet Connection'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CheckConnectionOncePage(),
                  ),
                ),
                child: const Text('Check Connection Once'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const AutoRefreshWhenNetworkIsAvailablePage(),
                  ),
                ),
                child: const Text(
                    'Bloc/Cubit Example Auto Refresh when network is available'),
              ),
            ),

            /// Test 3G Throttling mode in Flutter Web Chrome to
            /// simulate below example of [SlowInternetConnectionStreamListenerPage]
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const SlowInternetConnectionStreamListenerPage(),
                  ),
                ),
                child: const Text('Slow Internet Connection Stream'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const RequireAllAddressesToRespondPage(),
                  ),
                ),
                child: const Text('Require All Addresses To Respond Example'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
