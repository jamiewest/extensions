import 'dart:collection';

import 'instrument_rule.dart';
import 'meter_scope.dart';
import '../options/options_service_collection_extensions.dart';

import '../dependency_injection/service_collection_descriptor_extensions.dart';
import '../dependency_injection/service_descriptor.dart';
import 'metrics_listener.dart';
import 'metrics_builder.dart';
import 'metrics_options.dart';

/// Extension methods for [MetricsBuilder] to add or clear [MetricsListener]
/// registrations, and to enable or disable metrics.
extension MetricsBuilderExtensions on MetricsBuilder {
  MetricsBuilder addListener(MetricsListener listener) {
    services.tryAddIterable(
      ServiceDescriptor.singletonInstance<MetricsListener>(listener),
    );
    return this;
  }

  /// Removes all [MetricsListener] registrations from the dependency
  /// injection container.
  MetricsBuilder clearListeners() {
    services.removeAll(MetricsListener);
    return this;
  }

  /// Enables a specified [Instrument] for the given [Meter] and
  /// [MetricsListener].
  MetricsBuilder enableMetrics({
    String? meterName,
    String? instrumentName,
    String? listenerName,
    int? scopes,
  }) =>
      _configureRule(
        (options) => options.enableMetrics(
          meterName: meterName,
          instrumentName: instrumentName,
          listenerName: listenerName,
          scopes: scopes ??= scopes ??= MeterScope.global | MeterScope.local,
        ),
      );

  /// Disables a specified [Instrument] for the given [Meter] and
  /// [MetricsListener].
  MetricsBuilder disableMetrics({
    String? meterName,
    String? instrumentName,
    String? listenerName,
    int? scopes,
  }) =>
      _configureRule(
        (options) => options.disableMetrics(
          meterName: meterName,
          instrumentName: instrumentName,
          listenerName: listenerName,
          scopes: scopes ??= scopes ??= MeterScope.global | MeterScope.local,
        ),
      );

  MetricsBuilder _configureRule(
    void Function(MetricsOptions options) configureOptions,
  ) {
    services.configure<MetricsOptions>(
      () => MetricsOptions(),
      configureOptions,
    );
    return this;
  }
}

extension MetricsOptionsExtensions on MetricsOptions {
  MetricsOptions enableMetrics({
    String? meterName,
    String? instrumentName,
    String? listenerName,
    int? scopes,
  }) {
    _addRule(
      meterName,
      instrumentName,
      listenerName,
      scopes ??= MeterScope.global | MeterScope.local,
      true,
    );
    return this;
  }

  MetricsOptions disableMetrics({
    String? meterName,
    String? instrumentName,
    String? listenerName,
    int? scopes,
  }) {
    _addRule(
      meterName,
      instrumentName,
      listenerName,
      scopes ??= MeterScope.global | MeterScope.local,
      false,
    );
    return this;
  }

  MetricsOptions _addRule(
    String? meterName,
    String? instrumentName,
    String? listenerName,
    int scopes,
    bool enable,
  ) {
    rules.add(
      InstrumentRule(
        meterName: meterName,
        instrumentName: instrumentName,
        ListenerName: listenerName,
        scopes: scopes,
        enable: enable,
      ),
    );
    return this;
  }
}
