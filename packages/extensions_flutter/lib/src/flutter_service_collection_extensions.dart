import 'package:extensions/hosting.dart';
import 'package:flutter/widgets.dart';

import 'flutter_application_lifetime.dart';
import 'flutter_builder.dart';
import 'flutter_hosting_environment.dart';
import 'flutter_lifetime.dart';

typedef ConfigureFlutterBuilder = void Function(FlutterBuilder builder);

/// Contains extension methods to [ServiceCollection] for configuring Flutter.
extension FlutterServiceCollectionExtensions on ServiceCollection {
  ServiceCollection addFlutter([ConfigureFlutterBuilder? configure]) {
    addSingleton<HostApplicationLifetime>(
      (services) => FlutterApplicationLifetime(
        services
            .getService<LoggerFactory>()!
            .createLogger('ApplicationLifetime'),
      ),
    );
    addSingleton<HostLifetime>(
      (services) => FlutterLifetime(
        app: services.getRequiredService<Widget>(),
        //options: options,
        logger: services
            .getRequiredService<LoggerFactory>()
            .createLogger('Hosting.Lifetime'),
        lifetime: services.getRequiredService<HostApplicationLifetime>(),
        environment: services.getRequiredService<HostEnvironment>()
            as FlutterHostingEnvironment,
      ),
    );

    addSingleton<HostingEnvironment>((_) => FlutterHostingEnvironment());
    addSingleton<HostEnvironment>(
      (services) => services.getRequiredService<HostingEnvironment>(),
    );
    addSingleton<FlutterHostingEnvironment>(
      (services) => services.getRequiredService<HostingEnvironment>(),
    );

    if (configure != null) {
      final builder = FlutterBuilder(this);
      configure(builder);
    }

    return this;
  }
}
