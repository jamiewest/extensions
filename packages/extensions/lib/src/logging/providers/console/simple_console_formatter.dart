import 'dart:io';

import '../../external_scope_provider.dart';
import '../../log_level.dart';
import 'console_formatter.dart';
import 'console_formatter_names.dart';
import 'log_entry.dart';
import 'logger_color_behavior.dart';
import 'simple_console_formatter_options.dart';

/// A simple console formatter that formats log messages with timestamps,
/// log levels, categories, and exception details.
class SimpleConsoleFormatter extends ConsoleFormatter {
  /// Creates a new instance of [SimpleConsoleFormatter].
  SimpleConsoleFormatter(this._options)
      : super(ConsoleFormatterNames.simple);

  final SimpleConsoleFormatterOptions _options;

  static const String _messagePadding = '      ';
  static const String _newLineWithMessagePadding = '\n$_messagePadding';

  // ANSI color codes
  static const String _defaultForegroundColor = '\x1B[39m\x1B[22m';

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

    final logLevel = logEntry.logLevel;
    final logLevelString = _getLogLevelString(logLevel);

    String? timestamp;
    final timestampFormat = _options.timestampFormat;
    if (timestampFormat != null) {
      final dateTime = _options.useUtcTimestamp
          ? DateTime.now().toUtc()
          : DateTime.now();
      timestamp = _formatTimestamp(dateTime, timestampFormat);
    }

    final createDefaultLogMessage = message.isEmpty;

    // Example:
    // info: ConsoleApp.Program[10]
    //       Request received

    final logLevelColors = _getLogLevelConsoleColors(logLevel);
    final logLevelWritten = logLevelColors != null;

    // Write timestamp
    if (timestamp != null) {
      textWriter
        ..write(timestamp)
        ..write(' ');
    }

    // Write log level with color if enabled
    if (logLevelWritten) {
      textWriter.write(logLevelColors);
    }

    textWriter.write(logLevelString);

    if (logLevelWritten) {
      textWriter.write(_defaultForegroundColor);
    }

    textWriter
      ..write(': ')
      ..write(logEntry.category)
      ..write('[')
      ..write(logEntry.eventId.id)
      ..write(']');

    if (!_options.singleLine) {
      textWriter.write('\n');
    }

    // Write scopes
    _writeScopeInformation(textWriter, scopeProvider, _options.singleLine);

    // Write message
    if (!createDefaultLogMessage) {
      textWriter.write(_messagePadding);

      _writeMessage(textWriter, message, _options.singleLine);
    }

    // Write exception
    if (logEntry.exception != null) {
      _writeMessage(
        textWriter,
        logEntry.exception.toString(),
        _options.singleLine,
      );
    }

    if (_options.singleLine) {
      textWriter.write('\n');
    }
  }

  String _formatTimestamp(DateTime dateTime, String format) =>
      // Simple timestamp formatting
      // For more complex formats, consider using the intl package
      dateTime.toIso8601String();

  String _getLogLevelString(LogLevel logLevel) {
    switch (logLevel) {
      case LogLevel.trace:
        return 'trce';
      case LogLevel.debug:
        return 'dbug';
      case LogLevel.information:
        return 'info';
      case LogLevel.warning:
        return 'warn';
      case LogLevel.error:
        return 'fail';
      case LogLevel.critical:
        return 'crit';
      case LogLevel.none:
        return 'none';
    }
  }

  String? _getLogLevelConsoleColors(LogLevel logLevel) {
    if (!_shouldUseColors()) {
      return null;
    }

    // Return ANSI color codes based on log level
    switch (logLevel) {
      case LogLevel.critical:
      case LogLevel.error:
        return '\x1B[1m\x1B[31m'; // Bright red
      case LogLevel.warning:
        return '\x1B[1m\x1B[33m'; // Bright yellow
      case LogLevel.information:
        return '\x1B[1m\x1B[37m'; // Bright white
      case LogLevel.debug:
        return '\x1B[1m\x1B[90m'; // Bright gray
      case LogLevel.trace:
        return '\x1B[90m'; // Gray
      default:
        return _defaultForegroundColor;
    }
  }

  bool _shouldUseColors() {
    switch (_options.colorBehavior) {
      case LoggerColorBehavior.enabled:
        return true;
      case LoggerColorBehavior.disabled:
        return false;
      case LoggerColorBehavior.defaultBehavior:
        // Check if we're running in a terminal that supports colors
        // On mobile platforms (Android/iOS), disable colors
        if (Platform.isAndroid || Platform.isIOS) {
          return false;
        }
        // Check if stdout supports ANSI
        return stdout.supportsAnsiEscapes;
    }
  }

  void _writeMessage(
    StringBuffer textWriter,
    String message,
    bool singleLine,
  ) {
    if (singleLine) {
      textWriter
        ..write(' ')
        ..write(message.replaceAll('\n', ' '));
    } else {
      final newMessage = message.replaceAll('\n', _newLineWithMessagePadding);
      textWriter
        ..write(newMessage)
        ..write('\n');
    }
  }

  void _writeScopeInformation(
    StringBuffer textWriter,
    ExternalScopeProvider? scopeProvider,
    bool singleLine,
  ) {
    if (!_options.includeScopes || scopeProvider == null) {
      return;
    }

    var paddingNeeded = !singleLine;
    scopeProvider.forEachScope<Object?>((scope, _) {
      if (paddingNeeded) {
        paddingNeeded = false;
        textWriter
          ..write(_messagePadding)
          ..write('=> ');
      } else {
        textWriter.write(' => ');
      }
      textWriter.write(scope);
    }, null);

    if (!paddingNeeded && !singleLine) {
      textWriter.write('\n');
    }
  }
}
