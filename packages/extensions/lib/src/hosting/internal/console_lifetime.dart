import 'dart:async';
import 'dart:io';

import '../../logging/logger.dart';
import '../../logging/logger_extensions.dart';
import '../../logging/logger_factory.dart';
import '../../options/options.dart';
import '../../system/threading/cancellation_token.dart';
import '../console_lifetime_options.dart';
import '../host_application_lifetime.dart';
import '../host_environment.dart';
import '../host_lifetime.dart';
import '../host_options.dart';

/// Listens for Ctrl+C or SIGTERM and initiates shutdown.
class ConsoleLifetime implements HostLifetime {
  final ConsoleLifetimeOptions _options;
  final HostEnvironment _environment;
  final HostApplicationLifetime _applicationLifetime;
  final HostOptions _hostOptions;
  final Logger _logger;

  ConsoleLifetime(
    Options<ConsoleLifetimeOptions> options,
    HostEnvironment environment,
    HostApplicationLifetime applicationLifetime,
    Options<HostOptions> hostOptions,
    LoggerFactory loggerFactory,
  )   : _options = options.value!,
        _environment = environment,
        _applicationLifetime = applicationLifetime,
        _hostOptions = hostOptions.value!,
        _logger = loggerFactory.createLogger('Hosting.Lifetime');

  ConsoleLifetimeOptions get options => _options;

  HostEnvironment get environment => _environment;

  HostApplicationLifetime get applicationLifetime => _applicationLifetime;

  HostOptions get hostOptions => _hostOptions;

  @override
  Future<void> stop(CancellationToken cancellationToken) => Future.value();

  @override
  Future<void> waitForStart(CancellationToken cancellationToken) {
    if (!_options.suppressStatusMessages) {
      _applicationLifetime.applicationStarted.register(
        (state) => (state as ConsoleLifetime)._onApplicationStarted(),
        this,
      );
      _applicationLifetime.applicationStopping.register(
        (state) => (state as ConsoleLifetime)._onApplicationStopping(),
        this,
      );
    }

    ProcessSignal.sigint.watch().listen((signal) {
      applicationLifetime.stopApplication();
      exit(0);
    });

    ProcessSignal.sigterm.watch().listen((signal) {
      applicationLifetime.stopApplication();
      exit(0);
    });

    ProcessSignal.sighup.watch().listen((signal) {
      applicationLifetime.stopApplication();
      exit(0);
    });

    return Future.value();
  }

  void _onApplicationStarted() {
    _logger
      ..logInformation('Application started. Press Ctrl+C to shut down.')
      ..logInformation('Hosting environment: ${_environment.environmentName}')
      ..logInformation('Content root path: ${_environment.contentRootPath}');
  }

  void _onApplicationStopping() {
    _logger.logInformation('Application is shutting down...');
  }
}
