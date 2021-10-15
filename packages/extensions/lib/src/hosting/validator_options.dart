class ValidatorOptions {
  final Map<Type, Function> _validators;

  ValidatorOptions() : _validators = <Type, Function>{};
  // Maps each options type to a method that forces its
  // evaluation, e.g. OptionsMonitor<TOptions>.get(name)
  Map<Type, Function> get validators => _validators;
}
