import 'package:extensions/dependency_injection.dart';
import 'package:extensions/hosting.dart';
import 'package:extensions/logging.dart';
import 'package:flutter/widgets.dart';

import 'flutter_application_lifetime.dart';
import 'flutter_error_handler.dart';
import 'flutter_lifecycle_observer.dart';
import 'flutter_lifetime.dart';
import 'flutter_service_collection_extensions.dart';

typedef FlutterAppBuilder = Widget Function(ServiceProvider services);

/// Registers a builder callback that wraps the the root application widget.
///
/// This is useful in scenarios where you need to wrap the root widget in order
/// to provide some functionality.
extension FlutterBuilderExtensions on FlutterBuilder {
  FlutterBuilder useApp(FlutterAppBuilder builder) {
    addRegisteredWidget(
      (sp, child) => FlutterLifecycleObserver(
        lifetime:
            sp.getRequiredService<HostApplicationLifetime>()
                as FlutterApplicationLifetime,
        child: child,
      ),
    );

    services
      ..addKeyedSingleton<Widget>('rootAppWidget', (sp, key) {
        var factories = sp.getServices<RegisteredWidgetFactory>();
        Widget child = builder(sp);

        for (final factory in factories.toList().reversed) {
          child = factory(sp, child);
        }

        return child;
      })
      ..addSingleton<Widget>(
        (sp) => sp.getRequiredKeyedService<Widget>('rootAppWidget'),
      )
      ..addSingleton<HostLifetime>(
        (sp) => FlutterLifetime(
          sp.getRequiredKeyedService<Widget>('rootAppWidget'),
          sp.getRequiredService<ErrorHandler>(),
          sp.getRequiredService<HostEnvironment>(),
          sp.getRequiredService<ApplicationLifetime>(),
          sp.getRequiredService<LoggerFactory>(),
        ),
      );
    return this;
  }

  FlutterBuilder addRegisteredWidget(RegisteredWidgetFactory factory) {
    services.addSingleton<RegisteredWidgetFactory>((_) => factory);

    return this;
  }
}
