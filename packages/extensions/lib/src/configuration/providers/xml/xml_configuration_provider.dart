import '../../configuration_provider.dart';
import 'xml_configuration_parser.dart';

/// An XML based [ConfigurationProvider].
///
/// Parses XML-format configuration data and makes it available through the
/// configuration system. Supports standard XML syntax including:
/// - Element hierarchies
/// - Attributes
/// - Special 'Name' attribute for semantic sections
/// - Repeated elements with auto-indexing
/// - CDATA sections
class XmlConfigurationProvider extends ConfigurationProvider
    with ConfigurationProviderMixin {
  /// Creates a new [XmlConfigurationProvider] with the given input.
  XmlConfigurationProvider(this.input);

  /// The XML configuration input string.
  final String input;

  @override
  void load() {
    final parsed = XmlConfigurationParser.parse(input);
    data.addAll(parsed);
  }
}
