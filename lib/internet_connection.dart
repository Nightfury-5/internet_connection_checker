part of 'internet_connection_checker.dart';

/// A utility class that checks the status of the internet connection.
///
/// The `InternetConnectionChecker` class provides a way to monitor the internet
/// connection status of a device. It can emit statuses like connected,
/// disconnected, and slow connection based on predefined criteria.
/// The class is designed as a singleton to ensure consistent
/// monitoring across the app.
class InternetConnectionChecker {
  /// Creates an instance of `InternetConnectionChecker`.
  ///
  /// This constructor is visible only for testing purposes and is
  /// used to create a new instance of the checker with custom configurations.
  ///
  /// *Parameters:*
  /// - `checkTimeout`: The timeout duration for checking connectivity.
  ///    Default is 5 seconds.
  /// - `checkInterval`: The interval between consecutive connectivity checks.
  ///    Default is 5 seconds.
  /// - `addresses`: A list of `AddressCheckOption` to check connectivity.
  /// - `httpClient`: A custom `http.Client` for making network requests.
  /// - `statusController`: A custom `StreamController` for managing
  ///    connection status events.
  /// - `connectivity`: A custom `Connectivity` instance for monitoring
  ///    network changes.
  /// - `slowConnectionConfig`: A `SlowConnectionConfig` instance for
  ///    configuring slow connection detection.
  /// - `requireAllAddressesToRespond`: Defaults to false, provides the output
  ///    when any one of the addresses is reached. When it's true, it will
  ///    provide the output after accessing all addresss sepecificed in
  ///    [addresses].
  InternetConnectionChecker.createInstance({
    this.checkTimeout = InternetConnectionCheckerConstants.DEFAULT_TIMEOUT,
    this.checkInterval = InternetConnectionCheckerConstants.DEFAULT_INTERVAL,
    List<AddressCheckOption>? addresses,
    http.Client? httpClient,
    StreamController<InternetConnectionStatus>? statusController,
    Connectivity? connectivity,
    SlowConnectionConfig? slowConnectionConfig,
    this.requireAllAddressesToRespond = false,
  })  : assert(
          addresses == null || addresses.isNotEmpty,
          '''The "addresses" parameter cannot be an empty list. Provide at least one address or leave it null to use the default addresses.''',
        ),
        _httpClient = httpClient ?? http.Client(),
        _connectivity = connectivity ?? Connectivity(),
        enableToCheckForSlowConnection =
            slowConnectionConfig?.enableToCheckForSlowConnection ?? false,
        slowConnectionThreshold =
            slowConnectionConfig?.slowConnectionThreshold ??
                DEFAULT_SLOW_CONNECTION_THRESHOLD,
        _statusController = statusController ??
            StreamController<InternetConnectionStatus>.broadcast() {
    this.addresses = addresses != null && addresses.isNotEmpty
        ? addresses
        : DEFAULT_ADDRESSES
            .map(
              (AddressCheckOption e) => AddressCheckOption(
                uri: e.uri,
                timeout: checkTimeout,
              ),
            )
            .toList();

    _statusController
      ..onListen = _startMonitoring
      ..onCancel = _stopMonitoring;
  }

  /// Whether to check all addresses for internet connectivity.
  bool requireAllAddressesToRespond;

  /// Singleton instance of `InternetConnectionChecker`.
  static final InternetConnectionChecker _instance =
      InternetConnectionChecker.createInstance();

  /// Access the singleton instance of `InternetConnectionChecker`.
  static InternetConnectionChecker get instance => _instance;

  /// Short form to access the instance of `InternetConnectionChecker`.
  static InternetConnectionChecker get I => _instance;

  /// Default timeout duration (5 seconds) for checking connectivity.
  // ignore: constant_identifier_names
  static const Duration DEFAULT_TIMEOUT =
      InternetConnectionCheckerConstants.DEFAULT_TIMEOUT;

  /// Default interval (5 seconds) between consecutive connectivity checks.
  // ignore: constant_identifier_names
  static const Duration DEFAULT_INTERVAL =
      InternetConnectionCheckerConstants.DEFAULT_INTERVAL;

  /// Default threshold duration to consider a connection as "slow".
  // ignore: constant_identifier_names
  static const Duration DEFAULT_SLOW_CONNECTION_THRESHOLD =
      InternetConnectionCheckerConstants.DEFAULT_SLOW_CONNECTION_THRESHOLD;

  /// Default list of addresses to check connectivity against.
  // ignore: non_constant_identifier_names
  static final List<AddressCheckOption> DEFAULT_ADDRESSES =
      InternetConnectionCheckerConstants.DEFAULT_ADDRESSES;

