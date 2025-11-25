import 'package:extensions/dependency_injection.dart';
import 'package:extensions/hosting.dart';
import 'package:extensions/logging.dart';
import 'package:flutter/widgets.dart';

import 'flutter_application_wrapper.dart';
import 'flutter_error_handler.dart';
import 'flutter_lifetime.dart';
import 'flutter_service_collection_extensions.dart';

typedef FlutterAppBuilder = Widget Function(
  ServiceProvider services,
);

/// Registers a builder callback that wraps the the root application widget.
///
/// This is useful in scenarios where you need to wrap the root widget in order
/// to provide some functionality.
extension FlutterBuilderExtensions on FlutterBuilder {
  FlutterBuilder useApp(FlutterAppBuilder builder) {
    services
      ..addSingleton<FlutterApplicationWrapper>(
        (s) => FlutterApplicationWrapper(builder(s)),
      )
      ..addSingleton<HostLifetime>(
        (sp) => FlutterLifetime(
          sp.getRequiredService<FlutterApplicationWrapper>(),
          sp.getRequiredService<ErrorHandler>(),
          sp.getRequiredService<HostEnvironment>(),
          sp.getRequiredService<ApplicationLifetime>(),
          sp.getRequiredService<LoggerFactory>(),
        ),
      );
    return this;
  }
}
