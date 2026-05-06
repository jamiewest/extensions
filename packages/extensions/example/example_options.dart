import 'package:extensions/dependency_injection.dart';
import 'package:extensions/hosting.dart';
import 'package:extensions/options.dart';
import 'package:extensions/src/hosting/hosting_host_builder_extensions_io.dart';
import 'package:extensions/system.dart';

/// Demonstrates named options registrations resolved via `OptionsSnapshot<T>`.
///
/// Run this file to print two separately named `MyOptions` instances.
Future<void> main(List<String> args) async => Host.createDefaultBuilder()
    .configureServices(
      (context, services) {
        services
          ..configure<MyOptions>(
            MyOptions.new,
            (options) => options.option = 'Primary options value',
            name: _primaryOptionsName,
          )
          ..configure<MyOptions>(
            MyOptions.new,
            (options) => options.option = 'Secondary options value',
            name: _secondaryOptionsName,
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

const _primaryOptionsName = 'custom_options';
const _secondaryOptionsName = 'custom_options1';

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
    print('=== Options Example ===');
    print('--- Resolve Named Options ---');
    print('$_primaryOptionsName: ${options.get(_primaryOptionsName)?.option}');
    print(
      '$_secondaryOptionsName: '
      '${options.get(_secondaryOptionsName)?.option}',
    );
    return Future.value();
  }

  @override
  Future<void> stop(CancellationToken cancellationToken) => Future.value();
}
