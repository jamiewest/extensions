import '../configuration/configuration.dart';
import 'host_environment.dart';

/// Context containing the common services on the `Host`. Some
/// properties may be null until set by the `Host`.
class HostBuilderContext {
  final Map<dynamic, dynamic> _properties;

  HostBuilderContext(Map<dynamic, dynamic> properties)
      : _properties = properties;

  /// The [HostEnvironment] initialized by the `Host`.
  HostEnvironment? hostingEnvironment;

  /// The [Configuration] containing the merged configuration
  /// of the application and the `Host`.
  Configuration? configuration;

  /// A central location for sharing state between components
  /// during the host building process.
  Map<dynamic, dynamic> get properties => _properties;
}
