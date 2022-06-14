import 'package:flutter/widgets.dart';

import '../extensions_flutter.dart';

/// Contains extension methods to [ServiceCollection] for configuring Flutter.
extension FlutterServiceCollectionExtensions on ServiceCollection {
  ServiceCollection addFlutter(
    Widget app, {
    FlutterLifetimeOptions? options,
  }) {
    this
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
                .createLogger('Hosting.Lifetime'),
            lifetime: s.getRequiredService<HostApplicationLifetime>(),
            environment: s.getRequiredService<HostEnvironment>()),
      );

    return this;
  }
}
