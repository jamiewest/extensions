import '../../logging/logger.dart';
import '../../system/threading/cancellation_token.dart';
import '../../system/threading/cancellation_token_source.dart';
import '../host_application_lifetime.dart';
import 'hosting_logger_extensions.dart';
import 'logger_event_ids.dart';

/// Allows consumers to perform cleanup during a graceful shutdown.
class ApplicationLifetime implements HostApplicationLifetime {
  final _startedSource = CancellationTokenSource();
  final _stoppingSource = CancellationTokenSource();
  final _stoppedSource = CancellationTokenSource();
  final Logger _logger;

  ApplicationLifetime(Logger logger) : _logger = logger;

  /// Triggered when the application host has fully started and is about to wait
  /// for a graceful shutdown.
  @override
  CancellationToken get applicationStarted => _startedSource.token;

  /// Triggered when the application host is performing a graceful shutdown.
  /// Request may still be in flight. Shutdown will block until this event
  /// completes.
  @override
  CancellationToken get applicationStopping => _stoppingSource.token;

  /// Triggered when the application host is performing a graceful shutdown.
  /// All requests should be complete at this point. Shutdown will block
  /// until this event completes.
  @override
  CancellationToken get applicationStopped => _stoppedSource.token;

  /// Signals the ApplicationStopping event and blocks until it completes.
  @override
  void stopApplication() {
    try {
      _stoppingSource.cancel();
    } on Exception catch (ex) {
      _logger.applicationError(
        LoggerEventIds.applicationStoppingException,
        'An error occurred stopping the application',
        ex,
      );
    }
  }

  /// Signals the ApplicationStarted event and blocks until it completes.
  void notifyStarted() {
    try {
      _startedSource.cancel();
    } on Exception catch (ex) {
      _logger.applicationError(
        LoggerEventIds.applicationStartupException,
        'An error occurred starting the application',
        ex,
      );
    }
  }

  /// Signals the ApplicationStopped event and blocks until it completes.
  void notifyStopped() {
    try {
      _stoppedSource.cancel();
    } on Exception catch (ex) {
      _logger.applicationError(
        LoggerEventIds.applicationStoppedException,
        'An error occurred stopping the application',
        ex,
      );
    }
  }
}
