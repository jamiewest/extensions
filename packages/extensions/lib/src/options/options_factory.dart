import '../../options.dart';
import 'configure_options.dart';
import 'options_validation_exception.dart';
import 'validate_options.dart';

/// Used to create [TOptions] instances.
class OptionsFactory<TOptions> {
  final Iterable<IConfigureOptions<TOptions>> _setups;
  final Iterable<IPostConfigureOptions<TOptions>> _postConfigures;
  final Iterable<ValidateOptions<TOptions>>? _validations;
  final OptionsImplementationFactory<TOptions> _factory;

  /// Initializes a new instance with the specified options configurations.
  OptionsFactory(
    OptionsImplementationFactory<TOptions> factory, {
    Iterable<IConfigureOptions<TOptions>>? setups,
    Iterable<IPostConfigureOptions<TOptions>>? postConfigureOptions,
    Iterable<ValidateOptions<TOptions>>? validations,
  })  : _factory = factory,
        _setups = setups ?? List<IConfigureOptions<TOptions>>.empty(),
        _postConfigures = postConfigureOptions ??
            List<IPostConfigureOptions<TOptions>>.empty(),
        _validations = validations ?? List<ValidateOptions<TOptions>>.empty();

  /// Returns a configured [TOptions] instance with the given [name].
  TOptions create(String name) {
    var options = _createInstance(name);

    for (var setup in _setups) {
      if (setup is IConfigureNamedOptions<TOptions>) {
        setup.configureNamed(name, options);
      } else if (name == Options.defaultName) {
        setup.configure(options);
      }
    }

    for (var post in _postConfigures) {
      post.postConfigure(options, name: name);
    }

    if (_validations != null) {
      var failures = List<String>.empty();
      for (var validate in _validations!) {
        var result = validate.validate(name, options);
        if (result != null && result.failed) {
          failures.addAll(result.failures);
        }
      }
      if (failures.isNotEmpty) {
        throw OptionsValidationException(name, TOptions, failures);
      }
    }

    return options;
  }

  /// Creates a new instance of options type
  TOptions _createInstance(String name) => _factory();
}
