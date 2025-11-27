import '../../external_scope_provider.dart';
import '../../log_level.dart';
import 'console_formatter.dart';
import 'console_formatter_names.dart';
import 'log_entry.dart';
import 'systemd_console_formatter_options.dart';

/// A console formatter that formats log messages for systemd journal.
///
/// This formatter outputs log messages in a format suitable for systemd's
/// structured logging, including priority levels compatible with syslog.
class SystemdConsoleFormatter extends ConsoleFormatter {
  /// Creates a new instance of [SystemdConsoleFormatter].
  SystemdConsoleFormatter(this._options)
      : super(ConsoleFormatterNames.systemd);

  final SystemdConsoleFormatterOptions _options;

  @override
  void write<TState>({
    required LogEntry<TState> logEntry,
    ExternalScopeProvider? scopeProvider,
    required StringBuffer textWriter,
  }) {
    final message = logEntry.formatter(logEntry.state, logEntry.exception);
    if (message.isEmpty && logEntry.exception == null) {
      return;
    }

    // Write systemd priority (syslog severity)
    final priority = _getSystemdPriority(logEntry.logLevel);
    textWriter.write('<$priority>');

    // Write timestamp if configured
    if (_options.timestampFormat != null) {
      final dateTime = _options.useUtcTimestamp
          ? DateTime.now().toUtc()
          : DateTime.now();
      textWriter
        ..write(_formatTimestamp(dateTime))
        ..write(' ');
    }

    // Write category and event ID
    textWriter
      ..write(logEntry.category)
      ..write('[')
      ..write(logEntry.eventId.id)
      ..write('] ');

    // Write scopes if enabled
    if (_options.includeScopes && scopeProvider != null) {
      scopeProvider.forEachScope<Object?>((scope, _) {
        textWriter
          ..write(scope)
          ..write(' => ');
      }, null);
    }

    // Write message
    if (message.isNotEmpty) {
      textWriter.write(message);
    }

    // Write exception if present
    if (logEntry.exception != null) {
      textWriter
        ..write(' ')
        ..write(logEntry.exception.toString());
    }
  }

  String _formatTimestamp(DateTime dateTime) => dateTime.toIso8601String();

  /// Gets the systemd priority level (syslog severity).
  ///
  /// Priority levels:
  /// 0 - Emergency (not used)
  /// 1 - Alert (not used)
  /// 2 - Critical
  /// 3 - Error
  /// 4 - Warning
  /// 5 - Notice (Information)
  /// 6 - Informational (Debug)
  /// 7 - Debug (Trace)
  int _getSystemdPriority(LogLevel logLevel) {
    switch (logLevel) {
      case LogLevel.trace:
        return 7; // Debug
      case LogLevel.debug:
        return 6; // Informational
      case LogLevel.information:
        return 5; // Notice
      case LogLevel.warning:
        return 4; // Warning
      case LogLevel.error:
        return 3; // Error
      case LogLevel.critical:
        return 2; // Critical
      case LogLevel.none:
        return 6; // Default to Informational
    }
  }
}
