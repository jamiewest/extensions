import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:extensions_flutter_firebase/extensions_flutter_firebase.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';

extension FirebaseBuilderExtensions on FirebaseBuilder {
  FirebaseBuilder addAnalytics() {
    addFirebase();
    services.addSingleton<FirebaseAnalytics>(
      (services) => FirebaseAnalytics.instance,
    );
    return this;
  }

  FirebaseBuilder addCrashlytics() {
    addFirebase();
    services.addSingleton<FirebaseCrashlytics>(
      (services) => FirebaseCrashlytics.instance,
    );
    services.addSingleton<HostLifetime>(
      (s) => FirebaseLifetime(
        app: s.getRequiredService<Widget>(),
        logger: s
            .getRequiredService<LoggerFactory>()
            .createLogger('Hosting.Lifetime'),
        lifetime: s.getRequiredService<HostApplicationLifetime>(),
        environment: s.getRequiredService<HostEnvironment>(),
        options: s.getRequiredService<FirebaseOptions>(),
      ),
    );
    return this;
  }

  FirebaseBuilder addFirebase() {
    services
      ..tryAddSingleton<FirebaseService>((services) => FirebaseService(services
          .getRequiredService<OptionsMonitor<FirebaseBuilderOptions>>()))
      ..addHostedService<FirebaseService>(
        (services) => services.getRequiredService<FirebaseService>(),
      );
    return this;
  }
}
