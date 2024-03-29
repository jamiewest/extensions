import '../logging/event_id.dart';
import '../logging/log_level.dart';
import '../logging/logger.dart';
import '../logging/logger_extensions.dart';
import 'logger_event_ids.dart';

extension HostingLoggerExtensions on Logger {
  void applicationError(
    EventId eventId,
    String message,
    Object error,
  ) {
    logCritical(
      message,
      eventId: eventId,
      error: error,
    );
  }

  void starting() {
    if (isEnabled(LogLevel.debug)) {
      logDebug(
        'Hosting starting',
        eventId: LoggerEventIds.starting,
      );
    }
  }

  void started() {
    if (isEnabled(LogLevel.debug)) {
      logDebug(
        'Hosting started',
        eventId: LoggerEventIds.started,
      );
    }
  }

  void stopping() {
    if (isEnabled(LogLevel.debug)) {
      logDebug(
        'Hosting stopping',
        eventId: LoggerEventIds.stopping,
      );
    }
  }

  void stopped() {
    if (isEnabled(LogLevel.debug)) {
      logDebug(
        'Hosting stopped',
        eventId: LoggerEventIds.stopped,
      );
    }
  }

  void stoppedWithException(Exception ex) {
    if (isEnabled(LogLevel.debug)) {
      logDebug(
        'Hosting shutdown exception',
        eventId: LoggerEventIds.stoppedWithException,
        error: ex,
      );
    }
  }

  void backgroundServiceFaulted(Exception ex) {
    if (isEnabled(LogLevel.error)) {
      logError(
        'BackgroundService failed',
        eventId: LoggerEventIds.backgroundServiceFaulted,
        error: ex,
      );
    }
  }

  void backgroundServiceStoppingHost(Exception ex) {
    if (isEnabled(LogLevel.critical)) {
      logCritical(
        '''The HostOptions.backgroundServiceExceptionBehavior is configured 
        to StopHost. A BackgroundService has thrown an unhandled exception, 
        and the Host instance is stopping. To avoid this behavior, configure 
        this to Ignore; however the BackgroundService will not be restarted.''',
        eventId: LoggerEventIds.backgroundServiceStoppingHost,
        error: ex,
      );
    }
  }

  void hostedServiceStartupFaulted(Exception? ex) {
    if (isEnabled(LogLevel.error)) {
      logError(
        'Hosting failed to start',
        eventId: LoggerEventIds.hostedServiceStartupFaulted,
        error: ex,
      );
    }
  }
}
