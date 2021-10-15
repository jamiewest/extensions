import 'log_level.dart';
import 'logger_filter_rule.dart';

/// The options for a LoggerFilter.
class LoggerFilterOptions {
  /// Creates a new [LoggerFilterOptions] instance.
  LoggerFilterOptions();

  /// Gets or sets value indicating whether logging
  /// scopes are being captured. Defaults to `true`
  bool captureScopes = true;

  /// Gets or sets the minimum level of log messages
  /// if none of the rules match.
  LogLevel? minLevel;

  /// Gets the collection of [LoggerFilterRule] used
  /// for filtering log messages.
  final List<LoggerFilterRule> rules = <LoggerFilterRule>[];
}
