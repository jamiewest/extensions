import 'dart:convert';

import '../../configuration_provider.dart';
import '../../stream_configuration_provider.dart';
import 'xml_configuration_parser.dart';

/// XML configuration provider that reads from a stream.
///
/// Parses XML-format configuration data from a stream and makes it available
/// through the configuration system. Supports standard XML syntax including:
/// - Element hierarchies
/// - Attributes
/// - Special 'Name' attribute for semantic sections
/// - Repeated elements with auto-indexing
/// - CDATA sections
class XmlStreamConfigurationProvider extends StreamConfigurationProvider
    with ConfigurationProviderMixin {
  /// Creates a new [XmlStreamConfigurationProvider] with the given source.
  XmlStreamConfigurationProvider(super.source);

  @override
  void loadStream(Stream<dynamic> stream) {
    // Convert stream to string and parse
    stream.transform(utf8.decoder).join().then((input) {
      final parsed = XmlConfigurationParser.parse(input);
      data.addAll(parsed);
    });
  }
}
