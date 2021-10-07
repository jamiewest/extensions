class ConsoleLifetimeOptions {
  ConsoleLifetimeOptions([this.suppressStatusMessages = false]);

  /// Indicates if host lifetime status messages should be
  /// supressed such as on startup.
  ///
  /// The default is false.
  bool suppressStatusMessages;
}
