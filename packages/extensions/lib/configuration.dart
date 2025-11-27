/// Contains classes for reading application configuration from various sources.
///
/// This library provides a flexible configuration system inspired by
/// Microsoft.Extensions.Configuration, allowing applications to read settings
/// from multiple sources with a unified API.
///
/// Configuration is performed using one or more configuration providers that
/// read configuration data from key-value pairs using various sources including:
///
/// - JSON files
/// - XML files
/// - INI files
/// - Command-line arguments
/// - In-memory collections
/// - Environment variables (via configuration_io.dart)
///
/// ## Basic Usage
///
/// Build a configuration from multiple sources:
///
/// ```dart
/// final config = ConfigurationBuilder()
///   ..addInMemoryCollection({
///     'Logging:LogLevel:Default': 'Information',
///     'AllowedHosts': '*',
///   })
///   ..addJsonFile('appsettings.json', optional: true)
///   ..addCommandLine(args)
///   .build();
///
/// // Read values
/// final logLevel = config['Logging:LogLevel:Default'];
/// final hosts = config['AllowedHosts'];
/// ```
///
/// ## Configuration Sections
///
/// Access nested configuration as typed sections:
///
/// ```dart
/// final loggingSection = config.getSection('Logging');
/// final logLevel = loggingSection['LogLevel:Default'];
///
/// // Bind to objects
/// final myOptions = loggingSection.get<LoggingOptions>();
/// ```
///
/// ## Configuration Reloading
///
/// Monitor configuration changes with change tokens:
///
/// ```dart
/// ChangeToken.onChangeTyped<IConfiguration>(
///   () => config.getReloadToken(),
///   (config) {
///     print('Configuration reloaded!');
///     // React to configuration changes
///   },
/// );
/// ```
library;

export 'src/configuration/chained_builder_extensions.dart';
export 'src/configuration/chained_configuration_provider.dart';
export 'src/configuration/chained_configuration_source.dart';
export 'src/configuration/configuration.dart';
export 'src/configuration/configuration_builder.dart';
export 'src/configuration/configuration_extensions.dart';
export 'src/configuration/configuration_key_comparator.dart';
export 'src/configuration/configuration_manager.dart';
export 'src/configuration/configuration_path.dart';
export 'src/configuration/configuration_provider.dart';
export 'src/configuration/configuration_reload_token.dart';
export 'src/configuration/configuration_root.dart';
export 'src/configuration/configuration_root_extensions.dart';
export 'src/configuration/configuration_section.dart';
export 'src/configuration/configuration_source.dart';
export 'src/configuration/internal_configuration_root_extensions.dart';
export 'src/configuration/memory_configuration_builder_extensions.dart';
export 'src/configuration/memory_configuration_provider.dart';
export 'src/configuration/memory_configuration_source.dart';
export 'src/configuration/providers/command_line/command_line_configuration_extensions.dart';
export 'src/configuration/providers/command_line/command_line_configuration_provider.dart';
export 'src/configuration/providers/command_line/command_line_configuration_source.dart';
export 'src/configuration/providers/ini/ini_configuration_extensions.dart';
export 'src/configuration/providers/ini/ini_configuration_parser.dart';
export 'src/configuration/providers/ini/ini_configuration_provider.dart';
export 'src/configuration/providers/ini/ini_configuration_source.dart';
export 'src/configuration/providers/ini/ini_stream_configuration_provider.dart';
export 'src/configuration/providers/ini/ini_stream_configuration_source.dart';
export 'src/configuration/providers/json/json_configuration_extensions.dart';
export 'src/configuration/providers/json/json_configuration_parser.dart';
export 'src/configuration/providers/json/json_configuration_provider.dart';
export 'src/configuration/providers/json/json_configuration_source.dart';
export 'src/configuration/providers/xml/xml_configuration_extensions.dart';
export 'src/configuration/providers/xml/xml_configuration_parser.dart';
export 'src/configuration/providers/xml/xml_configuration_provider.dart';
export 'src/configuration/providers/xml/xml_configuration_source.dart';
export 'src/configuration/providers/xml/xml_stream_configuration_provider.dart';
export 'src/configuration/providers/xml/xml_stream_configuration_source.dart';
export 'src/configuration/stream_configuration_provider.dart';
export 'src/configuration/stream_configuration_source.dart';
