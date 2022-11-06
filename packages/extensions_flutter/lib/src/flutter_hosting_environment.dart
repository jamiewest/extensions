import 'package:extensions/hosting.dart';
import 'package:flutter/foundation.dart';

class FlutterHostingEnvironment extends HostingEnvironment {
  @override
  String get environmentName =>
      buildMode == 'Release' ? 'Production' : 'Development';
}

extension HostingEnvironmentExtensions on HostingEnvironment {
  String get buildMode {
    if (kReleaseMode) return 'Release';
    if (kProfileMode) return 'Profile';
    if (kDebugMode) return 'Debug';
    return 'Unknown';
  }
}
