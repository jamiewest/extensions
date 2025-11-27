import '../configuration/configuration.dart';

/// Provides configuration for a specific logger provider type.
///
/// This interface is used by logger providers to access their specific
/// configuration settings. It wraps the configuration retrieval process
/// in a type-safe manner.
///
/// Type parameter [T] represents the logger provider type (e.g.,
/// ConsoleLoggerProvider, DebugLoggerProvider).
abstract class ILoggerProviderConfiguration<T> {
  /// Gets the configuration for the logger provider.
  ///
  /// Returns an [IConfiguration] containing the provider-specific
  /// configuration settings extracted from the application configuration.
  IConfiguration get configuration;
}

typedef LoggerProviderConfiguration<T> = ILoggerProviderConfiguration<T>;
