import '../../diagnostics.dart';
import '../dependency_injection/service_collection.dart';
import '../dependency_injection/service_collection_descriptor_extensions.dart';
import '../dependency_injection/service_provider_service_extensions.dart';
import '../options/configure_options.dart';
import '../options/options_builder_extensions.dart';
import '../options/options_monitor.dart';
import '../options/options_service_collection_extensions.dart';
import 'default_meter_factory.dart';
import 'meter_factory.dart';
import 'metrics_options.dart';

/// Extension methods for setting up metrics services in an [ServiceCollection].
extension MetricsServceExtensions on ServiceCollection {
  ServiceCollection addMetrics(
    void Function(MetricsBuilder builder) configure,
  ) {
    addOptions(() => null);
    tryAddSingleton<MeterFactory>((s) => DefaultMeterFactory());
    tryAddSingleton<MetricsSubscriptionManager>(
      (s) => MetricsSubscriptionManager(
        s.getServices<MetricsListener>(),
        s.getRequiredService<OptionsMonitor<MetricsOptions>>(),
        s.getRequiredService<MeterFactory>(),
      ),
    );

    addOptions<_NoOpOptions>(_NoOpOptions.new).validateOnStart();

    tryAddSingleton<ConfigureOptions<_NoOpOptions>>(
      (s) => _SubscriptionActivator(
        s.getRequiredService<MetricsSubscriptionManager>(),
      ),
    );

    var builder = _MetricsBuilder(this);
    configure(builder);

    return this;
  }
}

final class _MetricsBuilder implements MetricsBuilder {
  _MetricsBuilder(this.services);

  @override
  final ServiceCollection services;
}

class _NoOpOptions {}

class _SubscriptionActivator implements ConfigureOptions<_NoOpOptions> {
  _SubscriptionActivator(this.manager);

  final MetricsSubscriptionManager manager;

  @override
  void configure(_NoOpOptions options) => manager.initialize();
}
