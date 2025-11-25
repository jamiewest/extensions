import '../dependency_injection/service_collection.dart';
import 'metrics_listener.dart';

/// Represents a type used to configure the metrics system by registering
/// [MetricsListener]s and using rules to determine which metrics are enabled.
abstract interface class MetricsBuilder {
  /// The application [ServiceCollection].
  ///
  /// This is used by extension methods to register services.
  abstract final ServiceCollection services;
}
