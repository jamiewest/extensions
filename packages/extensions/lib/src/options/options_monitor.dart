import '../../options.dart';
import '../primitives/change_token.dart';

import '../shared/disposable.dart';

typedef OnChangeListener<TOptions> = void Function(TOptions options,
    [String? name]);

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
    for (var source in sources as List<OptionsChangeTokenSource<TOptions>>) {
      var registration = ChangeToken.onStateChange(
        () => source.getChangeToken(),
        _invokeChanged,
        source.name,
      );

      _registrations.add(registration);
    }
  }

  void _invokeChanged(String? name) {
    var _name = name ?? Options.defaultName;
    _cache.tryRemove(_name);
    var options = get(_name);
    if (_onChange != null) {
      _onChange!.call(options, name);
    }
  }

  /// The present value of the options.
  TOptions get currentValue => get(Options.defaultName);

  @override
  void dispose() {}

  /// Returns a configured [TOptions] instance with the given [name].
  TOptions get(String? name) {
    var _name = name ?? Options.defaultName;
    return _cache.getOrAdd(_name, () => _factory.create(_name));
  }

  /// Registers a listener to be called whenever a named [TOptions] changes.
  Disposable onChange(OnChangeListener<TOptions> listener) {
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
  void dispose() => _monitor.onChange((options, [name]) => null);
}
