part of 'diagnostics.dart';

/// Meter is the class responsible for creating and tracking the Instruments.
class Meter implements Disposable {
  static final List<Meter> _allMeters = <Meter>[];
  List<Instrument> _instruments = <Instrument>[];
  final Map<String, List<Instrument>> _nonObservableInstrumentsCache =
      <String, List<Instrument>>{};
  bool _disposed = false;

  final String _name;
  final String? _version;
  final Map<String, Object?>? _tags;
  final Object? _scope;

  static bool get _isSupported => _initializeIsSupported();

  static bool _initializeIsSupported() => true;

  Meter({
    required String name,
    String? version,
    Map<String, Object?>? tags,
    Object? scope,
  })  : _name = name,
        _version = version,
        _tags = tags,
        _scope = scope {
    _allMeters.add(this);
  }

  factory Meter.from(MeterOptions options) => Meter(
        name: options.name,
        version: options.version,
        tags: options.tags,
        scope: options.scope,
      );

  /// Returns the Meter name.
  String get name => _name;

  /// Returns the Meter version.
  String? get version => _version;

  /// Returns the tags associated with the meter.
  Map<String, Object?>? get tags => _tags;

  /// Returns the Meter scope object.
  Object? get scope => _scope;

  /// Dispose the Meter which will disable all instruments created by this
  /// meter.
  @override
  void dispose() => _dispose(true);

  /// Dispose the Meter which will disable all instruments created by this
  /// meter.
  void _dispose(bool disposing) {
    if (!disposing) {
      return;
    }

    List<Instrument>? instruments;

    if (_disposed) {
      return;
    }
    _disposed = true;
    _allMeters.remove(this);
    instruments = _instruments;
    _instruments = <Instrument>[];
    _nonObservableInstrumentsCache.clear();

    for (var instrument in instruments) {
      instrument._notifyForUnpublishedInstrument();
    }
  }
}
