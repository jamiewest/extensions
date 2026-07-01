/// Extends the configuration library with IO-specific providers that read
/// configuration from environment variables.
///
/// This library adds platform-specific configuration sources that depend on
/// `dart:io` and are therefore not web-safe. Environment variables live here;
/// JSON file support is web-safe and available from `configuration.dart`.
/// Import this barrel (or `io.dart`) on the Dart VM when environment variables
/// are needed.
///
/// ## Environment Variables
///
/// Read configuration from environment variables:
///
/// ```dart
/// final config = ConfigurationBuilder()
///   ..addEnvironmentVariables()
///   .build();
///
/// final path = config['PATH'];
/// ```
///
/// Use prefixes to filter environment variables:
///
/// ```dart
/// final config = ConfigurationBuilder()
///   ..addEnvironmentVariables(prefix: 'MYAPP_')
///   .build();
///
/// // MYAPP_ConnectionString becomes ConnectionString
/// final connStr = config['ConnectionString'];
/// ```
library;

export 'configuration.dart';
export 'src/configuration/providers/environment_variables/environment_variables_configuration_provider.dart';
export 'src/configuration/providers/environment_variables/environment_variables_configuration_source.dart';
export 'src/configuration/providers/environment_variables/environment_variables_extensions.dart';
