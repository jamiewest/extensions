import '../system/disposable.dart';
import 'event_id.dart';
import 'log_level.dart';
import 'logger.dart';
import 'logger_factory.dart';

/// A generic logger interface used to enable activation of a named logger from
/// dependency injection.
///
/// The type parameter [T] specifies the type whose name is used as the logger
/// category.
abstract class TypedLogger<T> implements Logger {}

/// Implementation of [TypedLogger] that wraps an underlying logger instance.
///
/// This class creates a logger using the full name of the type [T] as the
/// category name.
class TypedLoggerImpl<T> implements TypedLogger<T> {
  /// Creates a new [TypedLoggerImpl] using the provided [factory].
  ///
  /// The logger category will be the full name of type [T].
  TypedLoggerImpl(LoggerFactory factory)
      : _logger = factory.createLogger(_getCategoryName<T>());

  final Logger _logger;

  static String _getCategoryName<T>() {
    final type = T;
    // Get the type name, handling generic types
    var typeName = type.toString();

    // Remove any generic parameters from the display name
    final genericIndex = typeName.indexOf('<');
    if (genericIndex != -1) {
      typeName = typeName.substring(0, genericIndex);
    }

    return typeName;
  }

  @override
  Disposable? beginScope<TState>(TState state) => _logger.beginScope(state);

  @override
  bool isEnabled(LogLevel logLevel) => _logger.isEnabled(logLevel);

  @override
  void log<TState>({
    required LogLevel logLevel,
    required EventId eventId,
    required TState state,
    Object? error,
    required LogFormatter<TState> formatter,
  }) {
    _logger.log(
      logLevel: logLevel,
      eventId: eventId,
      state: state,
      error: error,
      formatter: formatter,
    );
  }
}

/// Extension methods for creating typed loggers.
extension TypedLoggerFactoryExtensions on LoggerFactory {
  /// Creates a new [TypedLogger] instance using the full name of the given
  /// type [T] as the category name.
  TypedLogger<T> createTypedLogger<T>() => TypedLoggerImpl<T>(this);
}
