import 'package:extensions/primitives.dart';
import 'package:extensions/system.dart';

/// Demonstrates change tokens, composition, and cooperative cancellation.
///
/// Run this file to see callbacks fire as tokens change and are cancelled.
void main() {
  print('=== Primitives Example ===');

  _cancellationTokenExample();
  _compositeChangeTokenExample();
  _onChangeExample();
}

/// Bridges a [CancellationToken] into the change-token model.
void _cancellationTokenExample() {
  print('--- Cancellation Change Token ---');

  // #region cancellation_change_token
  final source = CancellationTokenSource();
  final changeToken = CancellationChangeToken(source.token);

  changeToken.registerChangeCallback(
    (state) => print('callback fired with state: $state'),
    'cancelled',
  );

  print('hasChanged before cancel: ${changeToken.hasChanged}');
  source.cancel();
  print('hasChanged after cancel: ${changeToken.hasChanged}');
  // #endregion
}

/// Treats several tokens as one.
void _compositeChangeTokenExample() {
  print('--- Composite Change Token ---');

  // #region composite_change_token
  final first = CancellationTokenSource();
  final second = CancellationTokenSource();

  // The composite reports a change as soon as *any* member changes.
  final composite = CompositeChangeToken([
    CancellationChangeToken(first.token),
    CancellationChangeToken(second.token),
  ]);

  print('hasChanged initially: ${composite.hasChanged}');
  second.cancel();
  print('hasChanged after one member fired: ${composite.hasChanged}');
  // #endregion
}

/// Re-registers automatically after every change.
void _onChangeExample() {
  print('--- ChangeToken.onChange ---');

  // #region change_token_on_change
  // The producer is called again after each change, so a single registration
  // survives repeated reloads — the pattern configuration reload uses.
  var generation = 0;
  var source = CancellationTokenSource();

  final registration = ChangeToken.onChange(
    () {
      generation++;
      return CancellationChangeToken(source.token);
    },
    () => print('configuration reloaded (generation $generation)'),
  );

  final previous = source;
  source = CancellationTokenSource();
  previous.cancel();

  registration.dispose();
  // #endregion
}
