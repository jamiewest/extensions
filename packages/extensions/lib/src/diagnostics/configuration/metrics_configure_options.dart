import '../../configuration/configuration.dart';
import '../../options/configure_options.dart';
import '../metrics_options.dart';

class MetricsConfigureOptions implements ConfigureOptions<MetricsOptions> {
  final String enabledMetricsKey = 'EnabledMetrics';
  final String enabledGlobalMetricsKey = 'EnabledGlobalMetrics';
  final String enabledLocalMetricsKey = 'EnabledLocalMetrics';
  final String defaultKey = 'Defaut';
  final Configuration _configuration;

  MetricsConfigureOptions(Configuration configuration)
      : _configuration = configuration;

  @override
  void configure(MetricsOptions options) => _loadConfig(options);

  void _loadConfig(MetricsOptions options) {}
}
