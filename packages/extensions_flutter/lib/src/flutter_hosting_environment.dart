import 'package:extensions/hosting.dart';
import 'package:flutter/foundation.dart';

class FlutterHostingEnvironment extends HostingEnvironment {
  @override
  String get environmentName {
    switch (buildMode) {
      case 'Release':
        return 'Production';
      case 'Profile':
        return 'Development';
      case 'Debug':
        return 'Development';
      default:
        return 'Development';
    }
  }

  String get buildMode {
    if (kReleaseMode) return 'Release';
    if (kProfileMode) return 'Profile';
    if (kDebugMode) return 'Debug';
    return 'Unknown';
  }
}
