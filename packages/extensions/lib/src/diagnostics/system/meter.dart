part of diagnostics;

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
      // instrument.notifyForUnpublishedInstrument();
    }
  }

  static Instrument? _getCachedInstrument(
    List<Instrument> instrumentList,
    Type instrumentType,
    String? unit,
    String? description,
    Map<String, Object?>? tags,
  ) {
    for (var instrument in instrumentList) {
      if (instrument.runtimeType == instrumentType &&
          instrument.unit == unit &&
          instrument.description == description &&
          instrument.tags == tags) {
        return instrument;
      }
    }

    return null;
  }

  Instrument _getOrCreateInstrument<T>(
    Type instrumentType,
    String name,
    String? unit,
    String? description,
    Map<String, Object?>? tags,
    Instrument Function() instrumentCreator,
  ) {
    List<Instrument>? instrumentList;

    if (!_nonObservableInstrumentsCache.containsKey(name)) {
      instrumentList = <Instrument>[];
      _nonObservableInstrumentsCache[name] = instrumentList;
    }

    instrumentList = _nonObservableInstrumentsCache[name];

    Instrument? cachedInstrument = _getCachedInstrument(
      instrumentList!,
      instrumentType,
      unit,
      description,
      tags,
    );

    if (cachedInstrument != null) {
      return cachedInstrument;
    }

    Instrument newInstrument = instrumentCreator.call();

    cachedInstrument = _getCachedInstrument(
      instrumentList,
      instrumentType,
      unit,
      description,
      tags,
    );

    if (cachedInstrument != null) {
      return cachedInstrument;
    }

    instrumentList.add(newInstrument);

    return newInstrument;
  }

  bool _addInstrument(Instrument instrument) {
    if (!_instruments.contains(instrument)) {
      _instruments.add(instrument);
      return true;
    }
    return false;
  }

  static List<Instrument>? _getPublishedInstruments() {
    List<Instrument>? instruments;

    if (_allMeters.length > 0) {
      instruments = <Instrument>[];

      for (var meter in _allMeters) {
        for (var instrument in meter._instruments) {
          instruments.add(instrument);
        }
      }
    }
    return instruments;
  }
}
