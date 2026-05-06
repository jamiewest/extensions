import 'package:extensions/dependency_injection.dart';
import 'package:extensions/hosting.dart';
import 'package:extensions/logging.dart';
import 'package:extensions/src/hosting/hosting_host_builder_extensions_io.dart';
import 'package:extensions/system.dart';

/// Demonstrates hosted-service lifecycle callbacks in a default host.
///
/// Run this file to observe ordered start/stop and lifetime event logs.
Future<void> main(List<String> args) async => Host.createDefaultBuilder()
    .configureServices(
      (_, services) => services.addHostedService<ExampleHostedService>(
        (services) => ExampleHostedService(
          services
              .getRequiredService<LoggerFactory>()
              .createLogger('ExampleHostedService'),
          services.getRequiredService<HostApplicationLifetime>(),
        ),
      ),
    )
    .useConsoleLifetime(null)
    .build()
    .run();

class ExampleHostedService extends HostedService {
  final Logger _logger;

  ExampleHostedService(
    Logger logger,
    HostApplicationLifetime lifetime,
  ) : _logger = logger {
    lifetime
      ..applicationStarted.register((_) => _onStarted())
      ..applicationStopping.register((_) => _onStopping())
      ..applicationStopped.register((_) => _onStopped());
  }

  @override
  Future<void> start(CancellationToken cancellationToken) async {
    _logger.logInformation('=== Host Lifecycle Example ===');
    _logger.logInformation('1. `start` has been called.');
    return;
  }

  @override
  Future<void> stop(CancellationToken cancellationToken) async {
    _logger.logInformation('4. `stop` has been called.');
    return;
  }

  void _onStarted() {
    _logger.logInformation('2. `applicationStarted` callback ran.');
  }

  void _onStopping() {
    _logger.logInformation('3. `applicationStopping` callback ran.');
  }

  void _onStopped() {
    _logger.logInformation('5. `applicationStopped` callback ran.');
  }
}
