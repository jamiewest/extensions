import 'dart:async';

import 'package:extensions/hosting.dart';
import 'package:extensions/logging.dart';
import 'package:extensions/src/shared/cancellation_token.dart';

// ignore: avoid_classes_with_only_static_members
class App {
  static Host? _host;

  static Host get host => _host ??= _buildHost();

  static Host _buildHost() => _host = Host.createDefaultBuilder()
      .configureServices((context, services) {
        services.addHostedService<ExampleBackgroundService>(
          (services) => ExampleBackgroundService(),
        );
      })
      .useConsoleLifetime()
      .build();
}

Future<void> main([List<String>? args]) async {
  await App.host.run();
}

class ExampleBackgroundService extends BackgroundService {
  late Logger _logger;
  ExampleBackgroundService() {
    _logger = App.host.services
        .getService<LoggerFactory>()
        .createLogger('ExampleBackgroundService');
  }

  @override
  Future<void> execute(CancellationToken stoppingToken) {
    _logger.logInformation('Starting');
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (stoppingToken.isCancellationRequested) {
        _logger.logInformation('Cancelling');
        timer.cancel();
      }
      _logger.logInformation('Woot');
    });

    return Future.value(null);
  }
}

class ExampleHostedService implements HostedService {
  Logger? _logger;

  ExampleHostedService() {
    _logger = App.host.services
        .getService<LoggerFactory>()
        .createLogger('ExampleHostedService');
    var appLifetime = App.host.services.getService<HostApplicationLifetime>();

    appLifetime.applicationStarted.register((state) => _onStarted());
    appLifetime.applicationStopping.register((state) => _onStopping());
    appLifetime.applicationStopped.register((state) => _onStopped());
  }

  @override
  Future<void> start(CancellationToken cancellationToken) {
    _logger!.logInformation('1. StartAsync has been called.');
    return Future.value();
  }

  @override
  Future<void> stop(CancellationToken cancellationToken) {
    _logger!.logInformation('4. StopAsync has been called.');
    return Future.value();
  }

  void _onStarted() {
    _logger!.logInformation('2. OnStarted has been called.');
  }

  void _onStopping() {
    _logger!.logInformation('3. OnStopping has been called.');
  }

  void _onStopped() {
    _logger!.logInformation('5. OnStopped has been called.');
  }
}
