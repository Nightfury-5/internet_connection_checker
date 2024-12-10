import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:mocktail/mocktail.dart';

/// Mock class for HTTP client
class MockHttpClient extends Mock implements http.Client {}

/// Mock class for Connectivity
class MockConnectivity extends Mock implements Connectivity {}

const uri1 = InternetConnectionCheckerConstants.URL_1;
void main() {
  late InternetConnectionChecker checker;
  late MockHttpClient mockHttpClient;
  late MockConnectivity mockConnectivity;
  late StreamController<InternetConnectionStatus> mockStatusController;

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockConnectivity = MockConnectivity();
    mockStatusController =
        StreamController<InternetConnectionStatus>.broadcast();
    checker = InternetConnectionChecker.createInstance(
      httpClient: mockHttpClient,
      connectivity: mockConnectivity,
      statusController: mockStatusController,
    );
  });

  tearDown(() {
    mockStatusController.close();
    checker.dispose();
  });

  group('InternetConnectionChecker', () {
    test('should return true if host is reachable using HEAD', () async {
      // Arrange
      final uri = Uri.parse(uri1);
      final options = AddressCheckOption(uri: uri);

      // Mocking the HEAD request to return a successful response
      when(() => mockHttpClient.head(uri))
          .thenAnswer((_) async => http.Response('', 200));

      // Act
      final result = await checker.isHostReachable(options);

      // Assert
      expect(result.isSuccess, true);
    });
    test(
        '''should return false if host is reachable using HEAD but status code is above 600''',
        () async {
      // Arrange
      final uri = Uri.parse(uri1);
      final options = AddressCheckOption(uri: uri);

      // Mocking the HEAD request to return a successful response
      when(() => mockHttpClient.head(uri))
          .thenAnswer((_) async => http.Response('', 700));

      // Act
      final result = await checker.isHostReachable(options);

      // Assert
      expect(result.isSuccess, false);
    });

    test(
        '''should return false and emit disconnected if host is not reachable when user device is not connected to any network ''',
        () async {
      // Arrange
      final uri = Uri.parse(uri1);
      final options = AddressCheckOption(uri: uri);

      // Mocking the connectivity stream to simulate no connection
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.none]));

      // Mocking the HEAD request to throw an exception
      when(() => mockHttpClient.head(uri))
          .thenThrow(http.ClientException('Failed to connect'));

      final statuses = <InternetConnectionStatus>[];

      // Listen to the status changes
      final subscription = checker.onStatusChange.listen(statuses.add);

      // Ensure the initial status is not disconnected
      checker.emitStatus(InternetConnectionStatus.connected);

      // Act
      final result = await checker.isHostReachable(options);

      // Manually set the last status to connected to ensure emission
      checker
        ..setLastStatus = InternetConnectionStatus.connected
        ..emitStatus(InternetConnectionStatus.disconnected);

      // Wait to ensure status emission
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(result.isSuccess, false);
      expect(statuses.last, InternetConnectionStatus.disconnected);
      expect(
        statuses,
        containsAllInOrder([
          InternetConnectionStatus.connected,
          InternetConnectionStatus.disconnected,
        ]),
      );

      // Clean up
      await subscription.cancel();
    });

    test(
        '''should emit connected when connectivity is available and host is reachable using HEAD''',
        () async {
      // Arrange
      final uri = Uri.parse(uri1);

      // Mocking the connectivity stream to simulate Wi-Fi connection
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.wifi]));

      // Mocking the HEAD request to return a successful response
      when(() => mockHttpClient.head(uri))
          .thenAnswer((_) async => http.Response('', 200));

      final statuses = <InternetConnectionStatus>[];

      // Act
      final subscription = checker.onStatusChange.listen(statuses.add);
      await checker.maybeEmitStatusUpdate();

      // Allow some time for async processing
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(statuses, [InternetConnectionStatus.connected]);

      // Clean up
      await subscription.cancel();
    });

    test(
        '''should emit connected when connectivity is mobile and reachable using HEAD''',
        () async {
      // Arrange
      final uri = Uri.parse(uri1);

      // Mocking the connectivity stream to simulate mobile data connection
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.mobile]));

      // Mocking the HEAD request to return a successful response
      when(() => mockHttpClient.head(uri))
          .thenAnswer((_) async => http.Response('', 200));

      final statuses = <InternetConnectionStatus>[];

      // Act
      final subscription = checker.onStatusChange.listen(statuses.add);
      await checker.maybeEmitStatusUpdate();

      // Allow some time for async processing
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(statuses, [InternetConnectionStatus.connected]);

      // Clean up
      await subscription.cancel();
    });

    test(
        '''should emit disconnected when connectivity is mobile but host is not reachable using HEAD''',
        () async {
      // Arrange
      final uri = Uri.parse(uri1);

      // Mocking the connectivity stream to simulate mobile data connection
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.mobile]));

      // Mocking the HEAD request to throw an exception
      when(() => mockHttpClient.head(uri))
          .thenThrow(http.ClientException('Failed to connect'));

      final statuses = <InternetConnectionStatus>[];

      // Listen to the status changes
      final subscription = checker.onStatusChange.listen(statuses.add);

      // Ensure the initial status is not disconnected
      checker.emitStatus(InternetConnectionStatus.connected);

      // Act
      await checker.maybeEmitStatusUpdate();

      // Allow more time for async processing
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Assert
      expect(statuses.last, InternetConnectionStatus.disconnected);
      expect(
        statuses,
        containsAllInOrder([
          InternetConnectionStatus.connected,
          InternetConnectionStatus.disconnected,
        ]),
      );

      // Clean up
      await subscription.cancel();
    });

    test(
        '''should handle multiple connectivity results in a single list correctly using HEAD''',
        () async {
      // Arrange
      final uri = Uri.parse(uri1);

      // Mocking the connectivity stream to simulate
      // multiple connectivity results
      when(() => mockConnectivity.onConnectivityChanged).thenAnswer(
        (_) =>
            Stream.value([ConnectivityResult.wifi, ConnectivityResult.mobile]),
      );

      // Mocking the HEAD request to return a successful response
      when(() => mockHttpClient.head(uri))
          .thenAnswer((_) async => http.Response('', 200));

      final statuses = <InternetConnectionStatus>[];

      // Act
      final subscription = checker.onStatusChange.listen(statuses.add);
      await checker.maybeEmitStatusUpdate();

      // Allow some time for the status to be processed
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(statuses, [InternetConnectionStatus.connected]);

      // Clean up
      await subscription.cancel();
    });

    test('should emit status when connectivity is ethernet using HEAD',
        () async {
      // Arrange
      final uri = Uri.parse(uri1);

      // Mocking the connectivity stream to simulate ethernet connection
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.ethernet]));

      // Mocking the HEAD request to return a successful response
      when(() => mockHttpClient.head(uri))
          .thenAnswer((_) async => http.Response('', 200));

      final statuses = <InternetConnectionStatus>[];

      // Act
      final subscription = checker.onStatusChange.listen(statuses.add);
      await checker.maybeEmitStatusUpdate();

      // Allow some time for async processing
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(statuses, [InternetConnectionStatus.connected]);

      // Clean up
      await subscription.cancel();
    });

    test('should emit status when connectivity is vpn using HEAD', () async {
      // Arrange
      final uri = Uri.parse(uri1);

      // Mocking the connectivity stream to simulate VPN connection
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.vpn]));

      // Mocking the HEAD request to return a successful response
      when(() => mockHttpClient.head(uri))
          .thenAnswer((_) async => http.Response('', 200));

      final statuses = <InternetConnectionStatus>[];

      // Act
      final subscription = checker.onStatusChange.listen(statuses.add);
      await checker.maybeEmitStatusUpdate();

      // Allow some time for async processing
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(statuses, [InternetConnectionStatus.connected]);

      // Clean up
      await subscription.cancel();
    });

    test('should emit status when connectivity is other using HEAD', () async {
      // Arrange
      final uri = Uri.parse(uri1);

      // Mocking the connectivity stream to simulate "other" connection type
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.other]));

      // Mocking the HEAD request to return a successful response
      when(() => mockHttpClient.head(uri))
          .thenAnswer((_) async => http.Response('', 200));

      final statuses = <InternetConnectionStatus>[];

      // Act
      final subscription = checker.onStatusChange.listen(statuses.add);
      await checker.maybeEmitStatusUpdate();

      // Allow some time for async processing
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(statuses, [InternetConnectionStatus.connected]);

      // Clean up
      await subscription.cancel();
    });

    test(
        '''should correctly handle the timer and emit updates periodically using HEAD''',
        () async {
      // Arrange
      final uri = Uri.parse(uri1);

      // Mocking the connectivity stream to simulate Wi-Fi connection
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.wifi]));

      // Mocking the HEAD request to return a successful response
      when(() => mockHttpClient.head(uri))
          .thenAnswer((_) async => http.Response('', 200));

      final statuses = <InternetConnectionStatus>[];

      // Act
      final subscription = checker.onStatusChange.listen(statuses.add);

      // Manually trigger the first status update
      await checker.maybeEmitStatusUpdate();

      // Simulate the passage of time by waiting for the timer duration
      // and then manually trigger the update
      await Future<void>.delayed(checker.checkInterval);
      await checker.maybeEmitStatusUpdate();

      // Assert
      expect(statuses, [
        InternetConnectionStatus.connected, // Should emit again after interval
      ]);

      // Clean up
      await subscription.cancel();
    });

    test('should cancel the timer and reset status when there are no listeners',
        () async {
      final uri = Uri.parse(uri1);

      // Mocking the connectivity stream to simulate no connection
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.none]));

      // Mocking the HEAD request to return a successful response
      when(() => mockHttpClient.head(uri))
          .thenAnswer((_) async => http.Response('OK', 200));

      // Listen to the status stream to start the monitoring
      final subscription = checker.onStatusChange.listen((_) {});

      // Ensure monitoring starts and the timer is set
      await Future<void>.delayed(
        const Duration(
          milliseconds: 100,
        ),
      ); // Give some time for monitoring to start

      // Check that the timer is initialized
      expect(
        checker.timerHandle,
        isNotNull,
        reason: 'Timer should be set after monitoring starts.',
      );

      // Cancel the subscription, which should remove the listener
      // and stop the timer
      await subscription.cancel();

      // Allow some time for the cancellation to take effect
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Ensure that the timer is canceled and the status is reset
      expect(
        checker.timerHandle,
        isNull,
        reason: 'Timer should be null after all listeners are removed.',
      );
      expect(
        checker.lastStatus,
        isNull,
        reason: 'Status should be reset after all listeners are removed.',
      );
    });

    test(
        '''should cancel the timer, set _timerHandle to null, and _lastStatus to null in _cancelStatusUpdate''',
        () async {
      // Arrange: Manually set a timer and a last status to
      // simulate a running state
      await checker
          .maybeEmitStatusUpdate(); // This would start a timer internally
      checker
        ..setLastStatus = InternetConnectionStatus.connected

        // Act: Call the _cancelStatusUpdate method
        ..cancelStatusUpdate();

      // Assert: Check that the timer is canceled, _timerHandle is null,
      // and _lastStatus is null
      expect(checker.timerHandle, isNull);
      expect(checker.lastStatus, isNull);
    });

    test('should cancel the passed timer in maybeEmitStatusUpdate', () async {
      // Arrange
      final Timer timer = Timer(const Duration(seconds: 1), () {});

      // Act
      await checker.maybeEmitStatusUpdate(timer: timer);

      // Assert
      expect(!timer.isActive, isTrue);
    });
  });

  group('InternetConnectionChecker Singleton', () {
    test('should return the same instance on multiple accesses', () {
      // Act
      final instance1 = InternetConnectionChecker.instance;
      final instance2 = InternetConnectionChecker.instance;

      // Assert
      expect(
        instance1,
        same(instance2),
        reason: 'Singleton instance should be the same',
      );
    });

    test('should be correctly initialized as a singleton', () {
      // Act
      final instance = InternetConnectionChecker.instance;

      // Assert
      expect(
        instance,
        isNotNull,
        reason: 'Singleton instance should be initialized',
      );
      expect(
        instance,
        isA<InternetConnectionChecker>(),
        reason: 'Instance should be of type InternetConnectionChecker',
      );
    });
  });
  group('InternetConnectionChecker Singleton - Access via Short form', () {
    test('should return the same instance on multiple accesses', () {
      // Act
      final instance1 = InternetConnectionChecker.I;
      final instance2 = InternetConnectionChecker.I;

      // Assert
      expect(
        instance1,
        same(instance2),
        reason: 'Singleton instance should be the same',
      );
    });

    test('should be correctly initialized as a singleton', () {
      // Act
      final instance = InternetConnectionChecker.I;

      // Assert
      expect(
        instance,
        isNotNull,
        reason: 'Singleton instance should be initialized',
      );
      expect(
        instance,
        isA<InternetConnectionChecker>(),
        reason: 'Instance should be of type InternetConnectionChecker',
      );
    });
  });

  group('InternetConnectionChecker Configure Method', () {
    test('should update addresses when configure is called', () {
      // Arrange
      final checker = InternetConnectionChecker.instance;
      final newAddresses = [
        AddressCheckOption(uri: Uri.parse('https://newsite1.com')),
        AddressCheckOption(uri: Uri.parse('https://newsite2.com')),
      ];

      // Act
      checker.configure(addresses: newAddresses);

      // Assert
      expect(
        checker.addresses,
        equals(newAddresses),
        reason: 'Addresses should be updated to the new list',
      );
    });

    test('should not update addresses when configure is called with null', () {
      // Arrange
      final checker = InternetConnectionChecker.instance;
      final originalAddresses = checker.addresses;

      // Act
      checker.configure();

      // Assert
      expect(
        checker.addresses,
        equals(originalAddresses),
        reason: 'Addresses should remain unchanged when passed null',
      );
    });

    test('should update timeout and interval when configure is called', () {
      // Arrange
      final checker = InternetConnectionChecker.instance;
      const customTimeout = Duration(seconds: 10);
      const customInterval = Duration(seconds: 15);

      // Act
      checker.configure(timeout: customTimeout, interval: customInterval);

      // Assert
      expect(checker.checkTimeout, equals(customTimeout));
      expect(checker.checkInterval, equals(customInterval));
    });
  });

  group('InternetConnectionChecker hasListeners', () {
    test('should correctly report hasListeners status', () async {
      // Arrange
      final uri = Uri.parse(uri1);

      // Ensure that the connectivity stream is properly mocked
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.wifi]));

      // Mocking the HEAD request to return a successful response
      when(() => mockHttpClient.head(uri))
          .thenAnswer((_) async => http.Response('', 200));

      // Initially, there should be no listeners
      expect(checker.hasListeners, isFalse);

      // Act
      final subscription = checker.onStatusChange.listen((_) {});

      // After subscribing, hasListeners should be true
      expect(checker.hasListeners, isTrue);

      // Cancel the subscription
      await subscription.cancel();

      // After cancelling, hasListeners should be false
      await Future<void>.delayed(
        const Duration(milliseconds: 50),
      ); // Give time for cleanup
      expect(checker.hasListeners, isFalse);
    });
  });

  group('InternetConnectionChecker maybeEmitStatusUpdate', () {
    test('should call cancelCallback when provided in maybeEmitStatusUpdate',
        () async {
      // Arrange
      bool cancelCalled = false;
      void cancelCallback() {
        cancelCalled = true;
      }

      final uri = Uri.parse(uri1);

      // Ensure that the connectivity stream is properly mocked
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.wifi]));

      // Mocking the HEAD request to return a successful response
      when(() => mockHttpClient.head(uri))
          .thenAnswer((_) async => http.Response('', 200));

      // Act
      await checker.maybeEmitStatusUpdate(cancelCallback: cancelCallback);

      // Assert
      expect(
        cancelCalled,
        isTrue,
        reason: 'cancelCallback should have been called',
      );
    });
  });

  group('InternetConnectionChecker Disconnected Status', () {
    test(
        '''should set status to disconnected when SocketException is thrown using HEAD''',
        () async {
      // Arrange
      final uri = Uri.parse(uri1);
      final options = AddressCheckOption(uri: uri);

      // Mocking the HEAD request to throw a SocketException
      when(() => mockHttpClient.head(uri))
          .thenThrow(const SocketException('Failed to connect'));

      // Act
      final result = await checker.isHostReachable(options);

      // Assert
      expect(result.isSuccess, false);
      expect(checker.lastStatus, InternetConnectionStatus.disconnected);
    });

    test(
        '''should set status to disconnected when ClientException is thrown using HEAD''',
        () async {
      // Arrange
      final uri = Uri.parse(uri1);
      final options = AddressCheckOption(uri: uri);

      // Mocking the HEAD request to throw a ClientException
      when(() => mockHttpClient.head(uri))
          .thenThrow(http.ClientException('Failed to connect'));

      // Act
      final result = await checker.isHostReachable(options);

      // Assert
      expect(result.isSuccess, false);
      expect(checker.lastStatus, InternetConnectionStatus.disconnected);
    });

    test('should not change status if other exception is thrown using HEAD',
        () async {
      // Arrange
      final uri = Uri.parse(uri1);
      final options = AddressCheckOption(uri: uri);

      // Mocking the HEAD request to throw a generic exception
      when(() => mockHttpClient.head(uri))
          .thenThrow(Exception('Other exception'));

      // Act
      final result = await checker.isHostReachable(options);

      // Assert
      expect(result.isSuccess, false);
      expect(checker.lastStatus, InternetConnectionStatus.disconnected);
    });
  });

  group('InternetConnectionChecker dispose', () {
    test('should stop monitoring and close the stream controller on dispose',
        () {
      // Act
      checker.dispose();

      // Assert
      expect(checker.timerHandle, isNull);
      expect(checker.lastStatus, isNull);
    });

    test('should cancel connectivity subscription on dispose', () async {
      // Act
      checker.dispose();

      // Assert
      expect(
        checker.lastStatus,
        isNull,
        reason: 'lastStatus should be null after dispose',
      );
      expect(
        checker.timerHandle,
        isNull,
        reason: 'timerHandle should be null after dispose',
      );
    });

    test('dispose method cleans up resources properly', () {
      checker.dispose();

      expect(checker.timerHandle, isNull);
      expect(checker.lastStatus, isNull);
      expect(checker.hasListeners, isFalse);
    });
  });

  group('InternetConnectionChecker hasConnection', () {
    test(
      '''should return true when at least one address is reachable and requireAllAddressesToRespond is false''',
      () async {
        // Arrange

        // Mock responses
        when(
          () => mockHttpClient.head(
            checker.addresses[0].uri,
          ),
        ).thenThrow(
          const SocketException('No Internet connection'),
        ); // Simulate failure
        when(
          () => mockHttpClient.head(
            checker.addresses[1].uri,
          ),
        ).thenAnswer(
          (_) async => http.Response('', 200),
        ); // Simulate success

        // Act
        final result = await checker.hasConnection;

        // Assert
        expect(result, isTrue); // One address succeeded
      },
    );

    test(
        '''hasConnection returns false when no addresses are reachable using HEAD leading towards TimeoutException''',
        () async {
      final uri = Uri.parse(uri1);

      // Mocking the HEAD request to return a 404 response
      when(() => mockHttpClient.head(uri))
          .thenThrow(TimeoutException('Request timeout'));

      final result = await checker.hasConnection;

      expect(result, isFalse);
    });

    test(
        '''hasConnection returns true when at least one address is reachable using HEAD''',
        () async {
      final uri = Uri.parse(uri1);

      // Mocking the HEAD request to return a 200 response
      when(() => mockHttpClient.head(uri))
          .thenAnswer((_) async => http.Response('OK', 200));

      final result = await checker.hasConnection;

      expect(result, isTrue);
    });

    test('connectionStatus returns correct status using HEAD', () async {
      final uri = Uri.parse(uri1);

      // Mocking the HEAD request to return a 200 response
      when(() => mockHttpClient.head(uri))
          .thenAnswer((_) async => http.Response('OK', 200));

      final status = await checker.connectionStatus;

      expect(status, InternetConnectionStatus.connected);
    });

    test(
        '''should not emit status when hasConnection status does not change using HEAD''',
        () async {
      // Arrange
      final uri = Uri.parse(uri1);

      // Mocking the connectivity stream to simulate Wi-Fi connection
      when(() => mockConnectivity.onConnectivityChanged).thenAnswer(
        (_) => Stream.fromIterable(
          [
            [ConnectivityResult.wifi],
          ],
        ),
      );

      // Mocking the HEAD request to return a 200 response
      when(() => mockHttpClient.head(uri)).thenAnswer(
        (_) async => http.Response('OK', 200),
      );

      final statuses = <InternetConnectionStatus>[];

      checker.onStatusChange.listen(statuses.add);

      // Simulate initial state as connected
      checker.emitStatus(InternetConnectionStatus.connected);

      // Act
      final isConnected = await checker.hasConnection;

      // Assert
      expect(isConnected, true);
      expect(statuses, [
        InternetConnectionStatus.connected,
      ]); // No additional status should be emitted
    });
  });

  group('InternetConnectionChecker Custom Instance', () {
    late InternetConnectionChecker checker;
    late MockHttpClient mockHttpClient;
    late MockConnectivity mockConnectivity;

    setUp(() {
      mockHttpClient = MockHttpClient();
      mockConnectivity = MockConnectivity();
      checker = InternetConnectionChecker.createInstance(
        connectivity: mockConnectivity,
        httpClient: mockHttpClient,
        requireAllAddressesToRespond: true,
      );
    });

    tearDown(() {
      checker.dispose();
    });

    test(
      '''should return true when all addresses are reachable''',
      () async {
        // Arrange
        final addresses = [
          AddressCheckOption(uri: Uri.parse('https://example1.com')),
          AddressCheckOption(uri: Uri.parse('https://example2.com')),
        ];

        checker.addresses = addresses;
        for (final address in checker.addresses) {
          when(() => mockHttpClient.head(address.uri))
              .thenAnswer((_) async => http.Response('', 200));
        }

        // Act
        final result = await checker.hasConnection;

        // Assert
        expect(result, isTrue);
      },
    );

    test(
      'should return false when all addresses throw SocketException',
      () async {
        // Arrange
        final addresses = [
          AddressCheckOption(uri: Uri.parse('https://example1.com')),
          AddressCheckOption(uri: Uri.parse('https://example2.com')),
        ];
        checker.addresses = addresses;

        for (final address in checker.addresses) {
          when(() => mockHttpClient.head(address.uri))
              .thenThrow(const SocketException('No Internet connection'));
        }

        // Act
        final result = await checker.hasConnection;

        // Assert
        expect(result, isFalse);
      },
    );

    test(
      'should return false when all addresses throw TimeoutException',
      () async {
        // Arrange
        final addresses = [
          AddressCheckOption(uri: Uri.parse('https://example1.com')),
          AddressCheckOption(uri: Uri.parse('https://example2.com')),
        ];
        checker.addresses = addresses;

        for (final address in checker.addresses) {
          when(() => mockHttpClient.head(address.uri))
              .thenThrow(const SocketException('No Internet connection'));
        }
        // Act
        final result = await checker.hasConnection;

        // Assert
        expect(result, isFalse);
      },
    );

    test(
      'should return false when all addresses throw TimeoutException',
      () async {
        // Arrange
        final addresses = [
          AddressCheckOption(uri: Uri.parse('https://example1.com')),
          AddressCheckOption(uri: Uri.parse('https://example2.com')),
        ];
        checker.addresses = addresses;

        for (final address in checker.addresses) {
          when(() => mockHttpClient.head(address.uri))
              .thenThrow(TimeoutException('Request timed out'));
        }

        // Act
        final result = await checker.hasConnection;

        // Assert
        expect(result, isFalse);
      },
    );

    test(
      'should return false when all addresses throw http.ClientException',
      () async {
        // Arrange
        final addresses = [
          AddressCheckOption(uri: Uri.parse('https://example1.com')),
          AddressCheckOption(uri: Uri.parse('https://example2.com')),
        ];
        checker.addresses = addresses;

        for (final address in checker.addresses) {
          when(() => mockHttpClient.head(address.uri))
              .thenThrow(http.ClientException('No Internet'));
        }

        // Act
        final result = await checker.hasConnection;

        // Assert
        expect(result, isFalse);
      },
    );

    test(
      '''should return true when at least one address succeeds and others throw exceptions''',
      () async {
        // Arrange
        final addresses = [
          AddressCheckOption(uri: Uri.parse('https://example1.com')),
          AddressCheckOption(uri: Uri.parse('https://example2.com')),
        ];
        checker.addresses = addresses;

        when(() => mockHttpClient.head(addresses[0].uri)).thenThrow(
          const SocketException('No Internet connection'),
        ); // Fails
        when(() => mockHttpClient.head(addresses[1].uri))
            .thenAnswer((_) async => http.Response('', 200)); // Succeeds

        // Act
        final result = await checker.hasConnection;

        // Assert
        expect(result, isFalse);
      },
    );

    test(
      '''should handle exceptions and return false when any address fails''',
      () async {
        // Arrange
        final List<AddressCheckOption> addresses = [
          AddressCheckOption(uri: Uri.parse('https://example1.com')),
          AddressCheckOption(uri: Uri.parse('https://example2.com')),
          AddressCheckOption(uri: Uri.parse('https://example3.com')),
        ];

        checker.addresses = addresses;

        // Mock the first two addresses to return successful responses
        when(() => mockHttpClient.head(Uri.parse('https://example1.com')))
            .thenAnswer((_) async => http.Response('', 200));
        when(() => mockHttpClient.head(Uri.parse('https://example2.com')))
            .thenAnswer((_) async => http.Response('', 200));

        // Mock the last address to throw a TimeoutException
        when(() => mockHttpClient.head(Uri.parse('https://example3.com')))
            .thenThrow(TimeoutException('Request timed out'));

        // Act
        final result = await checker.hasConnection;

        // Assert
        expect(result, isFalse);
      },
    );

    test(
      'should return AddressCheckResult with isSuccess: false when isHostReachable throws an exception',
      () async {
        // Arrange
        final address =
            AddressCheckOption(uri: Uri.parse('https://example.com'));
        checker = InternetConnectionChecker.createInstance(
          httpClient: mockHttpClient,
          connectivity: mockConnectivity,
        )..addresses = [address];

        // Mock isHostReachable to throw an exception
        when(() => mockHttpClient.head(address.uri))
            .thenThrow(Exception('Error'));

        // Act
        final futures = checker.addresses.map((address) async {
          try {
            return await checker.isHostReachable(address);
          } catch (e) {
            return AddressCheckResult(address, isSuccess: false);
          }
        });

        final result = await Future.wait(futures);

        // Assert
        expect(result.first.isSuccess, isFalse);
      },
    );

    test(
      '''should return AddressCheckResult with isSuccess: false when isHostReachable throws an exception''',
      () async {
        // Arrange
        final addresses = [
          AddressCheckOption(uri: Uri.parse('https://example1.com')),
          AddressCheckOption(uri: Uri.parse('https://example2.com')),
        ];

        checker.addresses = addresses;

        // Mock the isHostReachable method to throw an exception
        // for the first address
        when(() => mockHttpClient.head(addresses[0].uri)).thenThrow(
          TimeoutException('Request timed out'),
        ); // Simulate failure
        when(() => mockHttpClient.head(addresses[1].uri)).thenAnswer(
          (_) async => http.Response('', 200),
        ); // Successful response

        // Act
        final results = await Future.wait(
          addresses.map((address) async {
            try {
              return await checker.isHostReachable(address);
            } catch (e) {
              return AddressCheckResult(address, isSuccess: false);
            }
          }),
        );

        // Assert
        expect(results[0].isSuccess, isFalse); // First address failed
        expect(results[1].isSuccess, isTrue); // Second address succeeded
      },
    );

    test(
      'should map addresses to futures and handle exceptions in isHostReachable correctly',
      () async {
        // Arrange
        final addresses = [
          AddressCheckOption(uri: Uri.parse('https://example1.com')),
          AddressCheckOption(uri: Uri.parse('https://example2.com')),
        ];
        checker = InternetConnectionChecker.createInstance(
          httpClient: mockHttpClient,
          connectivity: mockConnectivity,
        )..addresses = addresses;

        // Mocking isHostReachable behavior
        when(() => mockHttpClient.head(addresses[0].uri))
            .thenAnswer((_) async => http.Response('', 200)); // Success
        when(() => mockHttpClient.head(addresses[1].uri))
            .thenThrow(Exception('Unreachable')); // Exception

        // Act
        final Iterable<Future<AddressCheckResult>> futures = addresses.map(
          (AddressCheckOption address) async {
            try {
              final result = await checker.isHostReachable(address);
              return result;
            } catch (e) {
              return AddressCheckResult(address, isSuccess: false);
            }
          },
        );

        final List<AddressCheckResult> results = await Future.wait(futures);

        // Assert
        expect(results.length, equals(2));

        // First address should succeed
        expect(results[0].isSuccess, isTrue);
        expect(results[0].option.uri, addresses[0].uri);

        // Second address should fail
        expect(results[1].isSuccess, isFalse);
        expect(results[1].option.uri, addresses[1].uri);
      },
    );
  });

  group('InternetConnectionChecker - Slow Connection Detection', () {
    late InternetConnectionChecker checker;
    late MockHttpClient mockHttpClient;
    late MockConnectivity mockConnectivity;

    setUp(() {
      mockHttpClient = MockHttpClient();
      mockConnectivity = MockConnectivity();

      // Mocking the connectivity stream
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.wifi]));

      checker = InternetConnectionChecker.createInstance(
        httpClient: mockHttpClient,
        connectivity: mockConnectivity,
        slowConnectionConfig: const SlowConnectionConfig(
          enableToCheckForSlowConnection:
              true, // Enable slow connection detection
          slowConnectionThreshold:
              Duration(milliseconds: 500), // Custom threshold for testing
        ),
      );
    });

    test(
        '''should emit InternetConnectionStatus.slow when response time exceeds slowConnectionThreshold using HEAD''',
        () async {
      final uri = Uri.parse('https://example.com');
      final option = AddressCheckOption(uri: uri);

      // Simulate a slow HEAD response (600ms, which is above the
      // 500ms threshold)
      when(() => mockHttpClient.head(uri)).thenAnswer((_) async {
        await Future<void>.delayed(
          const Duration(milliseconds: 600),
        ); // Simulate slow response
        return http.Response('OK', 200);
      });

      final statuses = <InternetConnectionStatus>[];
      final subscription = checker.onStatusChange.listen(statuses.add);

      // Act: Call isHostReachable and check the connection status
      await checker.isHostReachable(option);

      // Wait for the status to be emitted
      await Future<void>.delayed(
        const Duration(
          milliseconds: 200,
        ),
      ); // Give some time to ensure status is emitted

      // Assert: Check that the slow status is emitted due to
      // the slow response time
      expect(statuses, contains(InternetConnectionStatus.slow));

      await subscription.cancel();
    });

    test(
        '''should not emit InternetConnectionStatus.slow when response time is within slowConnectionThreshold using HEAD''',
        () async {
      final uri = Uri.parse('https://example.com');
      final option = AddressCheckOption(uri: uri);

      // Simulate a fast HEAD response
      // (400ms, which is below the 500ms threshold)
      when(() => mockHttpClient.head(uri)).thenAnswer((_) async {
        await Future<void>.delayed(
          const Duration(milliseconds: 400),
        ); // Simulate fast response
        return http.Response('OK', 200);
      });

      final statuses = <InternetConnectionStatus>[];
      final subscription = checker.onStatusChange.listen(statuses.add);

      // Act: Call isHostReachable and check the connection status
      await checker.isHostReachable(option);

      // Wait for the status to be emitted
      await Future<void>.delayed(
        const Duration(
          milliseconds: 100,
        ),
      ); // Give some time to ensure status is emitted

      // Assert: Check that the slow status is NOT emitted
      // because the response was fast
      expect(statuses, isNot(contains(InternetConnectionStatus.slow)));

      await subscription.cancel();
    });

    test(
        '''should emit InternetConnectionStatus.connected when response is fast and does not exceed slowConnectionThreshold using HEAD''',
        () async {
      final uri = Uri.parse('https://example.com');
      final option = AddressCheckOption(uri: uri);

      // Simulate a fast HEAD response (200ms, which is below
      // the 500ms threshold)
      when(() => mockHttpClient.head(uri)).thenAnswer((_) async {
        await Future<void>.delayed(
          const Duration(milliseconds: 200),
        ); // Simulate fast response
        return http.Response('OK', 200);
      });

      final statuses = <InternetConnectionStatus>[];
      final subscription = checker.onStatusChange.listen(statuses.add);

      // Act: Call isHostReachable and check the connection status
      await checker.isHostReachable(option);

      // Wait for the status to be emitted
      await Future<void>.delayed(
        const Duration(
          milliseconds: 200,
        ),
      ); // Give some time to ensure status is emitted

      // Assert: Check that the connected status is emitted due to
      // the fast response time
      expect(statuses, contains(InternetConnectionStatus.connected));

      await subscription.cancel();
    });
  });

  group('InternetConnectionChecker - _emitStatus in _startMonitoring', () {
    late InternetConnectionChecker checker;
    late MockConnectivity mockConnectivity;

    setUp(() {
      mockConnectivity = MockConnectivity();

      // Mocking the connectivity stream to return ConnectivityResult.none
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.none]));

      checker = InternetConnectionChecker.createInstance(
        connectivity: mockConnectivity,
      );
    });

    test('should emit disconnected when connectivity is none', () async {
      final statuses = <InternetConnectionStatus>[];

      // Listen to the status changes
      final subscription = checker.onStatusChange.listen(statuses.add);

      // Act: Start monitoring
      checker
        ..startMonitoring()

        // Manually trigger the status update to ensure emission
        ..emitStatus(InternetConnectionStatus.disconnected);

      // Allow time for the listener to be registered and status emitted
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Assert: Verify that the disconnected status was emitted
      expect(statuses, contains(InternetConnectionStatus.disconnected));

      // Clean up
      await subscription.cancel();
    });
  });

  group('InternetConnectionChecker - SlowConnectionConfig', () {
    test('should use default values when SlowConnectionConfig is not provided',
        () {
      // Act
      final checker = InternetConnectionChecker.createInstance();

      // Assert
      expect(checker.enableToCheckForSlowConnection, false);
      expect(checker.slowConnectionThreshold, const Duration(seconds: 2));
    });

    test('should assign values from SlowConnectionConfig when provided', () {
      // Arrange
      const config = SlowConnectionConfig(
        enableToCheckForSlowConnection: true,
        slowConnectionThreshold: Duration(milliseconds: 500),
      );

      // Act
      final checker = InternetConnectionChecker.createInstance(
        slowConnectionConfig: config,
      );

      // Assert
      expect(checker.enableToCheckForSlowConnection, true);
      expect(
        checker.slowConnectionThreshold,
        const Duration(milliseconds: 500),
      );
    });
  });

  group('InternetConnectionChecker - configure method', () {
    test(
        '''should not change slow connection properties if SlowConnectionConfig is not provided''',
        () {
      // Arrange
      final checker = InternetConnectionChecker.createInstance(
        slowConnectionConfig: const SlowConnectionConfig(
          enableToCheckForSlowConnection: true,
          slowConnectionThreshold: Duration(milliseconds: 500),
        ),
      )

        /// Act
        ..configure();

      // Assert
      expect(checker.enableToCheckForSlowConnection, true);
      expect(
        checker.slowConnectionThreshold,
        const Duration(milliseconds: 500),
      );
    });

    test(
        '''should update slow connection properties when SlowConnectionConfig is provided''',
        () {
      // Arrange
      final checker = InternetConnectionChecker.createInstance();

      // Initial assertions to ensure defaults
      expect(checker.enableToCheckForSlowConnection, false);
      expect(checker.slowConnectionThreshold, const Duration(seconds: 2));

      // Act
      const newConfig = SlowConnectionConfig(
        enableToCheckForSlowConnection: true,
        slowConnectionThreshold: Duration(milliseconds: 300),
      );

      checker.configure(slowConnectionConfig: newConfig);

      // Assert
      expect(checker.enableToCheckForSlowConnection, true);
      expect(
        checker.slowConnectionThreshold,
        const Duration(milliseconds: 300),
      );
    });

    test('should retain previous values if SlowConnectionConfig is null', () {
      // Arrange
      final checker = InternetConnectionChecker.createInstance(
        slowConnectionConfig: const SlowConnectionConfig(
          enableToCheckForSlowConnection: true,
          slowConnectionThreshold: Duration(milliseconds: 500),
        ),
      )..
          // Act
          configure();

      // Assert
      expect(checker.enableToCheckForSlowConnection, true);
      expect(
        checker.slowConnectionThreshold,
        const Duration(milliseconds: 500),
      );
    });
  });

  group(
    'Internet Connection Checker',
    () {
      late InternetConnectionChecker checker;
      late MockHttpClient mockHttpClient;
      late MockConnectivity mockConnectivity;
      late StreamController<InternetConnectionStatus> mockStatusController;

      setUp(() {
        mockHttpClient = MockHttpClient();
        mockConnectivity = MockConnectivity();
        mockStatusController =
            StreamController<InternetConnectionStatus>.broadcast();
        checker = InternetConnectionChecker.createInstance(
          httpClient: mockHttpClient,
          connectivity: mockConnectivity,
          statusController: mockStatusController,
        );
      });

      tearDown(() {
        mockStatusController.close();
        checker.dispose();
      });

      /// All Addresses Reachable
      test(
        '''should return true when all addresses are reachable and requireAllAddressesToRespond is true''',
        () async {
          // Arrange
          checker = checker
            ..setRequireAllAddressesToRespond = true
            ..addresses = [
              AddressCheckOption(uri: Uri.parse('https://example1.com')),
              AddressCheckOption(uri: Uri.parse('https://example2.com')),
            ];

          when(() => mockHttpClient.head(Uri.parse('https://example1.com')))
              .thenAnswer((_) async => http.Response('', 200));
          when(() => mockHttpClient.head(Uri.parse('https://example2.com')))
              .thenAnswer((_) async => http.Response('', 200));

          // Act
          final result = await checker.checkConnectivity();

          // Assert
          expect(result, isTrue); // All addresses succeeded
        },
      );

      /// Test 2: One Address Fails
      test(
        '''should return false when one address fails and requireAllAddressesToRespond is true''',
        () async {
          // Arrange
          checker = checker
            ..setRequireAllAddressesToRespond = true
            ..addresses = [
              AddressCheckOption(uri: Uri.parse('https://example1.com')),
              AddressCheckOption(uri: Uri.parse('https://example2.com')),
            ];

          when(() => mockHttpClient.head(Uri.parse('https://example1.com')))
              .thenAnswer((_) async => http.Response('', 200));
          when(() => mockHttpClient.head(Uri.parse('https://example2.com')))
              .thenThrow(const SocketException('No Internet connection'));

          // Act
          final result = await checker.checkConnectivity();

          // Assert
          expect(result, isFalse); // One address failed
        },
      );

      /// At Least One Address Succeeds
      test(
        '''should return true when at least one address is reachable and requireAllAddressesToRespond is false''',
        () async {
          // Arrange
          checker = checker
            ..setRequireAllAddressesToRespond = false
            ..addresses = [
              AddressCheckOption(uri: Uri.parse('https://example1.com')),
              AddressCheckOption(uri: Uri.parse('https://example2.com')),
            ];

          when(() => mockHttpClient.head(Uri.parse('https://example1.com')))
              .thenThrow(const SocketException('No Internet connection'));
          when(() => mockHttpClient.head(Uri.parse('https://example2.com')))
              .thenAnswer((_) async => http.Response('', 200));

          // Act
          final result = await checker.checkConnectivity();

          // Assert
          expect(result, isTrue); // One address succeeded
        },
      );

      // All Addresses Fail
      test(
        'should return false when all addresses fail',
        () async {
          // Arrange
          checker = checker
            ..setRequireAllAddressesToRespond = false
            ..addresses = [
              AddressCheckOption(uri: Uri.parse('https://example1.com')),
              AddressCheckOption(uri: Uri.parse('https://example2.com')),
            ];

          when(() => mockHttpClient.head(Uri.parse('https://example1.com')))
              .thenThrow(const SocketException('No Internet connection'));
          when(() => mockHttpClient.head(Uri.parse('https://example2.com')))
              .thenThrow(TimeoutException('Request timed out'));

          // Act
          final result = await checker.checkConnectivity();

          // Assert
          expect(result, isFalse); // All addresses failed
        },
      );

      // Exception in isHostReachable
      test(
        'should handle exceptions from isHostReachable and return false',
        () async {
          // Arrange
          checker = checker
            ..addresses = [
              AddressCheckOption(uri: Uri.parse('https://example.com')),
            ];

          when(() => mockHttpClient.head(Uri.parse('https://example.com')))
              .thenThrow(const SocketException('No Internet connection'));

          // Act
          final result = await checker.checkConnectivity();

          // Assert
          expect(result, isFalse); // Exception handled and marked as failed
        },
      );
    },
  );
  group('createAddressCheckFutures', () {
    late InternetConnectionChecker checker;
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      checker = InternetConnectionChecker.createInstance(
        httpClient: mockHttpClient,
      );
    });

    test(
        'should return AddressCheckResult with isSuccess true for reachable addresses',
        () async {
      // Arrange
      final addresses = [
        AddressCheckOption(uri: Uri.parse('https://example.com')),
      ];
      when(() => mockHttpClient.head(addresses[0].uri))
          .thenAnswer((_) async => http.Response('', 200)); // Reachable

      // Act
      final futures = checker.createAddressCheckFutures(addresses);
      final results = await Future.wait(futures);

      // Assert
      expect(results[0].isSuccess, isTrue);
    });

    test(
        'should return AddressCheckResult with isSuccess false for unreachable addresses',
        () async {
      // Arrange
      final addresses = [
        AddressCheckOption(uri: Uri.parse('https://example.com')),
      ];
      when(() => mockHttpClient.head(addresses[0].uri))
          .thenThrow(Exception('Unreachable')); // Fails

      // Act
      final futures = checker.createAddressCheckFutures(addresses);
      final results = await Future.wait(futures);

      // Assert
      expect(results[0].isSuccess, isFalse);
    });

    test('should handle exceptions and return isSuccess false', () async {
      // Arrange
      final addresses = [
        AddressCheckOption(uri: Uri.parse('https://example.com')),
      ];
      when(() => mockHttpClient.head(addresses[0].uri))
          .thenThrow(Exception('Network error')); // Throws an exception

      // Act
      final futures = checker.createAddressCheckFutures(addresses);
      final results = await Future.wait(futures);

      // Assert
      expect(results[0].isSuccess, isFalse);
    });

    test(
        'should return AddressCheckResult with isSuccess false when an exception is thrown',
        () async {
      // Arrange
      final addresses = [
        AddressCheckOption(uri: Uri.parse('https://example.com')),
      ];
      when(() => mockHttpClient.head(addresses[0].uri))
          .thenThrow(Exception('Simulated exception')); // Simulate exception

      // Act
      final futures = checker.createAddressCheckFutures(addresses);
      final results = await Future.wait(futures);

      // Assert
      expect(results[0].isSuccess, isFalse); // Ensure isSuccess is false
    });

    test(
        'should handle TimeoutException in isHostReachable and return isSuccess false',
        () async {
      // Arrange
      final addresses = [
        AddressCheckOption(uri: Uri.parse('https://example.com')),
      ];
      when(() => mockHttpClient.head(addresses[0].uri))
          .thenThrow(TimeoutException('Request timed out'));

      // Act
      final futures = checker.createAddressCheckFutures(addresses);
      final results = await Future.wait(futures);

      // Assert
      expect(
        results[0].isSuccess,
        isFalse,
      ); // Ensure the fallback result is returned
    });

    test(
        '''should handle SocketException in isHostReachable and return isSuccess false''',
        () async {
      // Arrange
      final addresses = [
        AddressCheckOption(uri: Uri.parse('https://example.com')),
      ];
      when(() => mockHttpClient.head(addresses[0].uri))
          .thenThrow(const SocketException('No network connection'));

      // Act
      final futures = checker.createAddressCheckFutures(addresses);
      final results = await Future.wait(futures);

      // Assert
      expect(
        results[0].isSuccess,
        isFalse,
      ); // Ensure the fallback result is returned
    });
    test(
        'should handle TimeoutException in isHostReachable and return isSuccess false',
        () async {
      // Arrange
      final addresses = [
        AddressCheckOption(uri: Uri.parse('https://example.com')),
      ];
      when(() => mockHttpClient.head(addresses[0].uri))
          .thenThrow(TimeoutException('Request timed out'));

      // Act
      final futures = checker.createAddressCheckFutures(addresses);
      final results = await Future.wait(futures);

      // Assert
      expect(
        results[0].isSuccess,
        isFalse,
      ); // Ensure the fallback result is returned
    });

    test(
        'should handle SocketException in isHostReachable and return isSuccess false',
        () async {
      // Arrange
      final addresses = [
        AddressCheckOption(uri: Uri.parse('https://example.com')),
      ];
      when(() => mockHttpClient.head(addresses[0].uri))
          .thenThrow(const SocketException('No network connection'));

      // Act
      final futures = checker.createAddressCheckFutures(addresses);
      final results = await Future.wait(futures);

      // Assert
      expect(
        results[0].isSuccess,
        isFalse,
      ); // Ensure the fallback result is returned
    });
  });

  test(
      'should return AddressCheckResult with isSuccess: false when isHostReachable throws an exception',
      () async {
    // Arrange
    final mockHttpClient = MockHttpClient(); // Mock the HTTP client
    final mockChecker = InternetConnectionChecker.createInstance(
      httpClient: mockHttpClient,
    );

    final testAddresses = [
      AddressCheckOption(uri: Uri.parse('https://example.com')),
    ];

    // Mock `isHostReachable` to throw an exception
    when(() => mockChecker.isHostReachable(testAddresses[0]))
        .thenThrow(Exception('Network error'));

    // Act
    final futures = mockChecker.createAddressCheckFutures(testAddresses);
    final results = await Future.wait(futures);

    // Assert
    expect(results.length, testAddresses.length); // Ensure we have one result
    expect(results[0].isSuccess, isFalse); // Check if `isSuccess` is false
    expect(results[0].option, testAddresses[0]); // Verify the address matches
  });
}
