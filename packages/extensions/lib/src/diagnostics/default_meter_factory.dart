import 'system/diagnostics.dart';
import 'meter_factory.dart';
import 'system/meter_options.dart';

class DefaultMeterFactory implements MeterFactory {
  final _cachedMeters = <String, List<FactoryMeter>>{};
  bool _disposed = false;
  @override
  Meter create(MeterOptions options) {
    if (_disposed) {
      // throw ObjectDisposedException
    }

    List<FactoryMeter>? meterList;
    if (_cachedMeters.containsKey(options.name)) {
      meterList = _cachedMeters[options.name];
      for (var meter in meterList!) {
        if (meter.version == options.version) {
          return meter;
        }
      }
    } else {
      meterList = <FactoryMeter>[];
      _cachedMeters[options.name] = meterList;
    }

    Object? scope = options.scope;
    options.scope = this;
    FactoryMeter m = FactoryMeter(
      name: options.name,
      version: options.version,
      tags: options.tags,
      scope: this,
    );
    options.scope = scope;
    meterList.add(m);
    return m;
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }

    _disposed = true;

    for (var meterList in _cachedMeters.values) {
      for (var meter in meterList) {
        meter.release();
      }
    }

    _cachedMeters.clear;
  }
}

class FactoryMeter extends Meter {
  FactoryMeter({
    required super.name,
    super.version,
    super.tags,
    super.scope,
  });

  void release() => super.dispose();

  @override
  void dispose() {}
}
