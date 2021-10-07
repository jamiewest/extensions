import '../logging/event_id.dart';
import '../logging/log_level.dart';
import '../logging/logger.dart';
import '../logging/logger_extensions.dart';
import 'logger_event_ids.dart';

extension HostingLoggerExtensions on Logger {
  void applicationError(
    EventId eventId,
    String message,
    Exception exception,
  ) {
    logCritical(
      message,
      eventId: eventId,
      exception: exception,
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
        exception: ex,
      );
    }
  }

  void backgroundServiceFaulted(Exception ex) {
    if (isEnabled(LogLevel.debug)) {
      logError(
        'BackgroundService failed',
        //eventId: LoggerEventIds.backgroundServiceFaulted,
        exception: ex,
      );
    }
  }
}
