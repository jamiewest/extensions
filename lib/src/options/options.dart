import 'options_wrapper.dart';

/// Used to retrieve configured [TOptions] instances.
class Options<TOptions> {
  /// The default configured [TOptions] instance.
  external TOptions get value;

  /// the default name used for options instances: ''.
  static const String defaultName = '';

  /// Creates a wrapper around an instance of [TOptions] to return itself as an
  /// [Options<TOptions>].
  static Options<TOptions> create<TOptions>(TOptions options) =>
      OptionsWrapper<TOptions>(options);
}
