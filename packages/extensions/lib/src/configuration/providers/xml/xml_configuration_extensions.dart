import '../../configuration_builder.dart';
import 'xml_configuration_source.dart';
import 'xml_stream_configuration_source.dart';

/// Extension methods for adding XML configuration sources.
extension XmlConfigurationExtensions on ConfigurationBuilder {
  /// Adds an XML configuration source with the given input string.
  ///
  /// Example:
  /// ```dart
  /// final config = ConfigurationBuilder()
  ///   .addXml('''
  ///     <settings>
  ///       <key>value</key>
  ///     </settings>
  ///   ''')
  ///   .build();
  /// ```
  ConfigurationBuilder addXml(String input) {
    add(XmlConfigurationSource(input));
    return this;
  }

  /// Adds an XML configuration source from a stream.
  ///
  /// Example:
  /// ```dart
  /// final config = ConfigurationBuilder()
  ///   .addXmlStream(stream)
  ///   .build();
  /// ```
  ConfigurationBuilder addXmlStream(Stream<dynamic> stream) {
    add(XmlStreamConfigurationSource()..stream = stream);
    return this;
  }
}
