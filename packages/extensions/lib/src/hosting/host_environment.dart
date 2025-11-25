import '../file_providers/file_provider.dart';

/// Provides information about the hosting environment an application is
/// running in.
abstract interface class HostEnvironment {
  /// Gets or sets the name of the environment. The host automatically
  /// sets this property to the value of the of the
  /// `environment` key as specified in configuration.
  abstract String environmentName;

  /// Gets or sets the name of the application.
  abstract String applicationName;

  /// Gets or sets the absolute path to the directory that contains
  /// the application content files.
  abstract String contentRootPath;

  /// Gets or sets an [FileProvider] pointing at [contentRootPath].
  abstract FileProvider? contentRootFileProvider;
}
