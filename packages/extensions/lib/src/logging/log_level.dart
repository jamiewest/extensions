enum LogLevel {
  /// Logs that contain the most detailed messages. These messages may contain
  /// sensitive application data. These messages are disabled by default and
  /// should never be enabled in a production environment.
  trace,

  /// Logs that are used for interactive investigation during development.
  /// These logs should primarily contain information useful for debugging and
  /// have no long-term value.
  debug,

  /// Logs that track the general flow of the application. These logs should
  /// have long-term value.
  information,

  /// Logs that highlight an abnormal or unexpected event in the application
  /// flow, but do not otherwise cause the application execution to stop.
  warning,

  /// Logs that highlight when the current flow of execution is stopped due to
  /// a failure. These should indicate a failure in the current activity, not
  /// an application-wide failure.
  error,

  /// Logs that describe an unrecoverable application or system crash, or a
  /// catastrophic failure that requires immediate attention.
  critical,

  /// Not used for writing log messages. Specifies that a logging category
  /// should not write any messages.
  none,
}

extension LogLevelExtensions on LogLevel {
  int get value {
    switch (this) {
      case LogLevel.trace:
        return 0;
      case LogLevel.debug:
        return 1;
      case LogLevel.information:
        return 2;
      case LogLevel.warning:
        return 3;
      case LogLevel.error:
        return 4;
      case LogLevel.critical:
        return 5;
      case LogLevel.none:
        return 6;
      default:
        return 6;
    }
  }

  String get name {
    var s = toString().split('.');
    return '${s.first}.${s.last[0].toUpperCase()}${s.last.substring(1)}';
  }
}
