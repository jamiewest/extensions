import 'package:extensions/hosting.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'version_info.dart';

class FlutterHostingEnvironment extends HostingEnvironment
    implements HostedService {
  late final String _buildMode;
  VersionInfo? _versionInfo;

  FlutterHostingEnvironment() {
    if (kReleaseMode) _buildMode = 'Release';
    if (kProfileMode) _buildMode = 'Profile';
    if (kDebugMode) _buildMode = 'Debug';
  }

  @override
  String get environmentName {
    switch (_buildMode) {
      case 'Release':
        return 'Production';
      case 'Debug':
        return 'Development';
      default:
        return 'Development';
    }
  }

  String get buildMode => _buildMode;

  VersionInfo? get version => _versionInfo;

  @override
  Future<void> start(CancellationToken cancellationToken) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final info = packageInfo;
    applicationName = info.appName;

    final sharedPreferences = await SharedPreferences.getInstance();

    _versionInfo = VersionInfo(
      packageInfo: packageInfo,
      sharedPreferences: sharedPreferences,
    );

    await _versionInfo!.track();
  }

  @override
  Future<void> stop(CancellationToken cancellationToken) => Future.value();
}
