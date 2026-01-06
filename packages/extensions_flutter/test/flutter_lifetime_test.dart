import 'dart:ui';

import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:extensions_flutter/src/flutter_error_handler.dart';
import 'package:extensions_flutter/src/flutter_lifetime_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestHostEnvironment implements HostEnvironment {
  @override
  String applicationName = 'test-app';

  @override
  String contentRootPath = '/tmp';

  @override
  FileProvider? contentRootFileProvider;

  @override
  String environmentName = 'test';
}

class _TestErrorHandler implements ErrorHandler {
  @override
  FlutterExceptionHandler? onFlutterError;

  @override
  ErrorCallback? onError;
}

// void main() {
//   TestWidgetsFlutterBinding.ensureInitialized();

//   test('waitForStart throws when cancellation is already requested', () async {
//     final lifetime = FlutterApplicationLifetime(NullLogger());
//     final flutterLifetime = FlutterLifetime(
//       const SizedBox.shrink(),
//       _TestErrorHandler(),
//       _TestHostEnvironment(),
//       lifetime,
//       FlutterLifetimeOptions(),
//       const NullLoggerFactory(),
//     );

//     await expectLater(
//       flutterLifetime.waitForStart(CancellationToken(true)),
//       throwsA(isA<OperationCanceledException>()),
//     );

//     expect(lifetime.applicationPaused, isEmpty);
//     expect(lifetime.applicationResumed, isEmpty);
//     expect(lifetime.applicationInactive, isEmpty);
//     expect(lifetime.applicationHidden, isEmpty);
//     expect(lifetime.applicationDetached, isEmpty);
//   });
// }
