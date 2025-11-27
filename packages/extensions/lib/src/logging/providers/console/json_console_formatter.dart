import 'dart:convert';

import '../../external_scope_provider.dart';
import '../../log_level.dart';
import 'console_formatter.dart';
import 'console_formatter_names.dart';
import 'json_console_formatter_options.dart';
import 'log_entry.dart';

/// A console formatter that formats log messages as JSON.
///
/// This formatter outputs structured log data in JSON format, which is useful
/// for log aggregation systems and structured logging pipelines.
class JsonConsoleFormatter extends ConsoleFormatter {
  /// Creates a new instance of [JsonConsoleFormatter].
  JsonConsoleFormatter(this._options) : super(ConsoleFormatterNames.json);

  final JsonConsoleFormatterOptions _options;

  @override
  void write<TState>({
    required LogEntry<TState> logEntry,
    ExternalScopeProvider? scopeProvider,
    required StringBuffer textWriter,
  }) {
    final message = logEntry.formatter(logEntry.state, logEntry.exception);

    final json = <String, dynamic>{
      'Timestamp': _formatTimestamp(
        _options.useUtcTimestamp ? DateTime.now().toUtc() : DateTime.now(),
      ),
      'LogLevel': _getLogLevelString(logEntry.logLevel),
      'Category': logEntry.category,
      'EventId': {
        'Id': logEntry.eventId.id,
        if (logEntry.eventId.name != null) 'Name': logEntry.eventId.name,
      },
      if (message.isNotEmpty) 'Message': message,
    };

    // Add scopes if available
    if (_options.includeScopes && scopeProvider != null) {
      final scopes = <Object?>[];
      scopeProvider.forEachScope<Object?>((scope, _) {
        scopes.add(scope);
      }, null);
      if (scopes.isNotEmpty) {
        json['Scopes'] = scopes;
      }
    }

    // Add state if it's a Map
    if (logEntry.state is Map<String, dynamic>) {
      json['State'] = logEntry.state;
    }

    // Add exception if present
    if (logEntry.exception != null) {
      json['Exception'] = {
        'Type': logEntry.exception.runtimeType.toString(),
        'Message': logEntry.exception.toString(),
      };
    }

    // Encode to JSON
    final encoder = _options.useJsonIndentation
        ? const JsonEncoder.withIndent('  ')
        : const JsonEncoder();

    textWriter.write(encoder.convert(json));
  }

  String _formatTimestamp(DateTime dateTime) => dateTime.toIso8601String();

  String _getLogLevelString(LogLevel logLevel) {
    switch (logLevel) {
      case LogLevel.trace:
        return 'Trace';
      case LogLevel.debug:
        return 'Debug';
      case LogLevel.information:
        return 'Information';
      case LogLevel.warning:
        return 'Warning';
      case LogLevel.error:
        return 'Error';
      case LogLevel.critical:
        return 'Critical';
      case LogLevel.none:
        return 'None';
    }
  }
}
