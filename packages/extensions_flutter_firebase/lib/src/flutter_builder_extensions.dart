import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';

import 'firebase_builder.dart';
import 'firebase_builder_options.dart';
import 'firebase_lifetime.dart';

typedef ConfigureFirebaseBuilder = void Function(FirebaseBuilder builder);
typedef ConfigureFirebaseOptions = FlutterFirebaseOptions Function(
    FlutterFirebaseOptions options);

extension FlutterBuilderExtensions on FlutterBuilder {
  FlutterBuilder addFirebase(FirebaseOptions options) {
    services.addSingletonInstance<FirebaseOptions>(options);

    services.addSingleton<FirebaseAnalytics>(
      (services) => FirebaseAnalytics.instance,
    );

    services.addSingleton<FirebaseCrashlytics>(
      (services) => FirebaseCrashlytics.instance,
    );
    services.addSingleton<HostLifetime>(
      (s) => FirebaseLifetime(
        app: s.getRequiredService<Widget>(),
        services: s,
        logger: s
            .getRequiredService<LoggerFactory>()
            .createLogger('Hosting.Lifetime'),
        lifetime: s.getRequiredService<HostApplicationLifetime>(),
        environment: s.getRequiredService<HostEnvironment>()
            as FlutterHostingEnvironment,
        options: s.getRequiredService<FirebaseOptions>(),
      ),
    );

    return this;
  }
}
