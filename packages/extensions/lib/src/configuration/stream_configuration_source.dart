/*
  Original definition explicitly states `build` as abstract, I am not sure
  why this was included when derived implementations will have to override.
*/
import 'configuration_source.dart';

/// Stream based [ConfigurationSource].
abstract class StreamConfigurationSource implements ConfigurationSource {
  /// The stream containing the configuration data.
  Stream<dynamic>? stream;
}
