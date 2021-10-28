import 'package:extensions/hosting.dart';
import 'package:extensions/src/hosting/hosting_host_builder_extensions_io.dart';

Future<void> main(List<String> args) async =>
    await Host.createDefaultBuilder(args)
        .configureServices(
          (context, services) {
            services
              ..configure<MyOptions>(
                () => MyOptions(),
                (options) => options.option = 'Ahahaha',
                name: 'custom_options',
              )
              ..configure<MyOptions>(
                () => MyOptions(),
                (options) => options.option = 'Bahahaha',
                name: 'custom_options1',
              )
              ..addHostedService<MyService>(
                (services) => MyService(
                  services.getRequiredService<OptionsSnapshot<MyOptions>>(),
                  //services.getRequiredService<OptionsSnapshot<MyOptions1>>(),
                ),
              );
          },
        )
        .useConsoleLifetime(null)
        .build()
        .run();

class MyOptions {
  String? option;
}

class MyOptions1 {
  String? option;
}

class MyService extends HostedService {
  MyService(
    this.options,
    //this.options1,
  );

  final OptionsSnapshot<MyOptions> options;
  //final OptionsSnapshot<MyOptions1> options1;

  @override
  Future<void> start(CancellationToken cancellationToken) {
    print(options.get('custom_options')?.option);
    print(options.get('custom_options1')?.option);
    return Future.value(null);
  }

  @override
  Future<void> stop(CancellationToken cancellationToken) => Future.value(null);
}
