import '../../configuration/chained_builder_extensions.dart';
import '../../configuration/configuration.dart';
import '../../configuration/configuration_builder.dart';
import 'i_metric_listener_configuration_factory.dart';
import 'metrics_configuration.dart';

/// Used to retrieve the metrics configuration for any listener name.
class MetricListenerConfigurationFactory
    implements IMetricListenerConfigurationFactory {
  final Iterable<MetricsConfiguration> _configurations;

  MetricListenerConfigurationFactory(
      Iterable<MetricsConfiguration> configurations)
      : _configurations = configurations;

  /// Gets the configuration for the given listener.
  @override
  Configuration getConfiguration(String listenerName) {
    var configurationBuilder = ConfigurationBuilder();
    for (var configuration in _configurations) {
      var section = configuration.configuration.getSection(listenerName);
      configurationBuilder.addConfiguration(section);
    }
    return configurationBuilder.build();
  }
}
