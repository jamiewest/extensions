import '../primitives/change_token.dart';
import '../system/disposable.dart';
import 'options.dart';
import 'options_change_token_source.dart';
import 'options_factory.dart';
import 'options_monitor_cache.dart';

typedef OnChangeListener<TOptions> = void Function(
  TOptions options, [
  String? name,
]);

/// Used for notifications when [TOptions] instances change.
class OptionsMonitor<TOptions> implements Disposable {
  final OptionsMonitorCache<TOptions> _cache;
  final OptionsFactory<TOptions> _factory;
  final List<Disposable> _registrations = <Disposable>[];
  OnChangeListener<TOptions>? _onChange;

  OptionsMonitor(
    OptionsFactory<TOptions> factory,
    Iterable<OptionsChangeTokenSource<TOptions>> sources,
    OptionsMonitorCache<TOptions> cache,
  )   : _factory = factory,
        _cache = cache {
    for (var source in sources.toList()) {
      var registration = ChangeToken.onChangeWithState(
        () => source.getChangeToken(),
        _invokeChanged,
        source.name,
      );

      _registrations.add(registration);
    }
  }

  void _invokeChanged(String? name) {
    var newName = name ?? Options.defaultName;
    _cache.tryRemove(newName);
    var options = get(newName);
    if (_onChange != null) {
      _onChange!.call(options, name);
    }
  }

  /// The present value of the options.
  TOptions get currentValue => get(Options.defaultName);

  @override
  void dispose() {
    for (var registration in _registrations) {
      registration.dispose();
    }
    _registrations.clear();
  }

  /// Returns a configured [TOptions] instance with the given [name].
  TOptions get(String? name) {
    var newName = name ?? Options.defaultName;
    return _cache.getOrAdd(newName, () => _factory.create(newName));
  }

  /// Registers a listener to be called whenever a named [TOptions] changes.
  Disposable? onChange(OnChangeListener<TOptions> listener) {
    var disposable = _ChangeTrackerDisposable<TOptions>(this, listener);
    _onChange = disposable.onChange;
    return disposable;
  }
}

class _ChangeTrackerDisposable<TOptions> implements Disposable {
  final OnChangeListener<TOptions> _listener;
  final OptionsMonitor<TOptions> _monitor;

  _ChangeTrackerDisposable(
    OptionsMonitor<TOptions> monitor,
    OnChangeListener<TOptions> listener,
  )   : _listener = listener,
        _monitor = monitor;

  void onChange(TOptions options, [String? name]) =>
      _listener.call(options, name);

  @override
  void dispose() => _monitor._onChange = null;
}
