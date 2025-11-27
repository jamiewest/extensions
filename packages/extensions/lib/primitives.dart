/// Contains fundamental primitives and change notification types used
/// throughout the extensions package.
///
/// This library provides isolated types that are shared across multiple
/// components, inspired by Microsoft.Extensions.Primitives.
///
/// ## Change Tokens
///
/// Track and react to changes in data sources:
///
/// ```dart
/// // Create a change token source
/// final cts = CancellationTokenSource();
/// final changeToken = CancellationChangeToken(cts.token);
///
/// // Register a callback
/// changeToken.registerChangeCallback(() {
///   print('Data changed!');
/// });
///
/// // Signal change
/// cts.cancel();
/// ```
///
/// ## Change Token Patterns
///
/// Use utility methods for common patterns:
///
/// ```dart
/// // React to changes with state
/// ChangeToken.onChangeTyped<MyData>(
///   () => dataSource.getChangeToken(),
///   (data) => print('New data: $data'),
/// );
///
/// // Composite change tokens
/// final token = CompositeChangeToken([token1, token2, token3]);
/// // Fires when any constituent token changes
/// ```
///
/// ## Validation
///
/// Use validation results for options validation:
///
/// ```dart
/// ValidationResult.success();
/// ValidationResult.fail('Invalid value');
/// ```
library;

export 'src/primitives/aggregate_exception.dart' show AggregateException;
export 'src/primitives/cancellation_change_token.dart'
    show CancellationChangeToken;
export 'src/primitives/change_token.dart'
    show
        ChangeCallback,
        ChangeToken,
        ChangeTokenConsumer,
        ChangeTokenProducer,
        ChangeTokenTypedConsumer,
        IChangeToken;
export 'src/primitives/composite_change_token.dart' show CompositeChangeToken;
export 'src/primitives/validation_result.dart';
export 'src/primitives/void_callback.dart';
