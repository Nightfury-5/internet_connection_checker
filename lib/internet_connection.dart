part of internet_connection_checker;

/// This is a singleton that can be accessed like a regular constructor
/// i.e. [InternetConnectionChecker()] always returns the same instance.
class InternetConnectionChecker {
  /// This is a singleton that can be accessed like a regular constructor
  /// i.e. InternetConnectionChecker() always returns the same instance.
  factory InternetConnectionChecker() => _instance;

  /// Creates an instance of the [InternetConnectionChecker]. This can be
  /// registered in any dependency injection framework with custom values for
  /// the [checkTimeout] and [checkInterval].
  InternetConnectionChecker.createInstance({
    this.checkTimeout = DEFAULT_TIMEOUT,
    this.checkInterval = DEFAULT_INTERVAL,
    List<AddressCheckOptions>? addresses,
  }) {
    this.addresses = addresses ??
        DEFAULT_ADDRESSES
            .map(
              (AddressCheckOptions e) => AddressCheckOptions(
                e.address,
                port: e.port,
                timeout: checkTimeout,
              ),
            )
            .toList();

    // immediately perform an initial check so we know the last status?
    // connectionStatus.then((status) => _lastStatus = status);

    // start sending status updates to onStatusChange when there are listeners
    // (emits only if there's any change since the last status update)
    _statusController.onListen = () {
      _maybeEmitStatusUpdate();
    };

    // stop sending status updates when no one is listening
    _statusController.onCancel = () {
      _timerHandle?.cancel();
      _lastStatus = null; // reset last status
    };
  }

  /// More info on why default port is 53
  /// here:
  /// - https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
  /// - https://www.google.com/search?q=dns+server+port
  static const int DEFAULT_PORT = 53;

  /// Default timeout is 10 seconds.
  ///
  /// Timeout is the number of seconds before a request is dropped
  /// and an address is considered unreachable
  static const Duration DEFAULT_TIMEOUT = Duration(seconds: 10);

  /// Default interval is 10 seconds
  ///
  /// Interval is the time between automatic checks
  static const Duration DEFAULT_INTERVAL = Duration(seconds: 10);

  /// Predefined reliable addresses. This is opinionated
  /// but should be enough. See https://www.dnsperf.com/#!dns-resolvers
  ///
  /// Addresses info:
  ///
  /// <!-- kinda hackish ^_^ -->
  /// <style>
  /// table {
  ///   width: 100%;
  ///   border-collapse: collapse;
  /// }
  /// th, td { padding: 5px; border: 1px solid lightgrey; }
  /// thead { border-bottom: 2px solid lightgrey; }
  /// </style>
  ///
  /// | Address        | Provider   | Info                                            |
  /// |:---------------|:-----------|:------------------------------------------------|
  /// | 1.1.1.1        | CloudFlare | https://1.1.1.1                                 |
  /// | 1.0.0.1        | CloudFlare | https://1.1.1.1                                 |
  /// | 8.8.8.8        | Google     | https://developers.google.com/speed/public-dns/ |
  /// | 8.8.4.4        | Google     | https://developers.google.com/speed/public-dns/ |
  /// | 208.67.222.222 | OpenDNS    | https://use.opendns.com/                        |
  /// | 208.67.220.220 | OpenDNS    | https://use.opendns.com/                        |
  static final List<AddressCheckOptions> DEFAULT_ADDRESSES =
      List<AddressCheckOptions>.unmodifiable(
    <AddressCheckOptions>[
      AddressCheckOptions(
        InternetAddress(
          '1.1.1.1', // CloudFlare
          type: InternetAddressType.IPv4,
        ),
      ),
      AddressCheckOptions(
        InternetAddress(
          '2606:4700:4700::1111', // CloudFlare
          type: InternetAddressType.IPv6,
        ),
      ),
      AddressCheckOptions(
        InternetAddress(
          '8.8.4.4', // Google
          type: InternetAddressType.IPv4,
        ),
      ),
      AddressCheckOptions(
        InternetAddress(
          '2001:4860:4860::8888', // Google
          type: InternetAddressType.IPv6,
        ),
      ),
      AddressCheckOptions(
        InternetAddress(
          '208.67.222.222', // OpenDNS
          type: InternetAddressType.IPv4,
        ), // OpenDNS
      ),
      AddressCheckOptions(
        InternetAddress(
          '2620:0:ccc::2', // OpenDNS
          type: InternetAddressType.IPv6,
        ), // OpenDNS
      ),
    ],
  );

  late List<AddressCheckOptions> _addresses;

  /// A list of internet addresses (with port and timeout) to ping.
  ///
  /// These should be globally available destinations.
  /// Default is [DEFAULT_ADDRESSES].
  ///
  /// When [hasConnection] or [connectionStatus] is called,
  /// this utility class tries to ping every address in this list.
  ///
  /// The provided addresses should be good enough to test for data connection
  /// but you can, of course, supply your own.
  ///
  /// See [AddressCheckOptions] for more info.
  List<AddressCheckOptions> get addresses => _addresses;

  set addresses(List<AddressCheckOptions> value) {
    _addresses = List<AddressCheckOptions>.unmodifiable(value);
    _maybeEmitStatusUpdate();
  }

  static final InternetConnectionChecker _instance =
      InternetConnectionChecker.createInstance();

