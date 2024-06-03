// Flutter Packages
import 'package:flutter/material.dart';

// Pages
import 'pages/custom_success_criteria.dart';
import 'pages/custom_uris.dart';
import 'pages/listen_once.dart';
import 'pages/listen_to_stream.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Internet Connection Checker Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final pages = {
    'Listen Once': const ListenOnce(),
    'Listen to Stream': const ListenToStream(),
    'Custom URIs': const CustomURIs(),
    'Custom Success Criteria': const CustomSuccessCriteria(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                    builder: (context) => entry.value,
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
