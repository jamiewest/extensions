import 'package:extensions/hosting.dart';

import 'flutter_app.dart';
import 'flutter_app_options.dart';
import 'flutter_builder.dart';
import 'flutter_hosting_environment.dart';
import 'flutter_service_collection_extensions.dart';

class FlutterAppBuilder {
  late final HostApplicationBuilder _hostApplicationBuilder;
  late final FlutterBuilder _flutterBuilder;

  FlutterAppBuilder([FlutterAppOptions? options]) {
    final configuration = ConfigurationManager();

    options ??= FlutterAppOptions();

    _hostApplicationBuilder = HostApplicationBuilder(
      settings: HostApplicationBuilderSettings(
        applicationName: options.applicationName,
        environmentName: options.environmentName,
        configuration: configuration,
      ),
    )..services.addFlutter();

    _flutterBuilder = FlutterBuilder(_hostApplicationBuilder.services);
  }

  FlutterHostingEnvironment get environment =>
      _hostApplicationBuilder.environment as FlutterHostingEnvironment;

  ServiceCollection get services => _hostApplicationBuilder.services;

  ConfigurationManager get configuration =>
      _hostApplicationBuilder.configuration;

  LoggingBuilder get logging => _hostApplicationBuilder.logging;

  FlutterBuilder get flutter => _flutterBuilder;

  FlutterApp build() => FlutterApp(
        _hostApplicationBuilder.build(),
      );
}
