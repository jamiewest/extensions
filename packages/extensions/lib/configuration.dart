/// Configuration
///
/// Configuration is performed using one or more configuration providers.
/// Configuration providers read configuration data from key-value pairs
/// using a variety of configuration sources:
///
/// ## Example
/// ```dart
/// import 'package:extensions/configuration.dart';
///
/// void main(List<String>? args) {
///   var builder = ConfigurationBuilder();
///   // Adds a memory collection to the configuration system.
///   configurationBuilder.addInMemoryCollection(
///   {
///       'Logging:LogLevel:Default', 'Warning',
///   });
///
///   var config = builder.build();
///   print(config['Logging:LogLevel:Default']);
/// }
/// ```
library configuration;

export 'src/configuration/chained_builder_extensions.dart';
export 'src/configuration/chained_configuration_provider.dart';
export 'src/configuration/chained_configuration_source.dart';
export 'src/configuration/configuration.dart';
export 'src/configuration/configuration_builder.dart';
export 'src/configuration/configuration_extensions.dart';
export 'src/configuration/configuration_key_comparator.dart';
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
export 'src/configuration/stream_configuration_provider.dart';
export 'src/configuration/stream_configuration_source.dart';

export 'src/shared/async_disposable.dart';
export 'src/shared/cancellation_token.dart';
export 'src/shared/disposable.dart';
