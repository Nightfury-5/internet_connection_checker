part of 'internet_connection_checker.dart';

/// A class for checking internet connectivity status.
///
/// This class provides functionality to monitor and verify internet
/// connectivity by checking reachability to various [Uri]s. It relies on the
/// [connectivity_plus] package for listening to connectivity changes and the
/// [http][http_link] package for making network requests.
///
/// [connectivity_plus]: https://pub.dev/packages/connectivity_plus
/// [http_link]: https://pub.dev/packages/http
///
/// <br />
///
/// ## Usage
///
/// <hr />
///
/// ### Checking for internet connectivity
///
/// ```dart
/// import 'package:internet_connection_checker/internet_connection_checker.dart';
///
/// bool result = await InternetConnectionChecker().hasConnection;
/// ```
///
/// <br />
///
/// ### Listening for internet connectivity changes
///
/// ```dart
/// import 'package:internet_connection_checker/internet_connection_checker.dart';
///
/// final listener = InternetConnectionChecker().onStatusChange.listen(
///   (InternetConnectionStatus status) {
///     switch (status) {
///       case InternetConnectionStatus.connected:
///         // The internet is now connected
///         break;
///       case InternetConnectionStatus.disconnected:
///         // The internet is now disconnected
///         break;
///     }
///   },
/// );
/// ```
///
/// Don't forget to cancel the subscription when it is no longer needed. This
/// will prevent memory leaks and free up resources.
///
/// ```dart
/// listener.cancel();
/// ```
class InternetConnectionChecker {
  /// Returns an instance of [InternetConnectionChecker].
  ///
  /// This is a singleton class, meaning that there is only one instance of it.
  factory InternetConnectionChecker() => _instance;

  /// Creates an instance of [InternetConnectionChecker].
  ///
  /// The [checkInterval] defines the interval duration between status checks.
  ///
  /// The [customCheckOptions] specify the list of [Uri]s to check for
  /// connectivity.
  ///
  /// The [useDefaultOptions] flag indicates whether to use the default [Uri]s.
  /// - If [useDefaultOptions] is `true` (default), the default [Uri]s will be
  /// used along with any [customCheckOptions] provided.
  ///
  /// - If [useDefaultOptions] is `false`, you must provide a non-empty
  /// [customCheckOptions] list.
  InternetConnectionChecker.createInstance({
    this.checkInterval = const Duration(seconds: 10),
    List<AddressCheckOption>? customCheckOptions,
    bool useDefaultOptions = true,
  }) : assert(
          useDefaultOptions || customCheckOptions?.isNotEmpty == true,
          'You must provide a list of options if you are not using the '
          'default ones.',
        ) {
    _internetCheckOptions = <AddressCheckOption>[
      if (useDefaultOptions) ..._defaultCheckOptions,
      if (customCheckOptions != null) ...customCheckOptions,
    ];

    _statusController.onListen = _maybeEmitStatusUpdate;
    _statusController.onCancel = _handleStatusChangeCancel;
  }

  /// The default list of [Uri]s used for checking internet reachability.
  final List<AddressCheckOption> _defaultCheckOptions = <AddressCheckOption>[
    AddressCheckOption(
      uri: Uri.parse(
        'https://1.1.1.1',
      ),
    ),
    AddressCheckOption(
      uri: Uri.parse(
        'https://icanhazip.com/',
      ),
    ),
    AddressCheckOption(
      uri: Uri.parse(
        'https://jsonplaceholder.typicode.com/todos/1',
      ),
    ),
    AddressCheckOption(
      uri: Uri.parse(
        'https://reqres.in/api/users/1',
      ),
    ),
  ];

  /// The list of [Uri]s used for checking internet reachability.
  late List<AddressCheckOption> _internetCheckOptions;

  /// The controller for the internet connection status stream.
  final StreamController<InternetConnectionStatus> _statusController =
      StreamController<InternetConnectionStatus>.broadcast();

