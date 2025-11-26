/// Base options class for console log formatters.
class ConsoleFormatterOptions {
  /// Creates a new instance of [ConsoleFormatterOptions].
  ConsoleFormatterOptions();

  /// Gets or sets a value that indicates whether scopes are included.
  ///
  /// Defaults to `false`.
  bool includeScopes = false;

  /// Gets or sets the format string used to format timestamp in logging
  /// messages.
  ///
  /// Defaults to `null`.
  String? timestampFormat;

  /// Gets or sets a value that indicates whether or not UTC timezone should be
  /// used to format timestamps.
  ///
  /// Defaults to `false`.
  bool useUtcTimestamp = false;
}
