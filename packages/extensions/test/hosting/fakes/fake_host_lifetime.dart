import 'package:extensions/hosting.dart';
import 'package:extensions/system.dart';

class FakeHostLifetime implements HostLifetime {
  int startCount = 0;
  int stopCount = 0;

  void Function(CancellationToken token)? startAction;
  void Function()? stopAction;

  @override
  Future<void> waitForStart(CancellationToken cancellationToken) {
    startCount++;
    startAction?.call(cancellationToken);
    return Future.value();
  }

  @override
  Future<void> stop(CancellationToken cancellationToken) {
    stopCount++;
    stopAction?.call();
    return Future.value();
  }
}
