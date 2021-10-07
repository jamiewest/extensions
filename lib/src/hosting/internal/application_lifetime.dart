import '../../logging/logger.dart';
import '../../shared/cancellation_token.dart';
import '../host_application_lifetime.dart';
import '../hosting_logger_extensions.dart';
import '../logger_event_ids.dart';

/// Allows consumers to perform cleanup during a graceful shutdown.
class ApplicationLifetime implements HostApplicationLifetime {
  final _startedSource = CancellationTokenSource();
  final _stoppingSource = CancellationTokenSource();
  final _stoppedSource = CancellationTokenSource();
  final Logger _logger;

  ApplicationLifetime(Logger logger) : _logger = logger;

  @override
  CancellationToken get applicationStarted => _startedSource.token;

  @override
  CancellationToken get applicationStopping => _stoppingSource.token;

  @override
  CancellationToken get applicationStopped => _stoppedSource.token;

  @override
  void stopApplication() {
    try {
      _executeHandlers(_stoppingSource);
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
      _executeHandlers(_startedSource);
    } on Exception catch (ex) {
      _logger.applicationError(
        LoggerEventIds.applicationStartupException,
        'An error occurred starting the application',
        ex,
      );
    }
  }

  void notifyStopped() {
    try {
      _executeHandlers(_stoppedSource);
    } on Exception catch (ex) {
      _logger.applicationError(
        LoggerEventIds.applicationStoppedException,
        'An error occurred stopping the application',
        ex,
      );
    }
  }

  void _executeHandlers(CancellationTokenSource cancel) {
    // Noop if this is already cancelled
    if (cancel.isCancellationRequested) {
      return;
    }

    // Run the cancellation token callbacks
    cancel.cancel();
  }
}
