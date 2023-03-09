import '../primitives/void_callback.dart';

class ValidatorOptions {
  final Map<Type, VoidCallback> _validators;

  ValidatorOptions() : _validators = <Type, VoidCallback>{};
  // Maps each options type to a method that forces its
  // evaluation, e.g. OptionsMonitor<TOptions>.get(name)
  Map<Type, VoidCallback> get validators => _validators;
}
