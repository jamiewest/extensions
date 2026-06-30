/// Extends the configuration library with IO-specific providers that read
/// configuration from environment variables and JSON files.
///
/// This library adds platform-specific configuration sources that depend on
/// `dart:io` and are therefore not web-safe: environment variables and JSON
/// file support (`addJson`). Import this barrel (or `io.dart`) on the Dart VM
/// when these sources are needed.
///
/// ## JSON Files
///
/// ```dart
/// final config = ConfigurationBuilder()
///   ..addJson('appsettings.json', optional: true)
///   .build();
/// ```
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
export 'src/configuration/providers/json/json_configuration_extensions.dart';
