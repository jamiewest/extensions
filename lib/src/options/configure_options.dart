typedef ConfigureAction<TOptions> = void Function(TOptions options);

/// Represents something that configures the [TOptions] type.
/// Note: These are run before all `PostConfigureOptions`.
abstract class IConfigureOptions<TOptions> {
  /// Invoked to configure a [TOptions] instance.
  void configure(TOptions options);
}

/// Implementation of [IConfigureOptions].
class ConfigureOptions<TOptions extends Object>
    implements IConfigureOptions<TOptions> {
  ConfigureOptions(this.action);

  /// The configuration action.
  final ConfigureAction<TOptions> action;

  /// Invokes the registered configure [action].
  @override
  void configure(TOptions options) => action.call(options);
}
