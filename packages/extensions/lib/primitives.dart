/// Contains isolated types that are used in many places within the extensions
/// package.
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
