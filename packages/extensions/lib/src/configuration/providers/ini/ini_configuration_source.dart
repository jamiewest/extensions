import '../../configuration_builder.dart';
import '../../configuration_provider.dart';
import '../../configuration_source.dart';
import 'ini_configuration_provider.dart';

/// Represents an INI configuration string as a [ConfigurationSource].
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
class IniConfigurationSource implements ConfigurationSource {
  /// Creates a new [IniConfigurationSource] with the given input.
  IniConfigurationSource(this.input);

  /// The INI configuration input string.
  final String input;

  @override
  ConfigurationProvider build(ConfigurationBuilder builder) =>
      IniConfigurationProvider(input);
}
