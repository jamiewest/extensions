import '../primitives/change_token.dart';

/// Used to fetch [ChangeToken] used for tracking options changes.
abstract class OptionsChangeTokenSource<TOptions> {
  /// Returns a [ChangeToken] which can be used to register
  /// a change notification callback.
  ChangeToken getChangeToken();

  /// The name of the option instance being changed.
  String get name;
}
