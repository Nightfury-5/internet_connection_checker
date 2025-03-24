# 🌍 Internet Connection Checker

[![Dart CI](https://github.com/RounakTadvi/internet_connection_checker/actions/workflows/main.yaml/badge.svg)](https://github.com/RounakTadvi/internet_connection_checker/actions/workflows/main.yaml)
[![codecov](https://codecov.io/gh/RounakTadvi/internet_connection_checker/branch/main/graph/badge.svg)](https://codecov.io/gh/RounakTadvi/internet_connection_checker)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License: BSD 3-Clause](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)


  A library designed for seamless internet connectivity checks. 
  This library enables you to verify your internet connection
  and can also detect slow internet connectivity.

### Table of contents

- [🌍 Internet Connection Checker](#-internet-connection-checker)
    - [Table of contents](#table-of-contents)
  - [Usecases](#usecases-of-this-library)
  - [Description](#description)
  - [Demo](#demo)
  - [Quick start](#quick-start)
  - [Purpose](#purpose)
  - [Getting Started](#getting-started)
    - [Singleton example](#singleton-basic-usage-example)
    - [Internet Connection Availability changes](#listen-to-stream-for-internet-connection-availability-changes)
    - [Creating a Custom Instance](#creating-a-custom-instance)
    - [Slow Internet Connectivity detection ](#enable-detection-for-slow-internet-connectivity)
    - [Using requireAllAddressesToRespond ](#Using-requirealladdressestorespond)  
  - [Features and bugs](#features-and-bugs)

## Usecases of this library:

- **Backend Server Checks**: 
Seamlessly verify internet connectivity and server reachability using built-in default addresses or by configuring custom backend server URLs tailored to your application needs.

- **Slow Internet Detection**: 
Efficiently detect and manage slow internet connections on the user's device to ensure a smooth user experience.

- **Auto Refresh**: 
 Automatically refresh pages in your app when the internet becomes available, providing a dynamic and seamless user experience.  

  For detailed implementation, refer to the example files:  
  ```
  example/lib/blocs/fetch_todos_cubit.dart
  example/lib/pages/auto_refresh_when_network_is_available_page.dart
  ```

### 💡 Important Note  
To prevent memory leaks, always dispose of the `InternetConnectionChecker` instance when it's no longer needed. For example, in a `StatefulWidget`'s `dispose` method:

```dart
@override
void dispose() {
  connectionChecker.dispose(); // Dispose of the InternetConnectionChecker instance
  super.dispose();
}
```

## Description

Checks for an internet (data) connection, by checking accessible Uri's.

The defaults of the plugin should be sufficient to reliably determine if
the device is currently connected to the global network, e.i. has access to the Internet.

### Platform Support

| Android | iOS | MacOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✅    | ✅  |  ✅   | ✅  |  ✅   |   ✅    |

## Demo

![Demo](https://raw.githubusercontent.com/RounakTadvi/internet_connection_checker/release/2.0.0/assets/demo_video.gif?raw=true)

## Quick start

Add the following dependencies to your `pubspec.yaml`:

```
dependencies:
  internet_connection_checker: ^3.0.0
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

## Mac OS Configuration

On MacOS, you'll need to add the following entry to your ```DebugProfile.entitlements``` and ```Release.entitlements``` (located under macos/Runner) to allow access to internet.

```dart
  <key>com.apple.security.network.server</key>
  <true/>
```

Example:

```dart
  <plist version="1.0">
    <dict>
	    <key>com.apple.security.app-sandbox</key>
	    <true/>
    </dict>
  </plist>
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
  final bool isConnected = await InternetConnectionChecker.instance.hasConnection;
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
  final connectionChecker = InternetConnectionChecker.instance;

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

*Note: Remember to dispose of any listeners and the instance of InternetConnectionChecker,
when they're not required to prevent memory leaks.
e.g. in a* `StatefulWidget`'s *dispose() method*:
  
```dart
...
@override
void dispose() {
  listener.cancel();
  connectionChecker.dispose();
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
    addresses: [
      AddressCheckOption(uri: Uri.parse('https://api.github.com/users/octocat')),
      AddressCheckOption(
        uri: Uri.parse('https://api.agify.io/?name=michael'),
      ),
    ],
  );

  bool isConnected = await customChecker.hasConnection;
  print('Custom instance connected: $isConnected');
}

```
*Note: Remember to dispose of InternetConnectionChecker instance,
when it's not needed to prevent memory leaks,
e.g. in a* `StatefulWidget`'s *dispose() method*:
  
```dart
...
@override
void dispose() {
  super.dispose();
  customChecker.dispose();
}
...
```

### Enable detection for slow internet connectivity

To create a custom instance of InternetConnectionChecker with detection for slow internet connectivity:

```dart
import 'package:internet_connection_checker/internet_connection_checker.dart';

void main() async {
  final customChecker = InternetConnectionChecker.createInstance(
    slowConnectionConfig: SlowConnectionConfig(
        enableToCheckForSlowConnection: true,
        slowConnectionThreshold: const Duration(seconds: 1),
      ),
  );

  bool isConnected = await customChecker.hasConnection;
  print('Custom instance connected: $isConnected');
}
```

Note: Ensure your slowConnectionThreshold's duration is not more than the checkInternal and checkTimeout Duration.

### Using requireAllAddressesToRespond

To ensure that the internet connection status is marked as connected only when all specified addresses are reachable, you can enable the requireAllAddressesToRespond configuration.

```dart
import 'package:internet_connection_checker/internet_connection_checker.dart';

void main() async {
  // Create a custom instance with requireAllAddressesToRespond set to true
  /// Remember to dispose of [customChecker] instance, when it's not needed 
  /// to prevent memory leaks.
  final customChecker = InternetConnectionChecker.createInstance(
    requireAllAddressesToRespond: true,
    addresses: [
      AddressCheckOption(uri: Uri.parse('https://dummyapi.online/api/movies/1')),
      AddressCheckOption(
        uri: Uri.parse('https://jsonplaceholder.typicode.com/albums/1'),
      ),
    ],
  );

  // Check connectivity
  final bool isConnected = await customChecker.hasConnection;

  if (isConnected) {
    print('All specified backend servers are reachable.');
  } else {
    print('Not all specified backend servers are reachable.');
  }
}
```

See `example` folder for more examples.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][issues_tracker].

[issues_tracker]: https://github.com/RounakTadvi/internet_connection_checker/issues
[pull_requests]: https://github.com/RounakTadvi/internet_connection_checker/pulls

## Credits
>* NOTE: This package is a continuation of [data_connection_checker](https://github.com/komapeb/data_connection_checker) which currently is not continued. * 

Web platform support for this package has been inspired by the [internet_connection_checker_plus](https://github.com/OutdatedGuy/internet_connection_checker_plus) library.
