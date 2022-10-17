import 'package:extensions/hosting.dart';
import 'package:extensions/src/hosting/hosting_host_builder_extensions_io.dart';

Future<void> main(List<String> args) async {
  await createDefaultBuilder(args)
      .configureServices((context, services) {
        services.addHostedService<MyBackgroundService>(
          (services) => MyBackgroundService(),
        );
      })
      .useConsoleLifetime(null)
      .build()
      .run();
}

class MyBackgroundService extends BackgroundService {
  @override
  Future<void> execute(CancellationToken stoppingToken) {
    print('hmmmmm');
    return Future.value();
  }
}
