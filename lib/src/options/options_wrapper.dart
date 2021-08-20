import 'options.dart';

/// [Options] wrapper that returns the options instance.
class OptionsWrapper<TOptions> implements Options<TOptions> {
  final TOptions _options;

  /// Initializes the wrapper with the options instance to return.
  OptionsWrapper(TOptions options) : _options = options;

  /// The options instance.
  @override
  TOptions get value => _options;
}
