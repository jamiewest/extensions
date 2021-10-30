import 'dart:async';

import 'package:extensions/hosting.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityBackgroundService extends BackgroundService {
  StreamSubscription<ConnectivityResult>? _subscription;
  final Logger _logger;

  ConnectivityBackgroundService(Logger logger) : _logger = logger;

  @override
  Future<void> execute(CancellationToken stoppingToken) async {
    _logger.logDebug('Starting connectivity service');

    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile) {
        _logger.logInformation('Connected to mobile');
      } else if (result == ConnectivityResult.wifi) {
        _logger.logInformation('Connected to wifi');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_subscription != null) {
      _subscription!.cancel();
    }
  }
}
