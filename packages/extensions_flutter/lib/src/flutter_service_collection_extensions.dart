import 'package:flutter/widgets.dart';

import '../extensions_flutter.dart';

typedef AppBuilder = Widget Function(ServiceProvider services);

/// Contains extension methods to [ServiceCollection] for configuring Flutter.
extension FlutterServiceCollectionExtensions on ServiceCollection {
  ServiceCollection addFlutter(
    AppBuilder appBuilder, {
    FlutterLifetimeOptions? options,
  }) {
    this
      ..addSingleton<Widget>((s) => appBuilder(s))
      ..addSingleton<HostApplicationLifetime>(
        (s) => FlutterApplicationLifetime(
          s.getService<LoggerFactory>()!.createLogger('ApplicationLifetime'),
        ),
      )
      ..addSingleton<HostLifetime>(
        (s) => FlutterLifetime(
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