  late List<AddressCheckOption> _addresses;
  final http.Client _httpClient;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _timerHandle;
  InternetConnectionStatus? _lastStatus;
  final StreamController<InternetConnectionStatus> _statusController;

  /// Indicates whether to check for slow connections.
  bool enableToCheckForSlowConnection;

  /// The threshold duration to consider a connection as "slow".
  Duration slowConnectionThreshold;

  /// The timeout duration for connectivity checks.
  Duration checkTimeout;

  /// The interval between consecutive connectivity checks.
  Duration checkInterval;

  /// Gets the list of addresses to check connectivity against.
  List<AddressCheckOption> get addresses => _addresses;

  /// Sets a new list of addresses to check connectivity against.
  set addresses(List<AddressCheckOption> value) {
    _addresses = List<AddressCheckOption>.unmodifiable(value);
    _maybeEmitStatusUpdate();
  }

  /// A stream of `InternetConnectionStatus` that emits the
  /// current connection status.
  Stream<InternetConnectionStatus> get onStatusChange =>
      _statusController.stream;

  /// Indicates whether there are any active listeners to the
  /// connection status stream.
  bool get hasListeners => _statusController.hasListener;

  /// Method to create futures for address checks, isolated for unit testing.
  @visibleForTesting
  Iterable<Future<AddressCheckResult>> createAddressCheckFutures(
    List<AddressCheckOption> addresses,
  ) {
    return addresses.map((AddressCheckOption address) async {
      final result = await isHostReachable(address);
      return result;
    });
  }

  /// Checks if all or any addresses are reachable based on the configuration.
  Future<bool> _checkConnectivity() async {
    final Iterable<Future<AddressCheckResult>> futures =
        createAddressCheckFutures(addresses);

    if (!requireAllAddressesToRespond) {
      try {
        // Ensure at least one successful result, even if others fail
        final List<bool> results = await Future.wait(
          futures.map((future) => future.then((result) => result.isSuccess)),
        );

        // Return true if any result is successful
        return results.contains(true);
      } catch (e) {
        return false; // If all futures fail, return false
      }
    } else {
      final List<AddressCheckResult> results = await Future.wait(futures);
      return results.every((result) => result.isSuccess);
    }
  }

  @visibleForTesting

  /// Checks if all or any addresses are reachable based on the configuration.
  Future<bool> checkConnectivity() => _checkConnectivity();

  /// Checks if there is an active internet connection.
  ///
  /// This method checks connectivity by making requests
  /// to the configured addresses.
  /// If `requireAllAddressesToRespond` is enabled, it validates all addresses.
  Future<bool> get hasConnection async {
    final bool isConnected = await _checkConnectivity();

    final InternetConnectionStatus newStatus = isConnected
        ? InternetConnectionStatus.connected
        : InternetConnectionStatus.disconnected;

    // Emit status immediately if it has changed
    if (_lastStatus != newStatus) {
      _emitStatus(newStatus);
    }

    return isConnected;
  }

  /// Gets the current internet connection status.
  Future<InternetConnectionStatus> get connectionStatus async {
    final bool isConnected = await _checkConnectivity();
    return isConnected
        ? InternetConnectionStatus.connected
        : InternetConnectionStatus.disconnected;
  }

