import '../../configuration/chained_builder_extensions.dart';
import '../../configuration/configuration.dart';
import '../../configuration/configuration_builder.dart';
import 'metrics_configuration.dart';

/// Retrieves the merged metrics configuration for a listener name.
///
/// The C# `IMetricListenerConfigurationFactory` interface collapses into
/// this single concrete class per the porting rules (one implementation,
/// no seam).
class MetricListenerConfigurationFactory {
  final Iterable<MetricsConfiguration> _configurations;

  /// Creates a factory over the given [configurations].
  MetricListenerConfigurationFactory(
    Iterable<MetricsConfiguration> configurations,
  ) : _configurations = configurations;

  /// Gets the configuration for the specified [listenerName], merging the
  /// matching section from every registered [MetricsConfiguration].
  Configuration getConfiguration(String listenerName) {
    var configurationBuilder = ConfigurationBuilder();
    for (var configuration in _configurations) {
      var section = configuration.configuration.getSection(listenerName);
      configurationBuilder.addConfiguration(section);
    }
    return configurationBuilder.build();
  }
}
