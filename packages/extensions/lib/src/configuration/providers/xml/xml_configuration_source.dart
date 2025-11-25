import '../../configuration_builder.dart';
import '../../configuration_provider.dart';
import '../../configuration_source.dart';
import 'xml_configuration_provider.dart';

/// Represents an XML configuration string as a [ConfigurationSource].
///
/// Supports XML configuration files with hierarchical structure, attributes,
/// and special handling for the 'Name' attribute.
///
/// Example XML format:
/// ```xml
/// <settings>
///   <Data Name="DefaultConnection">
///     <ConnectionString>Server=...</ConnectionString>
///     <Provider>SqlClient</Provider>
///   </Data>
/// </settings>
/// ```
class XmlConfigurationSource implements ConfigurationSource {
  /// Creates a new [XmlConfigurationSource] with the given input.
  XmlConfigurationSource(this.input);

  /// The XML configuration input string.
  final String input;

  @override
  ConfigurationProvider build(ConfigurationBuilder builder) =>
      XmlConfigurationProvider(input);
}