  /// Checks if a specific host is reachable.
  ///
  /// This method sends a request to the given [option] and
  /// determines if the host is reachable.
  /// If slow connection detection is enabled, it also
  /// checks if the response time exceeds
  /// the configured threshold.
  Future<AddressCheckResult> isHostReachable(AddressCheckOption option) async {
    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      final http.Response response =
          await _httpClient.head(option.uri).timeout(option.timeout);
      stopwatch.stop();

      /*
      This condition considers any valid HTTP response
      (including informational, redirection, client error,
      and server error status codes) as an indication that
      the internet is available.

      Even if the server returns an error (e.g., 404 Not Found, 
      500 Internal Server Error), it proves that the internet connection
      is active because the device successfully communicated with the server.
      */

      if (response.statusCode >= 100 && response.statusCode < 600) {
        if (enableToCheckForSlowConnection &&
            stopwatch.elapsed > slowConnectionThreshold) {
          _emitStatus(InternetConnectionStatus.slow);
        } else {
          _emitStatus(
            InternetConnectionStatus.connected,
          );
        }
      } else {
        _emitStatus(InternetConnectionStatus.disconnected);
      }

      return AddressCheckResult(
        option,
        isSuccess: response.statusCode >= 100 && response.statusCode < 600,
      );
    } catch (e) {
      return AddressCheckResult(option, isSuccess: false);
    }
  }

  /// Triggers an immediate status update based on
  /// the current connection status.
  @visibleForTesting
  Future<void> maybeEmitStatusUpdate({
    Timer? timer,
    Function? cancelCallback,
  }) async {
    await _maybeEmitStatusUpdate(timer: timer, cancelCallback: cancelCallback);
  }

  /// Emits the given connection status to the status stream.
  void emitStatus(InternetConnectionStatus newStatus) {
    return _emitStatus(newStatus);
  }

  /// Internal method to emit the connection status if it has changed.
  void _emitStatus(InternetConnectionStatus newStatus) {
    if (_lastStatus != newStatus && hasListeners) {
      _statusController.add(newStatus);
    }
    _lastStatus = newStatus;
  }

  /// Schedules the next status update check.
  Future<void> _maybeEmitStatusUpdate({
    Timer? timer,
    Function? cancelCallback,
  }) async {
    _timerHandle?.cancel();
    // ignore: avoid_dynamic_calls
    cancelCallback?.call() ?? timer?.cancel();

    final bool isConnected = await _checkConnectivity();
    final InternetConnectionStatus status = isConnected
        ? InternetConnectionStatus.connected
        : InternetConnectionStatus.disconnected;

    _emitStatus(status);
    _scheduleNextStatusCheck();
  }

  /// Schedules the next status check based on the configured interval.
  void _scheduleNextStatusCheck() {
    if (hasListeners) {
      _timerHandle = Timer(checkInterval, _maybeEmitStatusUpdate);
    }
  }

  /// Starts monitoring the connectivity changes and triggers status updates.
  @visibleForTesting
  void startMonitoring() {
    return _startMonitoring();
  }

  /// Internal method to start monitoring the connectivity changes.
  void _startMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> connectivityList) async {
      if (connectivityList.contains(ConnectivityResult.none)) {
        _emitStatus(InternetConnectionStatus.disconnected);
      } else if (connectivityList.any(
        (ConnectivityResult result) =>
            result != ConnectivityResult.bluetooth &&
            (result == ConnectivityResult.wifi ||
                result == ConnectivityResult.mobile ||
                result == ConnectivityResult.ethernet ||
                result == ConnectivityResult.vpn ||
                result == ConnectivityResult.other),
      )) {
        await _maybeEmitStatusUpdate();
      }
    });

    _maybeEmitStatusUpdate(); // Initial status update
  }

  /// Stops monitoring the connectivity changes and
  /// cancels any scheduled checks.
  void _stopMonitoring() {
    _connectivitySubscription?.cancel();
    _timerHandle?.cancel();
    _timerHandle = null;
    _lastStatus = null;
  }

  /// Cancels any scheduled status updates.
  @visibleForTesting
  void cancelStatusUpdate() {
    return _cancelStatusUpdate();
  }

  /// Internal method to cancel any scheduled status updates.
  void _cancelStatusUpdate() {
    _timerHandle?.cancel();
    _timerHandle = null;
    _lastStatus = null;
  }

  /// Allows configuration of the checker.
  ///
  /// This method allows you to reconfigure the checker with new settings.
  /// You can change the timeout, interval, addresses to check, and the
  /// slow connection configuration.
  void configure({
    Duration? timeout,
    Duration? interval,
    List<AddressCheckOption>? addresses,
    SlowConnectionConfig? slowConnectionConfig, // Optional
  }) {
    if (timeout != null) {
      checkTimeout = timeout;
    }
    if (interval != null) {
      checkInterval = interval;
    }
    if (addresses != null) {
      this.addresses = addresses;
    }

    // Apply the new slow connection configuration if provided
    if (slowConnectionConfig != null) {
      enableToCheckForSlowConnection =
          slowConnectionConfig.enableToCheckForSlowConnection;
      slowConnectionThreshold = slowConnectionConfig.slowConnectionThreshold;
    }

    _maybeEmitStatusUpdate(); // Apply the new configuration immediately
  }

  /// Gets the timer handle for the scheduled status updates.
  @visibleForTesting
  Timer? get timerHandle => _timerHandle;

  /// Gets the last emitted connection status.
  @visibleForTesting
  InternetConnectionStatus? get lastStatus => _lastStatus;

  /// Sets the last emitted connection status for testing purposes.
  @visibleForTesting
  // ignore: avoid_setters_without_getters
  set setLastStatus(InternetConnectionStatus status) {
    _lastStatus = status;
  }

  /// Sets the last emitted connection status for testing purposes.
  @visibleForTesting
  // ignore: avoid_setters_without_getters
  set setRequireAllAddressesToRespond(bool value) {
    requireAllAddressesToRespond = value;
  }

  /// Disposes of the singleton instance and cleans up resources.
  ///
  /// This method stops monitoring the connectivity changes, cancels any
  /// scheduled status updates, and closes the status stream.
  void dispose() {
    _stopMonitoring(); // Stops monitoring and cancels the timer
    _statusController.close(); // Closes the stream controller
  }
}
