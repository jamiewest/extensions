import '../dependency_injection/service_collection.dart';

/// Represents a type used to configure the metrics system by registering
/// [MetricsListeners] and using rules to determine which metrics are enabled.
class MetricsBuilder {
  MetricsBuilder(this.services);

  /// The application [ServiceCollection].
  ///
  /// This is used by extension methods to register services.
  final ServiceCollection services;
}
