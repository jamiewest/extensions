import '../../configuration/configuration.dart';
import '../../dependency_injection/service_collection_service_extensions.dart';
import '../../options/configuration_change_token_source.dart';
import '../../options/configure_options.dart';
import '../../options/options_change_token_source.dart';
import '../metrics_builder.dart';
import '../metrics_options.dart';
import 'metrics_configuration.dart';
import 'metrics_configure_options.dart';

/// Extensions for [MetricsBuilder] for enabling metrics based
  /// on [Configuration].
  extension MetricsBuilderConfigurationExtensions on MetricsBuilder {
    MetricsBuilder addConfiguration(Configuration configuration) {
      services
        ..addSingletonInstance<ConfigureOptions<MetricsOptions>>(
          (services) => MetricsConfigureOptions(configuration),
        )
        ..addSingletonInstance<OptionsChangeTokenSource<MetricsOptions>>(
          (services) => ConfigurationChangeTokenSource<MetricsOptions>(
            config: configuration,
          ),
        )
        ..addSingletonInstance<MetricsConfiguration>(
          (services) => MetricsConfiguration(configuration),
        );
      return this;
    }
  }
