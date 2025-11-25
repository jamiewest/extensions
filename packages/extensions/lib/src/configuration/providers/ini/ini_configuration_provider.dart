import '../../configuration_provider.dart';
import 'ini_configuration_parser.dart';

/// An INI based [ConfigurationProvider].
///
/// Parses INI-format configuration data and makes it available through the
/// configuration system. Supports standard INI syntax including:
/// - Section headers: [Section:Header]
/// - Key-value pairs: key=value
/// - Quoted values: key = " value "
/// - Comments: ; # /
class IniConfigurationProvider extends ConfigurationProvider
    with ConfigurationProviderMixin {
  /// Creates a new [IniConfigurationProvider] with the given input.
  IniConfigurationProvider(this.input);

  /// The INI configuration input string.
  final String input;

  @override
  void load() {
    final parsed = IniConfigurationParser.parse(input);
    data.addAll(parsed);
  }
}
