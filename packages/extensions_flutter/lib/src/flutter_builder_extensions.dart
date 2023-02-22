import 'package:extensions/dependency_injection.dart';
import 'package:flutter/widgets.dart';

import 'flutter_service_collection_extensions.dart';

typedef FlutterAppBuilder = Widget Function(
  ServiceProvider services,
  Widget child,
);

/// Registers a builder callback that wraps the the root application widget.
///
/// This is useful in scenarios where you need to wrap the root widget in order
/// to provide some functionality.
extension FlutterBuilderExtensions on FlutterBuilder {
  FlutterBuilder use(FlutterAppBuilder builder) {
    services.tryAddIterable(
      ServiceDescriptor.transient<FlutterAppBuilder>((services) => builder),
    );
    return this;
  }
}
