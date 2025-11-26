import '../../external_scope_provider.dart';
import 'log_entry.dart';

/// Allows custom log message formatting for console output.
abstract class ConsoleFormatter {
  /// Creates a new instance of [ConsoleFormatter] with the given name.
  ConsoleFormatter(this.name);

  /// Gets the name associated with the console log formatter.
  final String name;

  /// Writes the log message to the specified [StringBuffer].
  ///
  /// Implementations can use ANSI color codes in the output for console
  /// coloring.
  void write<TState>({
    required LogEntry<TState> logEntry,
    ExternalScopeProvider? scopeProvider,
    required StringBuffer textWriter,
  });
}
