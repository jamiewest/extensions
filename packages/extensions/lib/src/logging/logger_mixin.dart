import 'package:tuple/tuple.dart';

import '../primitives/disposable.dart';
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
    Exception? exception,
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
        exception,
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
    Exception? exception,
    LogFormatter<TState> formatter,
    List<Exception>? exceptions,
    TState state,
  ) {
    try {
      logger.log<TState>(
        logLevel: logLevel,
        state: state,
        eventId: eventId,
        exception: exception,
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

      var result = loggerIsEnabled(logLevel, loggerInfo.logger, exceptions);
      if (result.item1) {
        break;
      }

      if (result.item2 != null) {
        exceptions == null
            ? exceptions = result.item2
            : exceptions.addAll(exceptions);
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

  static Tuple2<bool, List<Exception>?> loggerIsEnabled(
    LogLevel logLevel,
    Logger logger,
    List<Exception>? exceptions,
  ) {
    var newExceptions = <Exception>[];

    try {
      if (logger.isEnabled(logLevel)) {
        return const Tuple2<bool, List<Exception>?>(true, null);
      }
    } on Exception catch (ex) {
      if (exceptions == null) {
        newExceptions.add(ex);
      } else {
        newExceptions = exceptions;
      }
    }

    return Tuple2<bool, List<Exception>?>(true, newExceptions);
  }
}
