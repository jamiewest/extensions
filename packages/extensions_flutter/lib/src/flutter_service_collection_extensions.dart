import 'package:extensions/dependency_injection.dart';
import 'package:extensions/hosting.dart';
import 'package:extensions/logging.dart';
import 'package:flutter/widgets.dart';

import 'flutter_application_lifetime.dart';
import 'flutter_lifetime.dart';
import 'flutter_lifetime_options.dart';

extension FlutterServiceCollectionExtensions on ServiceCollection {
  ServiceCollection addFlutter(
    Widget app,
    FlutterLifetimeOptions options,
  ) {
    addSingleton<Widget>(implementationInstance: app);
    addSingleton<HostApplicationLifetime>(
      implementationFactory: (s) => FlutterApplicationLifetime(
        s.getService<LoggerFactory>().createLogger('ApplicationLifetime'),
      ),
    );
    addSingleton<HostLifetime>(
      implementationFactory: (s) => FlutterLifetime(
        app: s.getRequiredService<Widget>(),
        options: options,
        logger: s
            .getRequiredService<LoggerFactory>()
            .createLogger('FlutterHostedService'),
        lifetime: s.getRequiredService<HostApplicationLifetime>(),
      ),
    );
    return this;
  }
}
