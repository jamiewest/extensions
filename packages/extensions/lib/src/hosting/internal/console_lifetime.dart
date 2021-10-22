import 'dart:async';
import 'dart:io';

import '../../../hosting.dart';
import '../../logging/logger.dart';
import '../../logging/logger_extensions.dart';
import '../../logging/logger_factory.dart';
import '../../options/options.dart';
import '../../shared/cancellation_token.dart';
import '../host_application_lifetime.dart';
import '../host_environment.dart';
import '../host_lifetime.dart';
import '../host_options.dart';
import 'console_lifetime_options.dart';

/// Listens for Ctrl+C or SIGTERM and initiates shutdown.
class ConsoleLifetime extends HostLifetime {
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
  )   : _options = options.value,
        _environment = environment,
        _applicationLifetime = applicationLifetime,
        _hostOptions = hostOptions.value,
        _logger = loggerFactory.createLogger('Microsoft.Hosting.Lifetime');

  ConsoleLifetimeOptions get options => _options;

  HostEnvironment get environment => _environment;

  HostApplicationLifetime get applicationLifetime => _applicationLifetime;

  HostOptions get hostOptions => _hostOptions;

  @override
  Future<void> stop(CancellationToken cancellationToken) {
    // There's nothing to do here
    var completer = Completer()..complete();
    return completer.future;
  }

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
      _onProcessExit();
    });

    //ProcessSignal.sigquit.watch().listen((signal) {
    //  print('sigquit');
    //  _onProcessExit();
    //  exit(0);
    //});

    ProcessSignal.sigterm.watch().listen((signal) {
      print('sigterm');
      _onProcessExit();
      exit(0);
    });

    return Future.value(null);
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

  void _onProcessExit() {
    applicationLifetime.stopApplication();
  }
}
