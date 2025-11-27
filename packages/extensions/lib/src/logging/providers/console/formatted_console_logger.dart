import 'dart:io';

import '../../../system/disposable.dart';
import '../../event_id.dart';
import '../../external_scope_provider.dart';
import '../../log_level.dart';
import '../../logger.dart';
import '../../null_scope.dart';
import 'console_formatter.dart';
import 'log_entry.dart';

/// A logger that writes formatted messages to the console output.
class FormattedConsoleLogger implements Logger {
  /// Creates a new instance of [FormattedConsoleLogger].
  FormattedConsoleLogger(
    this.name,
    this._formatter,
    this._scopeProvider,
  );

  /// The name of the logger.
  final String name;

  final ConsoleFormatter _formatter;
  final ExternalScopeProvider? _scopeProvider;

  @override
  Disposable beginScope<TState>(TState state) =>
      _scopeProvider?.push(state) ?? NullScope.instance;

  @override
  bool isEnabled(LogLevel logLevel) => logLevel != LogLevel.none;

  @override
  void log<TState>({
    required LogLevel logLevel,
    required EventId eventId,
    required TState state,
    Object? error,
    required LogFormatter<TState> formatter,
  }) {
    if (!isEnabled(logLevel)) {
      return;
    }

    final logEntry = LogEntry<TState>(
      logLevel: logLevel,
      category: name,
      eventId: eventId,
      state: state,
      exception: error,
      formatter: formatter,
    );

    final buffer = StringBuffer();
    _formatter.write(
      logEntry: logEntry,
      scopeProvider: _scopeProvider,
      textWriter: buffer,
    );

    if (buffer.isNotEmpty) {
      stdout.writeln(buffer.toString().trimRight());
    }
  }
}
