typedef ConfigureAction<TOptions> = void Function(TOptions options);

/// Represents something that configures the [TOptions] type.
/// Note: These are run before all `PostConfigureOptions`.
abstract class ConfigureOptions<TOptions> {
  /// Invoked to configure a [TOptions] instance.
  void configure(TOptions options);
}

/// Implementation of [ConfigureOptions].
class ConfigureOptionsBase<TOptions extends Object>
    implements ConfigureOptions<TOptions> {
  ConfigureOptionsBase(this.action);

  /// The configuration action.
  final ConfigureAction<TOptions> action;

  /// Invokes the registered configure [action].
  @override
  void configure(TOptions options) => action.call(options);
}
