import 'package:extensions/hosting.dart';
import 'package:extensions_flutter/src/flutter_lifetime_options.dart';
import 'package:extensions_flutter/src/flutter_service_collection_extensions.dart';
import 'package:flutter/widgets.dart';

extension FlutterHostBuilderExtensions on HostBuilder {
  HostBuilder useFlutterLifetime(
    Widget app,
    FlutterLifetimeOptions options,
  ) {
    configureServices((context, services) => services.addFlutter(app, options));
    return this;
  }
}
