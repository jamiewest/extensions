import 'dart:collection';

import '../../configuration_builder.dart';
import 'command_line_configuration_source.dart';

extension CommandLineConfigurationExtensions on ConfigurationBuilder {
  ConfigurationBuilder addCommandLine(Iterable<String> args,
      [LinkedHashMap<String, String>? switchMappings]) {
    add(CommandLineConfigurationSource(
      args: args,
      switchMappings: switchMappings,
    ));
    return this;
  }
}
