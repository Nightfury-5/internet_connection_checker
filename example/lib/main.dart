// Flutter Packages

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:internet_connection_checker_example/blocs/check_connection_once_cubit/check_connection_once_cubit.dart';
import 'package:internet_connection_checker_example/blocs/custom_response_internet_cubit/custom_response_internet_cubit.dart';
import 'package:internet_connection_checker_example/blocs/custom_url_internet_cubit/custom_url_internet_cubit.dart';
import 'package:internet_connection_checker_example/blocs/fetch_todos_cubit/fetch_todos_cubit.dart';
import 'package:internet_connection_checker_example/blocs/internet_cubit/internet_cubit.dart';
import 'package:internet_connection_checker_example/pages/auto_refresh_when_network_is_available_page.dart';
import 'package:internet_connection_checker_example/pages/connection_stream_listener_page.dart';
import 'pages/check_connection_once_page.dart';
import 'pages/custom_response_internet_checker_page.dart';
import 'pages/custom_uri_internet_connection_checker_page.dart';

// Pages

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Internet Connection Checker Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final Map<String, Widget> pages = <String, Widget>{
    'Listen to Stream': const ConnectionStreamListenerPage(),
    'Custom URL Internet Connnectuon':
        const CustomURIInternetConnectionCheckerPage(),
    'Custom Success Criteria': const CustomResponseInternetCheckerPage(),
    'Check Connection Once': const CheckConnectionOncePage(),
    'Bloc/Cubit Example Auto Refresh when network is available':
        const AutoRefreshWhenNetworkIsAvailablePage(),
  };

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
          children: pages.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (_) => CheckConnectionOnceCubit(),
                        ),
                        BlocProvider(
                          create: (_) => InternetCubit(),
                        ),
                        BlocProvider(
                          create: (_) => CustomUrlInternetCubit(),
                        ),
                        BlocProvider(
                          create: (_) => CustomResponseInternetCubit(),
                        ),
                        BlocProvider(
                          create: (_) => FetchTodosCubit(
                            internetCubit: InternetCubit(),
                          )..fetchTodos(),
                        ),
                      ],
                      child: entry.value,
                    ),
                  ),
                ),
                child: Text(entry.key),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
