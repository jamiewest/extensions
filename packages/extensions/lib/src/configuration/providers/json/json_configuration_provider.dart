import 'dart:collection';

import '../../configuration_provider.dart';
import 'json_configuration_parser.dart';

/// A JSON based [ConfigurationProvider].
class JsonConfigurationProvider extends ConfigurationProvider
    with ConfigurationProviderMixin {
  JsonConfigurationProvider(this.input);

  final String input;

  /// Loads the JSON data from a stream.
  @override
  void load() {
    data = LinkedHashMap.from(
      JsonConfigurationParser.parse(input),
    );
  }
}
