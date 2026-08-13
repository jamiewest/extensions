import 'package:extensions/hosting.dart';
import 'package:extensions/hosting_io.dart';
import 'package:extensions/system.dart';

/// Shows how to register and run a simple hosted background service.
///
/// Run this file to see host startup followed by one background loop iteration.
Future<void> main(List<String> args) async {
  print('=== Background Service Example ===');
  // #region register_background_service
  await createDefaultBuilder(args)
      .configureServices((context, services) {
        services.addHostedService<MyBackgroundService>(
          (services) => MyBackgroundService(),
        );
      })
      .useConsoleLifetime()
      .build()
      .run();
  // #endregion
}

// #region background_service
final class MyBackgroundService extends BackgroundService {
  @override
  Future<void> execute(CancellationToken stoppingToken) async {
    print('--- Service Work ---');
    print('Background service is running once and then exiting.');
  }
}
// #endregion
