import 'package:tuple/tuple.dart';

import '../shared/disposable.dart';
import 'event_id.dart';
import 'log_level.dart';
import 'logger_information.dart';

/// Function to create a `String` message of the `state` and `exception`.
typedef LogFormatter<TState> = String Function(
  TState state,
  Exception? exception,
);

/// Represents a type used to perform logging.
///
/// Aggregates most logging patterns to a single method.
class Logger {
  /// Writes a log entry.
  external void log<TState>({
    required LogLevel logLevel,
    required EventId eventId,
    required TState state,
    Exception? exception,
    required LogFormatter<TState> formatter,
  });

  /// Checks if the given [logLevel] is enabled.
  external bool isEnabled(LogLevel logLevel);

  /// Begins a logical operation scope.
  external Disposable beginScope<TState>(TState state);
}

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
      // TODO: Catch the correct exception here.
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

  static Tuple2<bool, List<Exception>?> loggerIsEnabled(
    LogLevel logLevel,
    Logger logger,
    List<Exception>? exceptions,
  ) {
    var _exceptions = <Exception>[];

    try {
      if (logger.isEnabled(logLevel)) {
        return const Tuple2<bool, List<Exception>?>(true, null);
      }
    } on Exception catch (ex) {
      if (exceptions == null) {
        _exceptions.add(ex);
      } else {
        _exceptions = exceptions;
      }
    }

    return Tuple2<bool, List<Exception>?>(true, _exceptions);
  }
}
