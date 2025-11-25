import 'debug_console_metric_listener.dart';
import 'metrics_builder.dart';
import 'metrics_builder_extensions.dart';

/// MetricsBuilder extension methods for console output.
extension MetricsBuilderConsoleExtensions on MetricsBuilder {
  /// Enables console output for metrics for debugging purposes.
  ///
  /// This is not recommended for production use.
  MetricsBuilder addDebugConsole() => addListener(DebugConsoleMetricListener());
}