  /// The singleton instance of [InternetConnectionChecker].
  static final InternetConnectionChecker _instance =
      InternetConnectionChecker.createInstance();

  /// The duration between consecutive status checks.
  ///
  /// Defaults to 5 seconds.
  final Duration checkInterval;

  /// The last known internet connection status result.
  InternetConnectionStatus? _lastStatus;

  /// The handle for the timer used for periodic status checks.
  Timer? _timerHandle;

  /// Checks if the [Uri] specified in [option] is reachable.
  ///
  /// Returns a [Future] that completes with an [AddressCheckResult] indicating
  /// whether the host is reachable or not.
  Future<AddressCheckResult> _checkReachabilityFor(
    AddressCheckOption option,
  ) async {
    try {
      final http.Response response = await compute(
        (_) {
          return http
              .head(option.uri, headers: option.headers)
              .timeout(option.timeout);
        },
        null,
      );

      return AddressCheckResult(
        option: option,
        isSuccess: option.responseStatusFn(response),
      );
    } catch (_) {
      return AddressCheckResult(
        option: option,
        isSuccess: false,
      );
    }
  }

  /// Checks if there is internet access by verifying connectivity to the
  /// specified [Uri]s.
  ///
  /// Returns a [Future] that completes with a boolean value indicating
  /// whether internet access is available or not.
  Future<bool> get hasConnection async {
    final Completer<bool> completer = Completer<bool>();
    int length = _internetCheckOptions.length;

    for (final AddressCheckOption option in _internetCheckOptions) {
      unawaited(
        _checkReachabilityFor(option).then((AddressCheckResult result) {
          length -= 1;

          if (completer.isCompleted) return;

          if (result.isSuccess) {
            completer.complete(true);
          } else if (length == 0) {
            completer.complete(false);
          }
        }),
      );
    }

    return completer.future;
  }

  /// Returns the current internet connection status.
  ///
  /// Returns a [Future] that completes with the [InternetConnectionStatus] indicating
  /// the current internet connection status.
  Future<InternetConnectionStatus> get connectionStatus async =>
      await hasConnection
          ? InternetConnectionStatus.connected
          : InternetConnectionStatus.disconnected;

  /// Internal method for emitting status updates.
  ///
  /// Updates the status and emits it if there are listeners.
  Future<void> _maybeEmitStatusUpdate() async {
    _startListeningToConnectivityChanges();
    _timerHandle?.cancel();

    final InternetConnectionStatus currentStatus = await connectionStatus;

    if (!_statusController.hasListener) return;

    if (_lastStatus != currentStatus && _statusController.hasListener) {
      _statusController.add(currentStatus);
    }

    _timerHandle = Timer(checkInterval, _maybeEmitStatusUpdate);

    _lastStatus = currentStatus;
  }

  /// Handles cancellation of status change events.
  ///
  /// Cancels the timer and resets the last status.
  void _handleStatusChangeCancel() {
    if (_statusController.hasListener) return;

    _connectivitySubscription?.cancel().then((_) {
      _connectivitySubscription = null;
    });
    _timerHandle?.cancel();
    _timerHandle = null;
    _lastStatus = null;
  }

  /// The result of the last attempt to check the internet status.
  InternetConnectionStatus? get lastTryResults => _lastStatus;

  /// Stream that emits internet connection status changes.
  Stream<InternetConnectionStatus> get onStatusChange =>
      _statusController.stream;

  /// Connectivity subscription.
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Starts listening to connectivity changes from [connectivity_plus] package
  /// using the [Connectivity.onConnectivityChanged] stream.
  ///
  /// [connectivity_plus]: https://pub.dev/packages/connectivity_plus
  void _startListeningToConnectivityChanges() {
    if (_connectivitySubscription != null) return;
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (_) {
        if (_statusController.hasListener) {
          _maybeEmitStatusUpdate();
        }
      },
    );
  }
}
