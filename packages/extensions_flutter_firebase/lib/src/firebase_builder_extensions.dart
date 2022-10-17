import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:extensions_flutter_firebase/extensions_flutter_firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

extension FirebaseBuilderExtensions on FirebaseBuilder {
  FirebaseBuilder addAnalytics() {
    services.addSingleton<FirebaseAnalytics>(
      (services) => FirebaseAnalytics.instance,
    );
    return this;
  }

  FirebaseBuilder addCrashlytics() {
    services.addSingleton<FirebaseCrashlytics>(
      (services) => FirebaseCrashlytics.instance,
    );
    services.addSingleton<HostLifetime>(
      (services) => FirebaseLifetime(
        app: services.getRequiredService<Widget>(),
        services: services,
        logger: services
            .getRequiredService<LoggerFactory>()
            .createLogger('Hosting.Lifetime'),
        lifetime: services.getRequiredService<HostApplicationLifetime>(),
        environment: services.getRequiredService<HostEnvironment>()
            as FlutterHostingEnvironment,
        options: services.getRequiredService<FirebaseOptions>(),
      ),
    );
    return this;
  }
}
