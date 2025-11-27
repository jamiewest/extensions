/// Utilities for working with logger provider aliases.
///
/// In .NET, logger providers can be decorated with ProviderAlias attribute
/// to provide a shorter configuration name. In Dart, we use a naming convention
/// where provider types follow the pattern: *LoggerProvider, and the alias
/// is the prefix before "LoggerProvider".
///
/// For example:
/// - ConsoleLoggerProvider -> alias: "Console"
/// - DebugLoggerProvider -> alias: "Debug"
/// - FileLoggerProvider -> alias: "File"
class ProviderAliasUtilities {
  /// Gets the alias for a logger provider type.
  ///
  /// Extracts the alias by removing the "LoggerProvider" suffix from the
  /// type name. If the type doesn't follow the naming convention, returns
  /// null.
  ///
  /// Examples:
  /// - ConsoleLoggerProvider returns "Console"
  /// - DebugLoggerProvider returns "Debug"
  /// - MyCustomProvider returns null
  static String? getAlias(Type providerType) {
    final typeName = providerType.toString();

    // Check if type follows the *LoggerProvider pattern
    if (typeName.endsWith('LoggerProvider')) {
      // Extract the prefix before "LoggerProvider"
      final alias = typeName.substring(
        0,
        typeName.length - 'LoggerProvider'.length,
      );

      // Return alias only if it's not empty
      return alias.isNotEmpty ? alias : null;
    }

    return null;
  }

  /// Gets the full type name for a logger provider type.
  ///
  /// Returns the string representation of the type.
  static String getFullName(Type providerType) => providerType.toString();
}
