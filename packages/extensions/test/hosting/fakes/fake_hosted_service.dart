import 'package:extensions/src/hosting/hosted_service.dart';
import 'package:extensions/system.dart';

class FakeHostedService implements HostedService, Disposable {
  int startCount = 0;
  int stopCount = 0;
  int disposeCount = 0;

  void Function(CancellationToken token)? startAction;
  void Function(CancellationToken token)? stopAction;
  void Function()? disposeAction;

  @override
  Future<void> start(CancellationToken cancellationToken) {
    startCount++;
    startAction?.call(cancellationToken);
    return Future.value();
  }

  @override
  Future<void> stop(CancellationToken cancellationToken) {
    stopCount++;
    stopAction?.call(cancellationToken);
    return Future.value();
  }

  @override
  void dispose() {
    disposeCount++;
    disposeAction?.call();
  }
}
