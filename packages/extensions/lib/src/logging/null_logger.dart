import '../system/disposable.dart';
import 'event_id.dart';
import 'log_level.dart';
import 'logger.dart';
import 'null_scope.dart';

/// Minimalistic logger that does nothing.
class NullLogger implements Logger {
  const NullLogger();

  /// Returns the shared instance of [NullLogger].
  static const NullLogger instance = NullLogger();

  @override
  Disposable beginScope<TState>(TState state) => NullScope.instance;

  @override
  bool isEnabled(LogLevel logLevel) => false;

  @override
  void log<TState>({
    required LogLevel logLevel,
    EventId? eventId,
    TState? state,
    Object? error,
    LogFormatter<TState>? formatter,
  }) {}
}
