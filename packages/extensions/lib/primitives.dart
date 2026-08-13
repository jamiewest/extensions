/// Contains fundamental primitives and change notification types used
/// throughout the extensions package.
///
/// This library provides isolated types that are shared across multiple
/// components, inspired by Microsoft.Extensions.Primitives.
///
/// ## Change Tokens
///
/// A change token signals that something it watches has changed:
///
/// {@example /example/example_primitives.dart#cancellation_change_token}
///
/// Treat several tokens as one with [CompositeChangeToken]:
///
/// {@example /example/example_primitives.dart#composite_change_token}
///
/// ## Change Token Patterns
///
/// `ChangeToken.onChange` re-registers after every change, so one
/// registration survives repeated reloads:
///
/// {@example /example/example_primitives.dart#change_token_on_change}
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

export 'src/primitives/cancellation_change_token.dart'
    show CancellationChangeToken;
export 'src/primitives/change_token.dart'
    show
        ChangeCallback,
        ChangeToken,
        ChangeTokenConsumer,
        ChangeTokenProducer,
        ChangeTokenTypedConsumer;
export 'src/primitives/composite_change_token.dart' show CompositeChangeToken;
export 'src/primitives/validation_result.dart';
export 'src/primitives/void_callback.dart';
export 'src/system/exceptions/aggregate_exception.dart' show AggregateException;
