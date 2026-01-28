import 'package:extensions/src/dependency_injection/service_collection.dart';
import 'package:extensions/src/dependency_injection/service_collection_container_builder_extensions.dart';
import 'package:extensions/src/dependency_injection/service_provider_service_extensions.dart';
import 'package:extensions/src/diagnostics/console_metrics.dart';
import 'package:extensions/src/diagnostics/debug_console_metric_listener.dart';
import 'package:extensions/src/diagnostics/metrics_builder.dart';
import 'package:extensions/src/diagnostics/metrics_builder_console_extensions.dart';
import 'package:extensions/src/diagnostics/metrics_listener.dart';
import 'package:test/test.dart';

void main() {
  group('MetricsBuilderConsoleExtensions', () {
    test('addDebugConsole registers debug listener', () {
      final services = ServiceCollection();
      final builder = _FakeBuilder(services);

      builder.addDebugConsole();

      final container = services.buildServiceProvider();
      final listeners = container.getServices<MetricsListener>().toList();
      expect(listeners, hasLength(1));
      expect(listeners.first, isA<DebugConsoleMetricListener>());
      expect(listeners.first.name, ConsoleMetrics.debugListenerName);
    });
  });
}

class _FakeBuilder implements MetricsBuilder {
  _FakeBuilder(this._services);

  final ServiceCollection _services;

  @override
  ServiceCollection get services => _services;
}
