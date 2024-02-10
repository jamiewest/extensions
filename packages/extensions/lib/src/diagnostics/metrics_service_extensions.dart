import '../dependency_injection/service_collection_descriptor_extensions.dart';
import '../options/options_service_collection_extensions.dart';

import 'default_meter_factory.dart';
import 'meter_factory.dart';

import '../dependency_injection/service_collection.dart';
import 'metrics_builder.dart';

/// Extension methods for setting up metrics services in an [ServiceCollection].
extension MetricsServceExtensions on ServiceCollection {
  ServiceCollection addMetrics(
    void Function(MetricsBuilder builder) configure,
  ) {
    addOptions(() => null);
    tryAddSingleton<MeterFactory>((s) => DefaultMeterFactory());

    var builder = MetricsBuilder(this);
    configure(builder);

    return this;
  }
}

class _NoOpOptions {}
