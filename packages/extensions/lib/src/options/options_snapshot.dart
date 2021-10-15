import 'options.dart';

/// Used to access the value of [TOptions] for the lifetime of a request.
abstract class OptionsSnapshot<TOptions> implements Options<TOptions> {
  /// Returns a configured [TOptions] instance with the given name.
  TOptions? get(String? name);
}
