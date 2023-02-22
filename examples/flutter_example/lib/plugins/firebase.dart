import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

typedef ConfigureAction = void Function(FirebaseBuilder builder);

extension FirebaseFlutterBuilder on FlutterBuilder {
  FlutterBuilder useFirebase({
    required FirebaseOptions options,
    ConfigureAction? configure,
  }) {
    services.addHostedService<FirebaseHostedService>(
      (services) => FirebaseHostedService(
        options: options,
        services: services,
        logger: services.createLogger('Firebase'),
      ),
    );

    if (configure != null) {
      configure(FirebaseBuilder._(services));
    }
    return this;
  }
}

extension FirebaseBuilderExtensions on FirebaseBuilder {
  FirebaseBuilder addAnalytics() {
    services.addSingleton<FirebaseAnalytics>((sp) {
      sp.createLogger('Firebase').logTrace('-> Loading analytics');
      return FirebaseAnalytics.instance;
    });
    return this;
  }

  FirebaseBuilder addCrashlytics() {
    services.addSingleton<FirebaseCrashlytics>((sp) {
      sp.createLogger('Firebase').logTrace('-> Loading crashlytics');
      return FirebaseCrashlytics.instance;
    });

    return this;
  }
}

class FirebaseBuilder {
  final ServiceCollection _services;

  // Private constructor to ensure that the builder is created internally.
  FirebaseBuilder._(ServiceCollection services) : _services = services;

  /// Gets the [ServiceCollection] where flutter services are configured.
  ServiceCollection get services => _services;
}

class FirebaseHostedService extends HostedService {
  FirebaseApp? _app;
  final FirebaseOptions _options;
  final ServiceProvider _services;
  final Logger _logger;

  FirebaseHostedService({
    required FirebaseOptions options,
    required ServiceProvider services,
    required Logger logger,
  })  : _options = options,
        _services = services,
        _logger = logger;

  @override
  Future<void> start(CancellationToken cancellationToken) async {
    WidgetsFlutterBinding.ensureInitialized();
    _logger.logDebug('Starting Firebase...');
    _app = await Firebase.initializeApp(
      name: _services.getRequiredService<HostEnvironment>().applicationName,
      options: _options,
    );

    final crashlytics = _services.getService<FirebaseCrashlytics>();
    if (crashlytics != null) {
      PlatformDispatcher.instance.onError = (error, stack) {
        crashlytics.recordError(error, stack, fatal: true);
        return true;
      };

      FlutterError.onError = (errorDetails) {
        crashlytics.recordFlutterFatalError(errorDetails);
      };
    }

    _services.getService<FirebaseAnalytics>()?.logAppOpen();
  }

  @override
  Future<void> stop(CancellationToken cancellationToken) async {
    _logger.logInformation('Stopping Firebase...');
    if (_app != null) {
      await _app!.delete();
    }
  }
}
