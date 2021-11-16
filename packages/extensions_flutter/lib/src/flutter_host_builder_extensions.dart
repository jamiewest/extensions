import 'package:extensions/hosting.dart';
import 'package:flutter/widgets.dart';

import 'flutter_application_lifetime.dart';
import 'flutter_lifetime.dart';
import 'flutter_lifetime_options.dart';

extension FlutterHostBuilderExtensions on HostBuilder {
  HostBuilder useFlutterLifetime(
    Widget app,
    FlutterLifetimeOptions options,
  ) {
    configureServices((context, services) {
      services
        ..addSingleton<Widget>(implementationInstance: app)
        ..addSingleton<HostApplicationLifetime>(
          implementationFactory: (s) => FlutterApplicationLifetime(
            s.getService<LoggerFactory>().createLogger('ApplicationLifetime'),
          ),
        )
        ..addSingleton<HostLifetime>(
          implementationFactory: (s) => FlutterLifetime(
            app: s.getRequiredService<Widget>(),
            options: options,
            logger: s
                .getRequiredService<LoggerFactory>()
                .createLogger('FlutterHostedService'),
            lifetime: s.getRequiredService<HostApplicationLifetime>(),
          ),
        );
    });
    return this;
  }

  /// Enables Flutter support and builds and starts the host.
  Future<void> runFlutter(
    Widget app,
    FlutterLifetimeOptions options,
    CancellationToken cancellationToken,
  ) =>
      useFlutterLifetime(app, options).build().run(cancellationToken);
}
