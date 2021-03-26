import 'dart:async';

import 'package:shitty_connection_checker/internet_connection_checker.dart';
import 'package:test/test.dart';

void main() async {
  group('internet_connection_checker', () {
    StreamSubscription<InternetConnectionStatus>? listener1;
    StreamSubscription<InternetConnectionStatus>? listener2;

    tearDown(() {
      // destroy any active listener after each test
      listener1?.cancel();
      listener2?.cancel();
    });

    test('''Initial results List 'lastTryResults' should be empty''', () {
      expect(
        InternetConnectionChecker().lastTryResults,
        isEmpty,
      );
    });

    test('''Shouldn't have any listeners attached''', () {
      expect(
        InternetConnectionChecker().hasListeners,
        isFalse,
      );
    });

    test('''Unawaited call hasConnection should return a Future<bool>''', () {
      expect(
        InternetConnectionChecker().hasConnection,
        isA<Future<bool>>(),
      );
    });

    test('''Awaited call to hasConnection should return a bool''', () async {
      expect(
        await InternetConnectionChecker().hasConnection,
        isA<bool>(),
      );
    });

    test(
        '''InternetConnectionChecker().lastTryResults should not be empty after '''
        '''an awaited call to either hasConnection or connectionStatus''', () {
      expect(
        InternetConnectionChecker().lastTryResults,
        isNotEmpty,
      );
    });

    test(
        '''Unawaited call to connectionStatus '''
        '''should return a Future<InternetConnectionStatus>''', () {
      expect(
        InternetConnectionChecker().connectionStatus,
        isA<Future<InternetConnectionStatus>>(),
      );
    });

    test(
        '''Awaited call to connectionStatus '''
        '''should return a Future<InternetConnectionStatus>''', () async {
      expect(
        await InternetConnectionChecker().connectionStatus,
        isA<InternetConnectionStatus>(),
      );
    });

    test('''We shouldn't have any listeners 1''', () {
      expect(
        InternetConnectionChecker().hasListeners,
        isFalse,
      );
    });

    test('''We should have listeners 1''', () {
      listener1 = InternetConnectionChecker().onStatusChange!.listen((_) {});
      expect(
        InternetConnectionChecker().hasListeners,
        isTrue,
      );
    });

    test('''We should have listeners 2''', () {
      listener1 = InternetConnectionChecker().onStatusChange!.listen((_) {});
      listener2 = InternetConnectionChecker().onStatusChange!.listen((_) {});
      expect(
        InternetConnectionChecker().hasListeners,
        isTrue,
      );
    });

    test('''We should have listeners 3''', () async {
      listener1 = InternetConnectionChecker().onStatusChange!.listen((_) {});
      await listener1!.cancel();
      listener2 = InternetConnectionChecker().onStatusChange!.listen((_) {});
      expect(
        InternetConnectionChecker().hasListeners,
        isTrue,
      );
    });

    test('''We shouldn't have any listeners 2''', () async {
      listener1 = InternetConnectionChecker().onStatusChange!.listen((_) {});
      await listener1!.cancel();
      listener2 = InternetConnectionChecker().onStatusChange!.listen((_) {});
      await listener2!.cancel();
      expect(
        InternetConnectionChecker().hasListeners,
        isFalse,
      );
    });

    test('''We shouldn't have any listeners 1''', () {
      expect(
        InternetConnectionChecker().hasListeners,
        isFalse,
      );
    });

    test('''We should have listeners 1 [isActivelyChecking]''', () {
      listener1 = InternetConnectionChecker().onStatusChange!.listen((_) {});
      expect(
        InternetConnectionChecker().isActivelyChecking,
        isTrue,
      );
    });

    test('''We should have listeners 2 [isActivelyChecking]''', () {
      listener1 = InternetConnectionChecker().onStatusChange!.listen((_) {});
      listener2 = InternetConnectionChecker().onStatusChange!.listen((_) {});
      expect(
        InternetConnectionChecker().isActivelyChecking,
        isTrue,
      );
    });

    test('''We should have listeners 3 [isActivelyChecking]''', () async {
      listener1 = InternetConnectionChecker().onStatusChange!.listen((_) {});
      await listener1!.cancel();
      listener2 = InternetConnectionChecker().onStatusChange!.listen((_) {});
      expect(
        InternetConnectionChecker().isActivelyChecking,
        isTrue,
      );
    });

    test('''We shouldn't have any listeners 2 [isActivelyChecking]''',
        () async {
      listener1 = InternetConnectionChecker().onStatusChange!.listen((_) {});
      await listener1!.cancel();
      listener2 = InternetConnectionChecker().onStatusChange!.listen((_) {});
      await listener2!.cancel();
      expect(
        InternetConnectionChecker().isActivelyChecking,
        isFalse,
      );
    });
  });
}
