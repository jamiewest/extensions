import 'package:extensions/dependency_injection.dart';
import 'package:extensions/hosting.dart';
import 'package:extensions/options.dart';
import 'package:extensions/src/hosting/hosting_host_builder_extensions_io.dart';
import 'package:extensions/system.dart';

Future<void> main(List<String> args) async => Host.createDefaultBuilder()
    .configureServices(
      (context, services) {
        services
          ..configure<MyOptions>(
            MyOptions.new,
            (options) => options.option = 'Ahahaha',
            name: 'custom_options',
          )
          ..configure<MyOptions>(
            MyOptions.new,
            (options) => options.option = 'Bahahaha',
            name: 'custom_options1',
          )
          ..addHostedService<MyService>(
            (services) => MyService(
              services.getRequiredService<OptionsSnapshot<MyOptions>>(),
            ),
          );
      },
    )
    .useConsoleLifetime()
    .build()
    .run();

class MyOptions {
  String? option;
}

class MyService extends HostedService {
  MyService(
    this.options,
  );

  final OptionsSnapshot<MyOptions> options;

  @override
  Future<void> start(CancellationToken cancellationToken) {
    print(options.get('custom_options')?.option);
    print(options.get('custom_options1')?.option);
    return Future.value();
  }

  @override
  Future<void> stop(CancellationToken cancellationToken) => Future.value();
}
