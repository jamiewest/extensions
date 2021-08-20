import '../dependency_injection/service_collection.dart';
import 'options.dart';

typedef ConfigureOptions<TOptions> = void Function(TOptions options);
typedef ConfigureOptions1<TOptions, TDep> = void Function(
    TOptions options, TDep dep);

class OptionsBuilder<TOptions> {
  final String defaultValidationFailureMessage =
      'A validation error has occurred.';

  final String _name;

  /// Creates a new [OptionsBuilder] instance.
  OptionsBuilder(this.services, String? name)
      : _name = name ?? Options.defaultName;

  /// The default name of the [TOptions] instance.
  String get name => _name;

  /// The [ServiceCollection] for the options being configured.
  final ServiceCollection services;

  // OptionsBuilder<TOptions> configure(
  //   ConfigureOptions<TOptions> configureOptions,
  // ) {
  //   services.addSingleton<IConfigureOptions<TOptions>>(
  //     ConfigureNamedOptions(name, configureOptions),
  //   );
  //   return this;
  // }

  // OptionsBuilder<TOptions> configure1<TDep>(
  //   ConfigureOptions1<TOptions, TDep> configureOptions,
  // ) {
  //   services.addTransient<IConfigureOptions<TOptions>>(
  //     ConfigureNamedOptions(name, configureOptions),
  //   );
  //   return this;
  // }
}
