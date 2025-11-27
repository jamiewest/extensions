import '../system/disposable.dart';
import 'event_id.dart';
import 'log_level.dart';
import 'logger.dart';
import 'null_scope.dart';
import 'typed_logger.dart';

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

/// Generic null logger that does nothing.
class NullTypedLogger<T> implements TypedLogger<T> {
  NullTypedLogger();

  // Cache for singleton instances per type
  static final Map<Type, Object> _instances = {};

  /// Returns the shared instance of [NullTypedLogger] for type [T].
  static NullTypedLogger<T> instance<T>() =>
      _instances.putIfAbsent(T, NullTypedLogger<T>.new) as NullTypedLogger<T>;

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
