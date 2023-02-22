import 'package:flutter/widgets.dart';

import '../extensions_flutter.dart';
import 'flutter_lifetime_options.dart';

typedef ConfigureAction = void Function(FlutterBuilder builder);

/// Extension methods for adding and setting up Flutter.
extension FlutterServiceCollectionExtensions on ServiceCollection {
  /// Adds required services for Flutter.
  ServiceCollection addFlutter<TApp extends Widget>(
    TApp app, {
    FlutterLifetimeOptions? options,
    ConfigureAction? configure,
  }) {
    addOptions<FlutterLifetimeOptions>(
      () => options ?? FlutterLifetimeOptions(),
    );

    addSingleton<HostApplicationLifetime>(
      (services) => FlutterApplicationLifetime(
        services
            .getService<LoggerFactory>()!
            .createLogger('ApplicationLifetime'),
      ),
    );

    addSingleton<HostLifetime>(
      (sp) => FlutterLifetime<TApp>(
        app,
        sp.getRequiredService<Options<FlutterLifetimeOptions>>(),
        sp.getServices<FlutterAppBuilder>(),
        sp,
        sp.getRequiredService<HostEnvironment>(),
        sp.getRequiredService<ApplicationLifetime>(),
        sp.getRequiredService<LoggerFactory>(),
      ),
    );

    final builder = FlutterBuilder._(this)._useFlutterLifecycleObserver();

    if (configure != null) {
      configure(builder);
    }

    return this;
  }
}

/// An interface for configuring Flutter.
class FlutterBuilder {
  final ServiceCollection _services;

  // Private constructor to ensure that the builder is created internally.
  FlutterBuilder._(ServiceCollection services) : _services = services;

  /// Gets the [ServiceCollection] where flutter services are configured.
  ServiceCollection get services => _services;
}

/// Adds Flutter lifecycle monitoring.
extension FlutterLifecycleObserverBuilder on FlutterBuilder {
  FlutterBuilder _useFlutterLifecycleObserver() {
    use(
      (services, child) => FlutterLifecycleObserver(
        lifetime: services.getRequiredService<HostApplicationLifetime>()
            as FlutterApplicationLifetime,
        child: child,
      ),
    );
    return this;
  }
}
