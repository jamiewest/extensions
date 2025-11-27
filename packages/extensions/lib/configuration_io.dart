/// Extends the configuration library with IO-specific providers for
/// reading configuration from environment variables.
///
/// This library adds platform-specific configuration sources that depend
/// on dart:io, specifically environment variable support.
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
