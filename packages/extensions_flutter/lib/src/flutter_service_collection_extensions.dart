import 'package:extensions/dependency_injection.dart';
import 'package:extensions/hosting.dart';
import 'package:extensions_flutter/src/flutter_builder.dart';
import 'package:flutter/widgets.dart';

import 'flutter_application_lifetime.dart';
import 'flutter_error_handler.dart';
import 'service_provider_extensions.dart';
import 'service_provider_scope.dart';

/// A factory function that wraps a widget with another widget.
///
/// Used by [FlutterBuilderExtensions.wrapWith] to create widget wrappers
/// such as providers, themes, or other ancestor widgets.
///
/// The [sp] parameter provides access to the dependency injection container.
/// The [child] parameter is the widget to be wrapped.
typedef WrappedWidgetFactory =
    Widget Function(ServiceProvider sp, Widget child);

/// A configuration callback for the [FlutterBuilder].
typedef ConfigureAction = void Function(FlutterBuilder builder);

/// Extension methods for adding Flutter support to a [ServiceCollection].
extension FlutterServiceCollectionExtensions on ServiceCollection {
  /// Adds required services for hosting a Flutter application.
  ///
  /// This registers:
  /// - [FlutterApplicationLifetime] for lifecycle event handling
  /// - [FlutterErrorHandler] for centralized error capture
  ///
  /// The [configure] callback provides a [FlutterBuilder] to set up the root
  /// widget and any widget wrappers.
  ///
  /// Example:
  /// ```dart
  /// services.addFlutter((flutter) {
  ///   flutter
  ///     ..wrapWith((sp, child) => Provider(child: child))
  ///     ..runApp((sp) => MyApp());
  /// });
  /// ```
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

    if (configure != null) {
      configure(builder);
    }

    return this;
  }
}
