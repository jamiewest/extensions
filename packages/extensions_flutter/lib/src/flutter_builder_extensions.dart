import 'package:extensions/dependency_injection.dart';
import 'package:extensions/hosting.dart';
import 'package:extensions/logging.dart';
import 'package:extensions/options.dart';
import 'package:extensions_flutter/src/flutter_builder.dart';
import 'package:flutter/widgets.dart';

import 'flutter_application_lifetime.dart';
import 'flutter_error_handler.dart';
import 'flutter_lifecycle_observer.dart';
import 'flutter_lifetime.dart';
import 'flutter_lifetime_options.dart';
import 'flutter_service_collection_extensions.dart';

/// A builder function that creates the root application widget.
///
/// The [services] parameter provides access to the dependency injection
/// container for resolving services needed by the widget.
typedef FlutterAppBuilder = Widget Function(ServiceProvider services);

/// A configuration callback for [FlutterLifetimeOptions].
typedef ConfigureFlutterOptions = void Function(FlutterLifetimeOptions options);

/// ConfigureOptions implementation for FlutterLifetimeOptions.
class _ConfigureFlutterLifetimeOptions
    implements ConfigureOptions<FlutterLifetimeOptions> {
  _ConfigureFlutterLifetimeOptions(this._action);
  final ConfigureFlutterOptions _action;

  @override
  void configure(FlutterLifetimeOptions options) => _action(options);
}

/// Extension methods for configuring Flutter applications via [FlutterBuilder].
///
/// These extensions provide methods for setting up the root widget,
/// adding widget wrappers, and configuring lifetime options.
extension FlutterBuilderExtensions on FlutterBuilder {
  /// Registers the root application widget and sets up the Flutter host lifetime.
  ///
  /// The [builder] callback receives a [ServiceProvider] and returns the root
  /// widget for the application. The widget is automatically wrapped with a
  /// [FlutterLifecycleObserver] to enable lifecycle event handling.
  ///
  /// Widgets registered via [wrapWith] are applied in reverse registration
  /// order, wrapping the root widget from innermost to outermost.
  ///
  /// Example:
  /// ```dart
  /// flutter.runApp((services) => MyApp(
  ///   logger: services.getRequiredService<Logger>(),
  /// ));
  /// ```
  FlutterBuilder runApp(FlutterAppBuilder builder) {
    wrapWith(
      (sp, child) => FlutterLifecycleObserver(
        lifetime:
            sp.getRequiredService<HostApplicationLifetime>()
                as FlutterApplicationLifetime,
        child: child,
      ),
    );

    // Register options infrastructure for FlutterLifetimeOptions
    services.addOptions<FlutterLifetimeOptions>(() => FlutterLifetimeOptions());

    services
      ..addKeyedSingleton<Widget>('rootAppWidget', (sp, key) {
        var factories = sp.getServices<WrappedWidgetFactory>();
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
          sp.getRequiredService<Options<FlutterLifetimeOptions>>(),
          sp.getRequiredService<LoggerFactory>(),
        ),
      );
    return this;
  }

  /// Registers a widget wrapper that will wrap the root application widget.
  ///
  /// Use this to add providers, themes, or other widgets that need to be
  /// ancestors of the root widget. Wrappers are applied in reverse registration
  /// order (last registered becomes outermost).
  ///
  /// The [factory] receives the [ServiceProvider] and the child widget to wrap.
  ///
  /// Example:
  /// ```dart
  /// flutter
  ///   ..wrapWith((sp, child) => ThemeProvider(child: child))
  ///   ..wrapWith((sp, child) => LocalizationProvider(child: child))
  ///   ..runApp((_) => MyApp());
  /// // Result: ThemeProvider(LocalizationProvider(FlutterLifecycleObserver(MyApp())))
  /// ```
  FlutterBuilder wrapWith(WrappedWidgetFactory factory) {
    services.addSingleton<WrappedWidgetFactory>((_) => factory);

    return this;
  }

  /// Configures Flutter lifetime options.
  ///
  /// The [configure] callback receives a [FlutterLifetimeOptions] instance
  /// that can be modified to customize lifetime behavior.
  ///
  /// Example:
  /// ```dart
  /// flutter
  ///   ..configure((options) => options.suppressStatusMessages = true)
  ///   ..runApp((_) => MyApp());
  /// ```
  FlutterBuilder configure(ConfigureFlutterOptions? configure) {
    if (configure != null) {
      services.addSingleton<ConfigureOptions<FlutterLifetimeOptions>>(
        (_) => _ConfigureFlutterLifetimeOptions(configure),
      );
    }
    return this;
  }
}
