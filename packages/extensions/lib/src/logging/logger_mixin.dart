import '../system/disposable.dart';
import 'event_id.dart';
import 'log_level.dart';
import 'logger.dart';
import 'logger_information.dart';

mixin LoggerMixin on Logger {
  List<LoggerInformation>? loggers;
  List<MessageLogger>? messageLoggers;
  List<ScopeLogger>? scopeLoggers;

  @override
  void log<TState>({
    required LogLevel logLevel,
    required EventId eventId,
    required TState state,
    Object? error,
    required LogFormatter<TState> formatter,
  }) {
    var loggers = messageLoggers;
    if (loggers == null) {
      return;
    }

    List<Exception>? exceptions;
    for (var i = 0; i < loggers.length; i++) {
      var loggerInfo = loggers[i];
      if (!loggerInfo.isEnabled(logLevel)) {
        continue;
      }

      loggerLog<TState>(
        logLevel,
        eventId,
        loggerInfo.logger,
        error,
        formatter,
        exceptions,
        state,
      );
    }
  }

  static void loggerLog<TState>(
    LogLevel logLevel,
    EventId eventId,
    Logger logger,
    Object? error,
    LogFormatter<TState> formatter,
    List<Exception>? exceptions,
    TState state,
  ) {
    try {
      logger.log<TState>(
        logLevel: logLevel,
        state: state,
        eventId: eventId,
        error: error,
        formatter: formatter,
      );
    } catch (e) {
      exceptions ??= <Exception>[];
      exceptions.add(e as Exception);
    }
  }

  @override
  bool isEnabled(LogLevel logLevel) {
    var loggers = messageLoggers;
    if (loggers == null) {
      return false;
    }

    List<Exception>? exceptions;
    var i = 0;
    for (; i < loggers.length; i++) {
      final loggerInfo = loggers[i];
      if (!loggerInfo.isEnabled(logLevel)) {
        continue;
      }

      var (isEnabled, ex) =
          loggerIsEnabled(logLevel, loggerInfo.logger, exceptions);
      if (isEnabled) {
        break;
      }

      if (ex != null) {
        exceptions == null ? exceptions = ex : exceptions.addAll(exceptions);
      }
    }

    if (exceptions != null) {
      if (exceptions.isNotEmpty) {
        // ThrowLoggingError(exceptions);
      }
    }

    if (i < loggers.length) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Disposable beginScope<TState>(TState state) => Scope();

  static (bool, List<Exception>?) loggerIsEnabled(
    LogLevel logLevel,
    Logger logger,
    List<Exception>? exceptions,
  ) {
    try {
      if (logger.isEnabled(logLevel)) {
        return (true, null);
      }
      return (false, null);
    } on Exception catch (ex) {
      var newExceptions = <Exception>[];
      if (exceptions == null) {
        newExceptions.add(ex);
      } else {
        newExceptions = exceptions..add(ex);
      }
      return (false, newExceptions);
    }
  }
}
