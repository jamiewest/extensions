import '../../configuration_builder.dart';
import '../../configuration_provider.dart';
import '../../stream_configuration_source.dart';
import 'ini_stream_configuration_provider.dart';

/// Represents an INI stream as a [ConfigurationSource].
///
/// Supports simple line-based configuration files with sections, key-value
/// pairs, and comments.
///
/// Example INI format:
/// ```ini
/// ; This is a comment
/// [Section:Header]
/// key1=value1
/// key2 = " value2 "
/// ```
class IniStreamConfigurationSource extends StreamConfigurationSource {
  @override
  ConfigurationProvider build(ConfigurationBuilder builder) =>
      IniStreamConfigurationProvider(this);
}