  /// Ping a single address. See [AddressCheckOptions] for
  /// info on the accepted argument.
  Future<AddressCheckResult> isHostReachable(
    AddressCheckOptions options,
  ) async {
    Socket? sock;
    try {
      sock = await Socket.connect(
        options.address,
        options.port,
        timeout: options.timeout,
      )
        ..destroy();
      return AddressCheckResult(
        options,
        isSuccess: true,
      );
    } catch (e) {
      sock?.destroy();
      return AddressCheckResult(
        options,
        isSuccess: false,
      );
    }
  }

  /// Initiates a request to each address in [addresses].
  /// If at least one of the addresses is reachable
  /// we assume an internet connection is available and return `true`.
  /// `false` otherwise.
  Future<bool> get hasConnection async {
    if (kIsWeb) {
      return html.window.navigator.onLine ?? false;
    }

    final Completer<bool> result = Completer<bool>();
    int length = addresses.length;

    for (final AddressCheckOptions addressOptions in addresses) {
      // ignore: unawaited_futures
      isHostReachable(addressOptions).then(
        (AddressCheckResult request) {
          length -= 1;
          if (!result.isCompleted) {
            if (request.isSuccess) {
              result.complete(true);
            } else if (length == 0) {
              result.complete(false);
            }
          }
        },
      );
    }

    return result.future;
  }

  /// Initiates a request to each address in [addresses].
  /// If at least one of the addresses is reachable
  /// we assume an internet connection is available and return
  /// [InternetConnectionStatus.connected].
  /// [InternetConnectionStatus.disconnected] otherwise.
  Future<InternetConnectionStatus> get connectionStatus async {
    return await hasConnection
        ? InternetConnectionStatus.connected
        : InternetConnectionStatus.disconnected;
  }

  /// The interval between periodic checks. Periodic checks are
  /// only made if there's an attached listener to [onStatusChange].
  /// If that's the case [onStatusChange] emits an update only if
  /// there's change from the previous status.
  ///
  /// Defaults to [DEFAULT_INTERVAL] (10 seconds).
  final Duration checkInterval;

  /// The timeout period before a check request is dropped and an address is
  /// considered unreachable.
  ///
  /// Defaults to [DEFAULT_TIMEOUT] (10 seconds).
  final Duration checkTimeout;

  // Checks the current status, compares it with the last and emits
  // an event only if there's a change and there are attached listeners
  //
  // If there are listeners, a timer is started which runs this function again
  // after the specified time in 'checkInterval'
  Future<void> _maybeEmitStatusUpdate([
    Timer? timer,
  ]) async {
    // just in case
    _timerHandle?.cancel();
    timer?.cancel();

    final InternetConnectionStatus currentStatus = await connectionStatus;

    // only send status update if last status differs from current
    // and if someone is actually listening
    if (_lastStatus != currentStatus && _statusController.hasListener) {
      _statusController.add(currentStatus);
    }

    // start new timer only if there are listeners
    if (!_statusController.hasListener) return;
    _timerHandle = Timer(checkInterval, _maybeEmitStatusUpdate);

    // update last status
    _lastStatus = currentStatus;
  }

  // _lastStatus should only be set by _maybeEmitStatusUpdate()
  // and the _statusController's.onCancel event handler
  InternetConnectionStatus? _lastStatus;
  Timer? _timerHandle;

  // controller for the exposed 'onStatusChange' Stream
  final StreamController<InternetConnectionStatus> _statusController =
      StreamController<InternetConnectionStatus>.broadcast();

  /// Subscribe to this stream to receive events whenever the
  /// [InternetConnectionStatus] changes. When a listener is attached
  /// a check is performed immediately and the status ([InternetConnectionStatus])
  /// is emitted. After that a timer starts which performs
  /// checks with the specified interval - [checkInterval].
  /// Default is [DEFAULT_INTERVAL].
  ///
  /// *As long as there's an attached listener, checks are being performed,
  /// so remember to dispose of the subscriptions when they're no longer needed.*
  ///
  /// Example:
  ///
  /// ```dart
  /// var listener = InternetConnectionChecker().onStatusChange.listen((status) {
  ///   switch(status) {
  ///     case InternetConnectionStatus.connected:
  ///       print('Data connection is available.');
  ///       break;
  ///     case InternetConnectionStatus.disconnected:
  ///       print('You are disconnected from the internet.');
  ///       break;
  ///   }
  /// });
  /// ```
  ///
  /// *Note: Remember to dispose of any listeners,
  /// when they're not needed anymore,
  /// e.g. in a* `StatefulWidget`'s *dispose() method*
  ///
  /// ```dart
  /// ...
  /// @override
  /// void dispose() {
  ///   listener.cancel();
  ///   super.dispose();
  /// }
  /// ...
  /// ```
  ///
  /// For as long as there's an attached listener, requests are
  /// being made with an interval of `checkInterval`. The timer stops
  /// when an automatic check is currently executed, so this interval
  /// is a bit longer actually (the maximum would be `checkInterval` +
  /// the maximum timeout for an address in `addresses`). This is by design
  /// to prevent multiple automatic calls to `connectionStatus`, which
  /// would wreck havoc.
  ///
  /// You can, of course, override this behavior by implementing your own
  /// variation of time-based checks and calling either `connectionStatus`
  /// or `hasConnection` as many times as you want.
  ///
  /// When all the listeners are removed from `onStatusChange`, the internal
  /// timer is cancelled and the stream does not emit events.
  Stream<InternetConnectionStatus> get onStatusChange =>
      _statusController.stream;

  /// Returns true if there are any listeners attached to [onStatusChange]
  bool get hasListeners => _statusController.hasListener;

  /// Alias for [hasListeners]
  bool get isActivelyChecking => _statusController.hasListener;
}
