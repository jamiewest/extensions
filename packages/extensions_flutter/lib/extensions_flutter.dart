/// To use, import `package:extensions_flutter/extensions_flutter.dart`
library extensions_flutter;

import 'package:extensions/hosting.dart';
import 'package:flutter/widgets.dart';

import 'src/flutter_host_builder_extensions.dart';
import 'src/flutter_lifetime_options.dart';

export 'package:extensions/hosting.dart';

export 'src/flutter_application_lifetime.dart';
export 'src/flutter_host_builder_extensions.dart';
export 'src/flutter_host_extensions.dart';
export 'src/flutter_hosting_environment.dart';
export 'src/flutter_lifecycle_observer.dart';
export 'src/flutter_lifetime.dart';
export 'src/flutter_lifetime_options.dart';

HostBuilder createDefaultBuilder(
  Widget app, {
  ErrorHandler? errorHandler,
  FlutterErrorHandler? flutterErrorHandler,
  void Function(ServiceCollection)? services,
  void Function(ConfigurationBuilder)? configuration,
  void Function(LoggingBuilder)? logging,
  void Function(HostingEnvironment)? environment,
}) {
  final builder = HostBuilder()
    ..useFlutterLifetime(
      (options) => options
        ..application = app
        ..errorHandler = errorHandler
        ..flutterErrorHandler = flutterErrorHandler,
    ).configureServices(
      (context, collection) {
        if (services != null) {
          services(collection);
        }
      },
    ).configureLogging(
      (context, config) {
        config.addDebug();
        if (logging != null) {
          logging(config);
        }
      },
    ).configureAppConfiguration(
      (context, config) {
        if (configuration != null) {
          configuration(config);
        }
      },
    );

  return builder;
}
