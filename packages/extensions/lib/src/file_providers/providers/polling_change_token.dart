import '../../../primitives.dart';

abstract class PollingChangeToken implements ChangeToken {
  CancellationTokenSource? get cancellationTokenSource;
}
