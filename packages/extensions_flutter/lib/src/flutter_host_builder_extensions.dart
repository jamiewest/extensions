import 'package:extensions/hosting.dart';

import 'flutter_application_lifetime.dart';
import 'flutter_lifetime.dart';
import 'flutter_lifetime_options.dart';

typedef FlutterOptions = void Function(FlutterLifetimeOptions options);

extension FlutterHostBuilderExtensions on HostBuilder {
  HostBuilder useFlutterLifetime([
    FlutterOptions? configure,
    CancellationToken? cancellationToken,
  ]) {
    final options = FlutterLifetimeOptions();

    if (configure != null) {
      configure(options);
    }

    configureServices(
      (context, services) => services
        ..addSingleton<HostApplicationLifetime>(
          (services) => FlutterApplicationLifetime(
            services
                .getService<LoggerFactory>()!
                .createLogger('ApplicationLifetime'),
          ),
        )
        ..addSingleton<HostLifetime>(
          (sp) => FlutterLifetime(
            sp.getRequiredService<Options<FlutterLifetimeOptions>>(),
            sp.getRequiredService<HostEnvironment>(),
            sp.getRequiredService<ApplicationLifetime>(),
            sp.getRequiredService<LoggerFactory>(),
          ),
        )
        ..addOptions<FlutterLifetimeOptions>(() => options).validate(
          (options) {
            if (options.application != null) {
              return true;
            }
            return false;
          },
          'The application argument is required.',
        ).validateOnStart(),
    );

    return this;
  }

  /// Enables Flutter support, builds and starts the host, and waits.
  Future<void> runFlutter([
    FlutterOptions? configure,
    CancellationToken? cancellationToken,
  ]) =>
      useFlutterLifetime(configure).build().run(cancellationToken);
}
