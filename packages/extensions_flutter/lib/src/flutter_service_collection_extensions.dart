import 'package:extensions/dependency_injection.dart';
import 'package:extensions/hosting.dart';
import 'package:flutter/widgets.dart';

import 'flutter_application_lifetime.dart';
import 'flutter_error_handler.dart';
import 'service_provider_extensions.dart';

typedef RegisteredWidgetFactory =
    Widget Function(ServiceProvider sp, Widget child);

typedef ConfigureAction = void Function(FlutterBuilder builder);

/// Extension methods for adding and setting up Flutter.
extension FlutterServiceCollectionExtensions on ServiceCollection {
  /// Adds required services for Flutter.
  ServiceCollection addFlutter(ConfigureAction? configure) {
    addSingleton<HostApplicationLifetime>(
      (services) => FlutterApplicationLifetime(
        services.createLogger('ApplicationLifetime'),
      ),
    );

    addSingleton<ApplicationLifetime>(
      (services) => services.getRequiredService<HostApplicationLifetime>()
          as ApplicationLifetime,
    );

    addSingleton<ErrorHandler>(
      (services) => FlutterErrorHandler(services.createLogger('ErrorHandler')),
    );

    final builder = FlutterBuilder(this);

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
  const FlutterBuilder(ServiceCollection services) : _services = services;

  /// Gets the [ServiceCollection] where flutter services are configured.
  ServiceCollection get services => _services;
}
