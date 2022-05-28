import '../../../primitives.dart';
import '../../primitives/cancellation_token.dart';

abstract class PollingChangeToken implements ChangeToken {
  CancellationTokenSource? get cancellationTokenSource;
}
