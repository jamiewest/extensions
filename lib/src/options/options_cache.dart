import 'package:tuple/tuple.dart';

import 'options.dart';
import 'options_monitor_cache.dart';
import 'options_service_collection_extensions.dart';

class OptionsCache<TOptions> implements OptionsMonitorCache<TOptions> {
  final Map<String, TOptions> _cache = <String, TOptions>{};
  final ImplementationFactory<TOptions> _factory;

  OptionsCache(ImplementationFactory<TOptions> factory) : _factory = factory;

  /// Clears all options instances from the cache.
  @override
  void clear() => _cache.clear();

  /// Gets a named options instance, or adds a new instance created
  /// with [createOptions].
  @override
  TOptions getOrAdd(String? name, CreateOptions<TOptions> createOptions) {
    var _name = name ?? Options.defaultName;
    return _cache.putIfAbsent(_name, () => createOptions.call());
  }

  /// Gets a named options instance, if available.
  Tuple2<bool, TOptions> tryGetValue(String? name) {
    if (_cache.containsKey(name)) {
      return Tuple2<bool, TOptions>(true, _cache[name]!);
    }
    return Tuple2<bool, TOptions>(false, _factory.call());
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
