import 'options.dart';
import 'options_cache.dart';
import 'options_factory.dart';
import 'options_service_collection_extensions.dart';
import 'options_snapshot.dart';

class OptionsManager<TOptions>
    implements Options<TOptions>, OptionsSnapshot<TOptions> {
  final OptionsFactory<TOptions> _factory;
  final OptionsCache<TOptions> _cache;

  OptionsManager(
    OptionsImplementationFactory<TOptions> builder,
    OptionsFactory<TOptions> factory,
  )   : _factory = factory,
        _cache = OptionsCache<TOptions>(builder);

  @override
  TOptions get(String? name) {
    var newName = name ?? Options.defaultName;
    var x = _cache.tryGetValue(newName);

    if (!x.$1) {
      var localFactory = _factory;
      var localName = newName;
      var options = _cache.getOrAdd(name, () => localFactory.create(localName));
      return options;
    }

    return x.$2;
  }

  @override
  TOptions get value => get(Options.defaultName);
}
