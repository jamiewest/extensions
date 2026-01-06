import 'package:extensions/dependency_injection.dart';
import 'package:extensions/hosting.dart';
import 'package:extensions_flutter/src/flutter_builder.dart';
import 'package:flutter/widgets.dart';

import 'flutter_application_lifetime.dart';
import 'flutter_error_handler.dart';
import 'flutter_lifetime_options.dart';
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
      (services) =>
          services.getRequiredService<HostApplicationLifetime>()
              as ApplicationLifetime,
    );

    addSingleton<ErrorHandler>(
      (services) => FlutterErrorHandler(services.createLogger('ErrorHandler')),
    );

    final builder = FlutterBuilder(this);

    // configure<FlutterLifetimeOptions>(FlutterLifetimeOptions.new, (options) {
    //   options.suppressStatusMessages = false;
    // });

    if (configure != null) {
      configure(builder);
    }

    return this;
  }
}
