import 'package:extensions/hosting.dart';
import 'package:extensions/src/hosting/hosting_host_builder_extensions_io.dart';
import 'package:extensions/system.dart';

/// Shows how to register and run a simple hosted background service.
///
/// Run this file to see host startup followed by one background loop iteration.
Future<void> main(List<String> args) async {
  print('=== Background Service Example ===');
  await createDefaultBuilder(args)
      .configureServices((context, services) {
        services.addHostedService<MyBackgroundService>(
          (services) => MyBackgroundService(),
        );
      })
      .useConsoleLifetime()
      .build()
      .run();
}

final class MyBackgroundService extends BackgroundService {
  @override
  Future<void> execute(CancellationToken stoppingToken) async {
    print('--- Service Work ---');
    print('Background service is running once and then exiting.');
  }
}
