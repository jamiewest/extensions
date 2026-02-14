import 'dart:async';
import 'dart:ui';

import 'package:extensions/hosting.dart';
import 'package:extensions/logging.dart';
import 'package:extensions/options.dart';
import 'package:extensions/system.dart';
import 'package:flutter/widgets.dart';

import 'flutter_application_lifetime.dart';
import 'flutter_error_handler.dart';
import 'flutter_lifetime_options.dart';

/// Bridges the `Host` lifecycle to Flutter's `runApp` and lifecycle events.
///
/// Responsibilities:
/// - Starts the Flutter app when the host signals `applicationStarted`.
/// - Wires Flutter error handlers into the host's logging pipeline.
/// - Logs lifecycle transitions (pause/resume/etc.) unless suppressed.
///
/// Typical usage (via `addFlutter` + `runApp`):
/// ```dart
/// final builder = Host.createApplicationBuilder()
///   ..addLogging((logging) => logging.addSimpleConsole())
///   ..services.addFlutter((flutter) {
///     flutter.runApp((sp) => MyApp(services: sp));
///   });
///
/// final host = builder.build();
/// Future<void> main() async => host.run();
/// ```
class FlutterLifetime implements HostLifetime {
  final Widget _application;
  final ErrorHandler _errorHandler;
  final HostEnvironment _environment;
  final FlutterApplicationLifetime _applicationLifetime;
  final FlutterLifetimeOptions _options;
  final Logger _logger;

  /// Creates the Flutter host lifetime implementation.
  ///
  /// Parameters are provided by the DI container during `Host` build:
  /// - [application] is the root widget produced by `runApp`.
  /// - [errorHandler] is the centralized error handler.
  /// - [environment] supplies host environment details.
  /// - [applicationLifetime] is the Flutter-specific lifetime.
  /// - [options] controls status message verbosity.
  /// - [loggerFactory] creates the lifetime logger.
  FlutterLifetime(
    Widget application,
    ErrorHandler errorHandler,
    HostEnvironment environment,
    HostApplicationLifetime applicationLifetime,
    Options<FlutterLifetimeOptions> options,
    LoggerFactory loggerFactory,
  ) : _application = application,
      _errorHandler = errorHandler,
      _environment = environment,
      _applicationLifetime = applicationLifetime as FlutterApplicationLifetime,
      _options = options.value!,
      _logger = loggerFactory.createLogger('Hosting.Lifetime');

  /// The host environment used for status messages and diagnostics.
  HostEnvironment get environment => _environment;

  /// The Flutter-specific application lifetime.
  FlutterApplicationLifetime get applicationLifetime => _applicationLifetime;

  @override
  /// Registers start callbacks and starts Flutter when the host starts.
  ///
  /// This method wires:
  /// - Host cancellation handling
  /// - Application lifetime events (started/stopping)
  /// - Flutter lifecycle events (pause/resume/etc.)
  /// - Flutter error routing
  ///
  /// It ultimately calls `runApp(_application)` when the host starts.
  Future<void> waitForStart(CancellationToken cancellationToken) async {
    if (cancellationToken.isCancellationRequested) {
      throw OperationCanceledException(cancellationToken: cancellationToken);
    }

    WidgetsFlutterBinding.ensureInitialized();

    final registrations = <CancellationTokenRegistration>[];
    var cancelled = false;

    void cancel(Object? _) {
      cancelled = true;
      for (final registration in registrations) {
        registration.dispose();
      }
      registrations.clear();

      applicationLifetime
        ..applicationPaused.remove(_onPaused)
        ..applicationResumed.remove(_onResumed)
        ..applicationInactive.remove(_onInactive)
        ..applicationHidden.remove(_onHidden)
        ..applicationDetached.remove(_onDetached);
    }

    registrations.add(cancellationToken.register(cancel));

    registrations.add(
      applicationLifetime.applicationStarted.register((state) {
        if (cancelled || cancellationToken.isCancellationRequested) {
          cancel(null);
          return;
        }

        (state as FlutterLifetime)._onApplicationStarted();
      }, this),
    );

    registrations.add(
      applicationLifetime.applicationStopping.register((state) {
        if (cancelled || cancellationToken.isCancellationRequested) {
          cancel(null);
          return;
        }

        (state as FlutterLifetime)._onApplicationStopping();
      }, this),
    );

    applicationLifetime
      ..applicationPaused.add(_onPaused)
      ..applicationResumed.add(_onResumed)
      ..applicationInactive.add(_onInactive)
      ..applicationHidden.add(_onHidden)
      ..applicationDetached.add(_onDetached);

    registrations.add(
      applicationLifetime.applicationStarted.register((_) {
        if (cancelled || cancellationToken.isCancellationRequested) {
          cancel(null);
          return;
        }

        FlutterError.onError = _errorHandler.onFlutterError;
        PlatformDispatcher.instance.onError = _errorHandler.onError;

        runApp(_application);
      }),
    );

    if (cancellationToken.isCancellationRequested) {
      cancel(null);
      throw OperationCanceledException(cancellationToken: cancellationToken);
    }
  }

  @override
  /// Requests application shutdown via the host lifetime.
  Future<void> stop(CancellationToken cancellationToken) async =>
      applicationLifetime.stopApplication();

  void _onApplicationStarted() {
    if (_options.suppressStatusMessages) return;
    _logger
      ..logInformation('Application started.')
      ..logInformation('Hosting environment: ${environment.environmentName}');
  }

  void _onApplicationStopping() {
    if (_options.suppressStatusMessages) return;
    _logger.logInformation('Application is shutting down...');
  }

  void _onPaused() {
    if (_options.suppressStatusMessages) return;
    _logger.logTrace('Application paused.');
  }

  void _onResumed() {
    if (_options.suppressStatusMessages) return;
    _logger.logTrace('Application resumed.');
  }

  void _onInactive() {
    if (_options.suppressStatusMessages) return;
    _logger.logTrace('Application is inactive.');
  }

  void _onHidden() {
    if (_options.suppressStatusMessages) return;
    _logger.logTrace('Application is hidden.');
  }

  void _onDetached() {
    if (_options.suppressStatusMessages) return;
    _logger.logTrace('Application is detached.');
  }
}
