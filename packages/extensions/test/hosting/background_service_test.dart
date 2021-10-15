// import 'dart:async';

// import 'package:async/async.dart';
// import 'package:extensions/src/hosting/background_service.dart';
// import 'package:extensions/src/shared/cancellation_token.dart';
// import 'package:test/test.dart';

// void main() {
//   group('Configuration', () {
//     test('StartReturnsCompletedTaskIfLongRunningTaskIsIncomplete', () {
//       var c = Completer();
//       var service = MyBackgroundService(c.future);

//       var t = service.start(CancellationToken.none);
//       var x = CancelableCompleter();
//       x
//     });
//   });
// }

// class MyBackgroundService extends BackgroundService {
//   final CancelableOperation _future;

//   MyBackgroundService(Future future)
//       : _future = CancelableOperation.fromFuture(future);

//   @override
//   Future<void> execute(CancellationToken stoppingToken) async {
//     await executeCore(stoppingToken);
//   }

//   Future<void> executeCore(CancellationToken stoppingToken) async {
//     var c = Completer();
//     stoppingToken.register((o) {
//       c.complete();
//     });

//     await Future.any([
//       _future.value,
//       c.future,
//     ]);
//   }
// }
