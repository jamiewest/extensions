import '../system/exceptions/object_disposed_exception.dart';
import 'meter_factory.dart';
import 'system/diagnostics.dart';
import 'system/meter_options.dart';

class DefaultMeterFactory implements MeterFactory {
  final _cachedMeters = <String, List<FactoryMeter>>{};
  bool _disposed = false;

  @override
  Meter create(MeterOptions options) {
    if (_disposed) {
      throw ObjectDisposedException(
        objectName: 'DefaultMeterFactory',
      );
    }

    // Validate scope - if options.scope is set and not this factory, throw
    if (options.scope != null && !identical(options.scope, this)) {
      throw ArgumentError(
        'MeterOptions.scope must be null or the factory instance that '
        'created the meter.',
      );
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

    var scope = options.scope;
    options.scope = this;
    var m = FactoryMeter(
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

    _cachedMeters.clear();
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
