import 'package:extensions_flutter/extensions_flutter.dart';

import 'firebase_builder.dart';
import 'firebase_builder_options.dart';

typedef ConfigureFirebaseBuilder = void Function(FirebaseBuilder builder);

extension FlutterBuilderExtensions on FlutterBuilder {
  FirebaseBuilder configureFirebase(FirebaseBuilderOptions options) {
    services.tryAddIterable(
      ServiceDescriptor.singletonInstance<
          ConfigureOptions<FirebaseBuilderOptions>>(options),
    );

    final builder = FirebaseBuilder(services);
    return builder;
  }
}
