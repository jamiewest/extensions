/*
  Omitted `ContentRootFileProvider` property.
*/

/// Provides information about the hosting environment
/// an application is running in.
abstract class HostEnvironment {
  /// The name of the environment. The host automatically
  /// sets this property to the value of the of the
  /// "environment" key as specified in configuration.
  String? environmentName;

  /// The name of the application. This property is
  /// automatically set by the host to the assembly
  /// containing the application entry point.
  String? applicationName;

  /// The absolute path to the directory that contains
  /// the application content files.
  String? contentRootPath;
}
