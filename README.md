# 🌍 Internet Connection Checker

[![Dart CI](https://github.com/RounakTadvi/internet_connection_checker/actions/workflows/main.yaml/badge.svg)](https://github.com/RounakTadvi/internet_connection_checker/actions/workflows/main.yaml)
[![codecov](https://codecov.io/gh/RounakTadvi/internet_connection_checker/branch/main/graph/badge.svg)](https://codecov.io/gh/RounakTadvi/internet_connection_checker)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

  A library designed for seamless internet connectivity checks. 
  This library enables you to verify your internet connection.

### Table of contents

- [🌍 Internet Connection Checker](#-internet-connection-checker)
    - [Table of contents](#table-of-contents)
  - [Description](#description)
  - [Demo](#demo)
  - [Quick start](#quick-start)
  - [Purpose](#purpose)
  - [Getting Started](#getting-started)
    - [Singleton example](#singleton-basic-usage-example)
    - [Internet Connection Availability changes](#listen-to-stream-for-internet-connection-availability-changes)
    - [Creating a Custom Instance](#creating-a-custom-instance)
    - [Custom Response Code Logic](#custom-response-code-logic)
  - [Features and bugs](#features-and-bugs)

## Description

Checks for an internet (data) connection, by checking accessible Uri's.

The defaults of the plugin should be sufficient to reliably determine if
the device is currently connected to the global network, e.i. has access to the Internet.

### Platform Support

| Android | iOS | MacOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✅    | ✅  |  ✅   | ✅  |  ✅   |   ✅    |

## Demo

<video width="" height="" controls>
  <source src="https://raw.githubusercontent.com/RounakTadvi/internet_connection_checker/release/2.0.0/assets/demo.mp4" type="video/mp4">
</video>

## Quick start

Add the following dependencies to your `pubspec.yaml`:

```
dependencies:
  internet_connection_checker: ^2.0.0
```

## Android Configuration

On Android, for correct working in release mode, you must add INTERNET & ACCESS_NETWORK_STATE 
permissions to AndroidManifest.xml, follow the next lines:

```dart
    <manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Permissions for internet_connection_checker -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    
    <application
        ...
```

## Purpose

The reason this package exists is that `connectivity_plus` package cannot reliably determine if a data connection is actually available. More info on its page here: <https://pub.dev/packages/connectivity_plus>.

## Getting Started

The `InternetConnectionChecker` can be used as a singleton or can be instantiated with a custom instance with your curated `AddressCheckOption`'s.

### Best usage with Flutter Bloc/Cubit

The InternetConnectionChecker package is particularly useful in scenarios where you need to handle changes in network connectivity dynamically. For instance, you can use it to refresh the page or trigger specific actions when the device goes offline and then reconnects to the internet. This is useful for applications where real-time updates or data synchronization is critical.

See `example` folder for one specific example which illustrates how to retry page refresh when internet connection is available. The example files paths are listed below:

```
example/lib/blocs/fetch_todos_cubit.dart
example/lib/pages/auto_refresh_when_network_is_available_page.dart
```

### Singleton Basic Usage example

```dart
import 'package:internet_connection_checker/internet_connection_checker.dart';

void main() async {
  bool isConnected = await InternetConnectionChecker().hasConnection;
  if (isConnected) {
    print('Device is connected to the internet');
  } else {
    print('Device is not connected to the internet');
  }
}

```

### Listen to Stream for Internet Connection availability changes:

```dart
import 'package:internet_connection_checker/internet_connection_checker.dart';

void main() {
  final connectionChecker = InternetConnectionChecker();

  final subscription = connectionChecker.onStatusChange.listen(
    (InternetConnectionStatus status) {
      if (status == InternetConnectionStatus.connected) {
        print('Connected to the internet');
      } else {
        print('Disconnected from the internet');
      }
    },
  );

  // Remember to cancel the subscription when it's no longer needed
  subscription.cancel();
}

```

*Note: Remember to dispose of any listeners,
when they're not needed to prevent memory leaks,
e.g. in a* `StatefulWidget`'s *dispose() method*:
  
```dart
...
@override
void dispose() {
  listener.cancel();
  super.dispose();
}
...
```

### Creating a Custom Instance

To create a custom instance of InternetConnectionChecker with specific check options:

```dart
import 'package:internet_connection_checker/internet_connection_checker.dart';

void main() async {
  final customChecker = InternetConnectionChecker.createInstance(
    customCheckOptions: [
      AddressCheckOption(uri: Uri.parse('https://1.1.1.1')),
      AddressCheckOption(
        uri: Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
      ),
    ],
    useDefaultOptions: false,
  );

  bool isConnected = await customChecker.hasConnection;
  print('Custom instance connected: $isConnected');
}

```

### Custom Response Code Logic

```dart

import 'package:internet_connection_checker/internet_connection_checker.dart';

void main() async {
  final customChecker = InternetConnectionChecker.createInstance(
    customCheckOptions: [
      AddressCheckOption(
        uri: Uri.parse('https://img.shields.io/pub/'),
        responseStatusFn: (response) {
          return response.statusCode == 404;
        },
      ),
    ],
    useDefaultOptions: false,
  );

  bool isConnected = await customChecker.hasConnection;
  print('Custom response logic connected: $isConnected');
}


```

See `example` folder for more examples.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][issues_tracker].

[issues_tracker]: https://github.com/RounakTadvi/internet_connection_checker/issues
[pull_requests]: https://github.com/RounakTadvi/internet_connection_checker/pulls

# Credits
>* NOTE: This package is a continuation of [data_connection_checker](https://github.com/komapeb/data_connection_checker) which currently is not continued. * 