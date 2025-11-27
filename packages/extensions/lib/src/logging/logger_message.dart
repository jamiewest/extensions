import '../system/disposable.dart';
import 'event_id.dart';
import 'log_level.dart';
import 'logger.dart';

/// Options for configuring logger message delegates.
class LogDefineOptions {
  /// Creates a new instance of [LogDefineOptions].
  LogDefineOptions({this.skipEnabledCheck = false});

  /// Gets or sets a flag that indicates whether to skip the enabled check for
  /// the log level when logging.
  ///
  /// Setting this to true improves performance by avoiding the enabled check,
  /// but means the delegate will always execute formatting logic even when
  /// the log level is disabled.
  final bool skipEnabledCheck;
}

/// Creates delegates for logging that can be cached and reused for improved
/// performance.
///
/// These methods create delegates that avoid repeated allocations during
/// logging operations by caching formatters and using closures.
class LoggerMessage {
  /// Defines a log message with no parameters.
  static void Function(Logger, Exception?) define(
    LogLevel logLevel,
    EventId eventId,
    String formatString, {
    LogDefineOptions? options,
  }) {
    final skipCheck = options?.skipEnabledCheck ?? false;

    return (logger, exception) {
      if (skipCheck || logger.isEnabled(logLevel)) {
        logger.log(
          logLevel: logLevel,
          eventId: eventId,
          state: formatString,
          error: exception,
          formatter: (state, error) => state,
        );
      }
    };
  }

  /// Defines a log message with one parameter.
  static void Function(Logger, T1, Exception?) define1<T1>(
    LogLevel logLevel,
    EventId eventId,
    String formatString, {
    LogDefineOptions? options,
  }) {
    final skipCheck = options?.skipEnabledCheck ?? false;

    return (logger, arg1, exception) {
      if (skipCheck || logger.isEnabled(logLevel)) {
        logger.log(
          logLevel: logLevel,
          eventId: eventId,
          state: (arg1,),
          error: exception,
          formatter: (state, error) =>
              formatString.replaceAll('{0}', state.$1.toString()),
        );
      }
    };
  }

  /// Defines a log message with two parameters.
  static void Function(Logger, T1, T2, Exception?) define2<T1, T2>(
    LogLevel logLevel,
    EventId eventId,
    String formatString, {
    LogDefineOptions? options,
  }) {
    final skipCheck = options?.skipEnabledCheck ?? false;

    return (logger, arg1, arg2, exception) {
      if (skipCheck || logger.isEnabled(logLevel)) {
        logger.log(
          logLevel: logLevel,
          eventId: eventId,
          state: (arg1, arg2),
          error: exception,
          formatter: (state, error) => formatString
              .replaceAll('{0}', state.$1.toString())
              .replaceAll('{1}', state.$2.toString()),
        );
      }
    };
  }

  /// Defines a log message with three parameters.
  static void Function(Logger, T1, T2, T3, Exception?) define3<T1, T2, T3>(
    LogLevel logLevel,
    EventId eventId,
    String formatString, {
    LogDefineOptions? options,
  }) {
    final skipCheck = options?.skipEnabledCheck ?? false;

    return (logger, arg1, arg2, arg3, exception) {
      if (skipCheck || logger.isEnabled(logLevel)) {
        logger.log(
          logLevel: logLevel,
          eventId: eventId,
          state: (arg1, arg2, arg3),
          error: exception,
          formatter: (state, error) => formatString
              .replaceAll('{0}', state.$1.toString())
              .replaceAll('{1}', state.$2.toString())
              .replaceAll('{2}', state.$3.toString()),
        );
      }
    };
  }

  /// Defines a log message with four parameters.
  static void Function(Logger, T1, T2, T3, T4, Exception?)
      define4<T1, T2, T3, T4>(
    LogLevel logLevel,
    EventId eventId,
    String formatString, {
    LogDefineOptions? options,
  }) {
    final skipCheck = options?.skipEnabledCheck ?? false;

    return (logger, arg1, arg2, arg3, arg4, exception) {
      if (skipCheck || logger.isEnabled(logLevel)) {
        logger.log(
          logLevel: logLevel,
          eventId: eventId,
          state: (arg1, arg2, arg3, arg4),
          error: exception,
          formatter: (state, error) => formatString
              .replaceAll('{0}', state.$1.toString())
              .replaceAll('{1}', state.$2.toString())
              .replaceAll('{2}', state.$3.toString())
              .replaceAll('{3}', state.$4.toString()),
        );
      }
    };
  }

  /// Defines a log scope with no parameters.
  static Disposable? Function(Logger) defineScope(String formatString) =>
      (logger) => logger.beginScope(formatString);

  /// Defines a log scope with one parameter.
  static Disposable? Function(Logger, T1) defineScope1<T1>(
    String formatString,
  ) =>
      (logger, arg1) => logger.beginScope(
            formatString.replaceAll('{0}', arg1.toString()),
          );

  /// Defines a log scope with two parameters.
  static Disposable? Function(Logger, T1, T2) defineScope2<T1, T2>(
    String formatString,
  ) =>
      (logger, arg1, arg2) => logger.beginScope(
            formatString
                .replaceAll('{0}', arg1.toString())
                .replaceAll('{1}', arg2.toString()),
          );

  /// Defines a log scope with three parameters.
  static Disposable? Function(Logger, T1, T2, T3) defineScope3<T1, T2, T3>(
    String formatString,
  ) =>
      (logger, arg1, arg2, arg3) => logger.beginScope(
            formatString
                .replaceAll('{0}', arg1.toString())
                .replaceAll('{1}', arg2.toString())
                .replaceAll('{2}', arg3.toString()),
          );
}
