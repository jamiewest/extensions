import '../../../primitives/cancellation_token_source.dart';
import '../../../primitives/change_token.dart';

abstract class PollingChangeToken implements ChangeToken {
  CancellationTokenSource? get cancellationTokenSource;
}
