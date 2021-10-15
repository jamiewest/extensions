import 'package:extensions/dependency_injection.dart';
import 'package:extensions/hosting.dart';
import 'package:extensions/logging.dart';
import 'package:extensions_flutter/src/flutter_lifetime.dart';
import 'package:extensions_flutter/src/flutter_lifetime_options.dart';
import 'package:flutter/widgets.dart';

import 'flutter_application_lifetime.dart';

extension FlutterServiceCollectionExtensions on ServiceCollection {
  ServiceCollection addFlutter(
    Widget app,
    FlutterLifetimeOptions options,
  ) {
    addSingleton<HostApplicationLifetime>(
      implementationFactory: (s) => FlutterApplicationLifetime(
        s.getService<LoggerFactory>().createLogger('ApplicationLifetime'),
      ),
    );
    addSingleton<HostLifetime>(
      implementationFactory: (services) => FlutterLifetime(
        app: app,
        options: options,
        logger: services
            .getRequiredService<LoggerFactory>()
            .createLogger('FlutterHostedService'),
        lifetime: services.getRequiredService<HostApplicationLifetime>(),
      ),
    );
    return this;
  }
}
