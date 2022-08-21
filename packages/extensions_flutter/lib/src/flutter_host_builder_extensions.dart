import 'package:extensions/hosting.dart';
import 'package:flutter/widgets.dart';

import 'flutter_lifetime_options.dart';
import 'flutter_service_collection_extensions.dart';

// extension FlutterHostBuilderExtensions on HostBuilder {
//   HostBuilder useFlutterLifetime(
//     Widget app, {
//     FlutterLifetimeOptions? options,
//   }) {
//     configureServices((context, services) {
//       services.addFlutter(app, options: options);
//     });
//     return this;
//   }

//   /// Enables Flutter support and builds and starts the host.
//   Future<void> runFlutter(
//     Widget app, {
//     FlutterLifetimeOptions? options,
//     CancellationToken? cancellationToken,
//   }) =>
//       useFlutterLifetime(
//         app,
//         options: options,
//       ).build().run(cancellationToken);
// }
