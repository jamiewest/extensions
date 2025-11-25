import 'package:extensions/src/dependency_injection/service_collection.dart';
import 'package:extensions/src/dependency_injection/service_collection_container_builder_extensions.dart';
import 'package:extensions/src/dependency_injection/service_provider_service_extensions.dart';

import 'package:extensions/src/diagnostics/measurement_handlers.dart';
import 'package:extensions/src/diagnostics/metrics_builder.dart';
import 'package:extensions/src/diagnostics/metrics_builder_extensions.dart';
import 'package:extensions/src/diagnostics/metrics_listener.dart';
import 'package:extensions/src/diagnostics/observable_instruments_source.dart';
import 'package:extensions/src/diagnostics/system/diagnostics.dart';
import 'package:test/test.dart';

void main() {
  group('MetricsBuilderExtensionsListenersTests', () {
    test('CanAddListenersByInstance', () {
      var services = ServiceCollection();
      var builder = _FakeBuilder(services);

      var instanceA = _FakeListenerA();
      builder.addListener(instanceA);
      var container = services.buildServiceProvider();
      expect(container.getServices<MetricsListener>().first, equals(instanceA));

      var instanceB = _FakeListenerB();
      builder.addListener(instanceB);
      container = services.buildServiceProvider();
      var listeners = container.getServices<MetricsListener>().toList();
      expect(listeners.length, equals(2));
      expect(instanceA, equals(listeners[0]));
      expect(instanceB, equals(listeners[1]));
    });

    test('CanClearListeners', () {
      var services = ServiceCollection();
      var builder = _FakeBuilder(services)
        ..addListener(_FakeListenerA())
        ..addListener(_FakeListenerB());
      var container = services.buildServiceProvider();
      expect(container.getServices<MetricsListener>().length, equals(2));

      builder.clearListeners();
      container = services.buildServiceProvider();
      expect(container.getServices<MetricsListener>().length, equals(0));
    });
  });
}

class _FakeBuilder implements MetricsBuilder {
  final ServiceCollection _services;

  _FakeBuilder(ServiceCollection services) : _services = services;

  @override
  ServiceCollection get services => _services;
}

class _FakeListenerA implements MetricsListener {
  @override
  String get name => 'Fake';

  @override
  MeasurementHandlers getMeasurementHandlers() {
    throw UnimplementedError();
  }

  @override
  void initialize(ObservableInstrumentsSource source) {}

  @override
  (bool, Object?) instrumentPublished(Instrument instrument) {
    throw UnimplementedError();
  }

  @override
  bool measurementsCompleted(Instrument instrument, Object? userState) {
    throw UnimplementedError();
  }
}

class _FakeListenerB implements MetricsListener {
  @override
  String get name => 'Fake';

  @override
  MeasurementHandlers getMeasurementHandlers() {
    throw UnimplementedError();
  }

  @override
  void initialize(ObservableInstrumentsSource source) {}

  @override
  (bool, Object?) instrumentPublished(Instrument instrument) {
    throw UnimplementedError();
  }

  @override
  bool measurementsCompleted(Instrument instrument, Object? userState) {
    throw UnimplementedError();
  }
}
