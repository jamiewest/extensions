/// Describes when to use color when logging messages.
enum LoggerColorBehavior {
  /// Use the default color behavior, which is platform-specific.
  /// On platforms that support color, this will enable colors.
  /// On platforms that don't support color, this will disable colors.
  defaultBehavior,

  /// Enable color output regardless of platform capabilities.
  enabled,

  /// Disable color output regardless of platform capabilities.
  disabled,
}
