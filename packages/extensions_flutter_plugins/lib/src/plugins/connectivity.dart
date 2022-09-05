import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:extensions_flutter/extensions_flutter.dart';

class ConnectivityService extends BackgroundService {
  final Logger _logger;

  ConnectivityService({
    required Logger logger,
  })  : _logger = logger,
        connectivity = Connectivity() {
    connectivity.onConnectivityChanged.listen((connectivity) {
      _logger.logDebug('Connection is \'${connectivity.name}\'');
    });
  }

  final Connectivity connectivity;

  @override
  Future<void> execute(CancellationToken stoppingToken) async {
    _logger.logTrace('ConnectivityService is starting...');
    await Connectivity().checkConnectivity();

    stoppingToken.register((state) async {
      _logger.logTrace('ConnectivityService is stopping...');
    });
  }
}
