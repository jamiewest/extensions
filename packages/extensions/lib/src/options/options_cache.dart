import 'options.dart';
import 'options_monitor_cache.dart';
import 'options_service_collection_extensions.dart';

class OptionsCache<TOptions> implements OptionsMonitorCache<TOptions> {
  final Map<String, TOptions> _cache = <String, TOptions>{};
  final OptionsImplementationFactory<TOptions> _factory;

  OptionsCache(OptionsImplementationFactory<TOptions> factory)
      : _factory = factory;

  /// Clears all options instances from the cache.
  @override
  void clear() => _cache.clear();

  /// Gets a named options instance, or adds a new instance created
  /// with [createOptions].
  @override
  TOptions getOrAdd(String? name, CreateOptions<TOptions> createOptions) {
    var newName = name ?? Options.defaultName;
    return _cache.putIfAbsent(newName, () => createOptions.call());
  }

  /// Gets a named options instance, if available.
  (bool, TOptions) tryGetValue(String? name) {
    if (_cache.containsKey(name)) {
      return (true, _cache[name] as TOptions);
    }
    return (false, _factory.call());
  }

  @override
  bool tryAdd(String? name, TOptions options) {
    _cache.putIfAbsent(name ?? Options.defaultName, _factory.call);
    if (_cache.containsKey(name)) {
      return true;
    }
    return false;
  }

  @override
  bool tryRemove(String? name) =>
      _cache.remove(name ?? Options.defaultName) == null;
}
