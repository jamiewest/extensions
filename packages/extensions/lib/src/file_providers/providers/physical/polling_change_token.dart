import '../../../primitives/change_token.dart';
import '../../../system/threading/cancellation_token_source.dart';

abstract class PollingChangeToken implements ChangeToken {
  CancellationTokenSource? get cancellationTokenSource;
}
