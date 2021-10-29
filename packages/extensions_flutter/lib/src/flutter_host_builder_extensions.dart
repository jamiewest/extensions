import 'package:extensions/hosting.dart';
import 'package:flutter/widgets.dart';

import 'flutter_lifetime_options.dart';
import 'flutter_service_collection_extensions.dart';

extension FlutterHostBuilderExtensions on HostBuilder {
  HostBuilder useFlutterLifetime(
    Widget app,
    FlutterLifetimeOptions options,
  ) {
    configureServices((context, services) => services.addFlutter(app, options));
    return this;
  }
}
