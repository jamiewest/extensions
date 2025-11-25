import 'log_level.dart';
import 'logger_information.dart';

typedef ConfigureFilter = bool Function(
  String name,
  String category,
  LogLevel level,
);

/// Defines a rule used to filter log messages.
class LoggerFilterRule {
  final String? _providerName;
  final String? _categoryName;
  final LogLevel? _logLevel;
  final MessageLoggerFilter? _filter;

  /// Creates a new [LoggerFilterRule] instance
  LoggerFilterRule(
    String? providerName,
    String? categoryName,
    LogLevel? logLevel,
    MessageLoggerFilter? filter,
  )   : _providerName = providerName,
        _categoryName = categoryName,
        _logLevel = logLevel,
        _filter = filter;

  /// Gets the logger provider type or alias this rule applies to.
  String? get providerName => _providerName;

  /// Gets the logger category this rule applies to.
  String? get categoryName => _categoryName;

  /// Gets the minimum [LogLevel] of messages.
  LogLevel? get logLevel => _logLevel;

  /// Gets the filter delegate that would be applied to messages
  /// that passed the [LogLevel].
  MessageLoggerFilter? get filter => _filter;

  @override
  String toString() => '''ProviderName: $providerName, 
      CategoryName: $categoryName,
      LogLevel: ${logLevel.toString()},
      ''';
}
