import '../../configuration/configuration.dart';

/// Factory for retrieving metric listener configuration.
///
/// Provides a mechanism to obtain configuration settings for a specific
/// metric listener by name.
abstract interface class IMetricListenerConfigurationFactory {
  /// Gets the configuration for the specified listener.
  ///
  /// [listenerName] - The name of the metric listener.
  /// Returns a [Configuration] object containing the listener's settings.
  Configuration getConfiguration(String listenerName);
}
