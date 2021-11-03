import 'package:extensions/hosting.dart';
import 'package:extensions/src/hosting/hosting_host_builder_extensions_io.dart';

Future<void> main(List<String> args) async =>
    await Host.createDefaultBuilder(args)
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
    _logger.logInformation('1. Start has been called.');
    return;
  }

  @override
  Future<void> stop(CancellationToken cancellationToken) async {
    _logger.logInformation('4. Stop has been called.');
    return;
  }

  void _onStarted() {
    _logger.logInformation('2. OnStarted has been called.');
  }

  void _onStopping() {
    _logger.logInformation('3. OnStopping has been called.');
  }

  void _onStopped() {
    _logger.logInformation('5. OnStopped has been called.');
  }
}
