import 'package:extensions/hosting.dart';

import 'flutter_lifetime_options.dart';
import 'flutter_service_collection_extensions.dart';

extension FlutterHostBuilderExtensions on HostBuilder {
  HostBuilder useFlutterLifetime(
    RootWidgetFactory app,
    FlutterLifetimeOptions options,
  ) {
    configureServices((context, services) => services.addFlutter(app, options));
    return this;
  }
}
