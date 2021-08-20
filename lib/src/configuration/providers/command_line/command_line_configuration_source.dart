import 'dart:collection';

import '../../configuration_builder.dart';
import '../../configuration_provider.dart';
import '../../configuration_source.dart';
import 'command_line_configuration_provider.dart';

/// Represents command line arguments as an [ConfigurationSource].
class CommandLineConfigurationSource implements ConfigurationSource {
  /// Initializes the [CommandLineConfigurationSource].
  CommandLineConfigurationSource({
    this.args,
    this.switchMappings,
  });

  /// Gets or sets the switch mappings.
  LinkedHashMap<String, String>? switchMappings;

  /// Gets or sets the command line args.
  Iterable<String>? args;

  @override
  ConfigurationProvider build(ConfigurationBuilder builder) =>
      CommandLineConfigurationProvider(args!, switchMappings);
}
