import 'package:extensions/hosting.dart';
import 'package:flutter/widgets.dart';

import 'flutter_app_builder.dart';
import 'flutter_app_options.dart';
import 'flutter_application_lifetime.dart';
import 'flutter_builder_extensions.dart';
import 'flutter_hosting_environment.dart';
import 'flutter_lifetime_options.dart';
import 'version_info.dart';

class FlutterApp implements Host, AsyncDisposable {
  final Host _host;
  late final Logger _logger;

  FlutterApp(Host host) : _host = host {
    _logger = host.services
        .getRequiredService<LoggerFactory>()
        .createLogger(environment.applicationName);
  }

  /// The application's configured services.
  @override
  ServiceProvider get services => _host.services;

  /// The application's configured [Configuration].
  Configuration get configuration =>
      _host.services.getRequiredService<Configuration>();

  /// The application's configured [HostEnvironment].
  FlutterHostingEnvironment get environment =>
      _host.services.getRequiredService<FlutterHostingEnvironment>();

  /// Allows consumers to be notified of application lifetime events.
  FlutterApplicationLifetime get lifetime =>
      _host.services.getRequiredService<FlutterApplicationLifetime>();

  /// The default logger for the application.
  Logger get logger => _logger;

  @override
  Future<void> start([CancellationToken? cancellationToken]) =>
      _host.start(cancellationToken);

  @override
  Future<void> stop([CancellationToken? cancellationToken]) =>
      _host.stop(cancellationToken);

  @override
  void dispose() => _host.dispose();

  @override
  Future<void> disposeAsync() => _host.disposeAsync();

  static FlutterApp create({
    required Widget app,
    String? applicationName,
    String? environmentName,
    String? version,
    bool enableVersionTracking = false,
    ErrorHandler? errorHandler,
    FlutterErrorHandler? flutterErrorHandler,
    void Function(ServiceCollection)? services,
    void Function(ConfigurationManager)? configuration,
    void Function(LoggingBuilder)? logging,
    void Function(FlutterHostingEnvironment)? environment,
  }) {
    final builder = FlutterAppBuilder(
      FlutterAppOptions(
        applicationName: applicationName,
        environmentName: environmentName,
      ),
    );

    if (enableVersionTracking) {
      builder.flutter.addVersionInfo();
    }

    if (services != null) services(builder.services);
    if (configuration != null) configuration(builder.configuration);
    if (logging != null) logging(builder.logging);
    if (environment != null) environment(builder.environment);

    builder.flutter.runApp(app);

    return builder.build();
  }

  static FlutterAppBuilder createBuilder() => FlutterAppBuilder();
}
