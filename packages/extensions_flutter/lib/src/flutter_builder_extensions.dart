import 'package:extensions/hosting.dart';
import 'package:flutter/widgets.dart';

import 'flutter_builder.dart';

extension FlutterBuilderExtensions on FlutterBuilder {
  FlutterBuilder useApp(Widget app) {
    services.addSingletonInstance<Widget>(app);
    return this;
  }
}
