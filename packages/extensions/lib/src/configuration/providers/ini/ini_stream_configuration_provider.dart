import 'dart:convert';

import '../../configuration_provider.dart';
import '../../stream_configuration_provider.dart';
import 'ini_configuration_parser.dart';
import 'ini_stream_configuration_source.dart';

/// INI configuration provider that reads from a stream.
///
/// Parses INI-format configuration data from a stream and makes it available
/// through the configuration system. Supports standard INI syntax including:
/// - Section headers: [Section:Header]
/// - Key-value pairs: key=value
/// - Quoted values: key = " value "
/// - Comments: ; # /
class IniStreamConfigurationProvider extends StreamConfigurationProvider
    with ConfigurationProviderMixin {
  /// Creates a new [IniStreamConfigurationProvider] with the given source.
  IniStreamConfigurationProvider(super.source);

  @override
  void loadStream(Stream<dynamic> stream) {
    // Convert stream to string and parse
    stream.transform(utf8.decoder).join().then((input) {
      final parsed = IniConfigurationParser.parse(input);
      data.addAll(parsed);
    });
  }
}
