import 'options.dart';
import 'options_factory.dart';

class UnnamedOptionsManager<TOptions> implements Options<TOptions> {
  final OptionsFactory<TOptions> _factory;
  TOptions? _value;

  UnnamedOptionsManager(OptionsFactory<TOptions> factory) : _factory = factory;

  @override
  TOptions get value => _value ?? _factory.create(Options.defaultName);
}
