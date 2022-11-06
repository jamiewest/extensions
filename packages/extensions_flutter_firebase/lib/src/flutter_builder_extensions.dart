import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'firebase_lifetime.dart';

extension FirebaseServiceCollectionExtensions on ServiceCollection {
  ServiceCollection addFirebase(FirebaseOptions options) {
    addSingletonInstance<FirebaseOptions>(options);

    addSingleton<FirebaseAnalytics>(
      (services) => FirebaseAnalytics.instance,
    );

    addSingleton<FirebaseCrashlytics>(
      (services) => FirebaseCrashlytics.instance,
    );
    addSingleton<HostLifetime>(
      (sp) => FirebaseLifetime(
        sp.getRequiredService<Options<FlutterLifetimeOptions>>(),
        sp.getRequiredService<HostEnvironment>(),
        sp.getRequiredService<ApplicationLifetime>(),
        sp.getRequiredService<LoggerFactory>(),
        sp.getRequiredService<FirebaseAnalytics>(),
        sp.getRequiredService<FirebaseCrashlytics>(),
        sp.getRequiredService<FirebaseOptions>(),
      ),
    );

    return this;
  }
}
