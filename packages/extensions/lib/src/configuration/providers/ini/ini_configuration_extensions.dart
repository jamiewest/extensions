import '../../configuration_builder.dart';
import 'ini_configuration_source.dart';
import 'ini_stream_configuration_source.dart';

/// Extension methods for adding INI configuration sources.
extension IniConfigurationExtensions on ConfigurationBuilder {
  /// Adds an INI configuration source with the given input string.
  ///
  /// Example:
  /// ```dart
  /// final config = ConfigurationBuilder()
  ///   .addIni('''
  ///     [Section]
  ///     key=value
  ///   ''')
  ///   .build();
  /// ```
  ConfigurationBuilder addIni(String input) {
    add(IniConfigurationSource(input));
    return this;
  }

  /// Adds an INI configuration source from a stream.
  ///
  /// Example:
  /// ```dart
  /// final config = ConfigurationBuilder()
  ///   .addIniStream(stream)
  ///   .build();
  /// ```
  ConfigurationBuilder addIniStream(Stream<dynamic> stream) {
    add(IniStreamConfigurationSource()..stream = stream);
    return this;
  }
}
