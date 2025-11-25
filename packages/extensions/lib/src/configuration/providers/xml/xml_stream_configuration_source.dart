import '../../../../configuration.dart' show ConfigurationSource;
import '../../../../configuration_io.dart' show ConfigurationSource;
import '../../../../io.dart' show ConfigurationSource;
import '../../configuration_builder.dart';
import '../../configuration_provider.dart';
import '../../configuration_source.dart' show ConfigurationSource;
import '../../stream_configuration_source.dart';
import 'xml_stream_configuration_provider.dart';

/// Represents an XML stream as a [ConfigurationSource].
///
/// Supports XML configuration with hierarchical structure, attributes,
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
class XmlStreamConfigurationSource extends StreamConfigurationSource {
  @override
  ConfigurationProvider build(ConfigurationBuilder builder) =>
      XmlStreamConfigurationProvider(this);
}
