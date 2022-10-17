import 'package:extensions/hosting.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'flutter_builder.dart';

const String _versionsKey = 'VersionTracking.Versions';
const String _buildsKey = 'VersionTracking.Builds';

extension VersionInfoServiceCollectionExtensions on FlutterBuilder {
  void addVersionInfo() {
    services
      ..addSingleton<VersionInfo>((services) => VersionInfo())
      ..addHostedService(
        (services) => VersionInfoService(
          services.getRequiredService<VersionInfo>(),
          services
              .getRequiredService<LoggerFactory>()
              .createLogger('VersionInfo'),
        ),
      );
  }
}

class VersionInfoService extends BackgroundService {
  final VersionInfo _versionInfo;
  final Logger _logger;

  VersionInfoService(
    VersionInfo versionInfo,
    Logger logger,
  )   : _versionInfo = versionInfo,
        _logger = logger;

  @override
  Future<void> execute(CancellationToken stoppingToken) async {
    _logger.logTrace('Tracking version information.');
    await _versionInfo.track();
  }
}

class VersionInfo {
  bool? _isFirstLaunchEver;
  bool? _isFirstLaunchForCurrentVersion;
  bool? _isFirstLaunchForCurrentBuild;
  String? _currentVersion;
  String? _currentBuild;
  String? _previousVersion;
  String? _previousBuild;
  String? _firstInstalledVersion;
  String? _firstInstalledBuild;
  List<String>? _versionHistory;
  List<String>? _buildHistory;

  /// Gets a value indicating whether this is the first time this app has ever
  /// been launched on this device.
  bool get isFirstLaunchEver => _isFirstLaunchEver!;

  /// Gets a value indicating if this is the first launch of the app for the
  /// current version number.
  bool get isFirstLaunchForCurrentVersion => _isFirstLaunchForCurrentVersion!;

  /// Gets a value indicating if this is the first launch of the app for the
  /// current build number.
  bool get isFirstLaunchForCurrentBuild => _isFirstLaunchForCurrentBuild!;

  /// Gets the current version number of the app.
  String get currentVersion => _currentVersion!;

  /// Gets the current build of the app.
  String get currentBuild => _currentBuild!;

  /// Gets the version number for the previously run version.
  String get previousVersion => _previousVersion!;

  /// Gets the build number for the previously run version.
  String get previousBuild => _previousBuild!;

  /// Gets the version number of the first version of the app that was
  /// installed on this device.
  String get firstInstalledVersion => _firstInstalledVersion!;

  /// Gets the build number of first version of the app that was installed
  /// on this device.
  String get firstInstalledBuild => _firstInstalledBuild!;

  /// Gets the collection of version numbers of the app that ran on this device.
  List<String> get versionHistory => _versionHistory!;

  /// Gets the collection of build numbers of the app that ran on this device.
  List<String> get buildHistory => _buildHistory!;

  /// Determines if this is the first launch of the app for a specified
  /// version number.
  bool isFirstLaunchForVersion(String version) =>
      currentVersion == version && isFirstLaunchForCurrentVersion;

  /// Determines if this is the first launch of the app for a specified
  /// build number.
  bool isFirstLaunchForBuild(String build) =>
      currentBuild == build && isFirstLaunchForCurrentBuild;

  Future<void> track() async {
    final sharedPreferences = await SharedPreferences.getInstance();

    var versionTrail = <String, List<String>>{};

    var isFirstLaunchEver = !sharedPreferences.containsKey(_versionsKey) ||
        !sharedPreferences.containsKey(_buildsKey);
    if (isFirstLaunchEver) {
      versionTrail.addAll({_versionsKey: <String>[], _buildsKey: <String>[]});
    } else {
      versionTrail.addAll({
        _versionsKey: _readHistory(sharedPreferences, _versionsKey).toList(),
        _buildsKey: _readHistory(sharedPreferences, _buildsKey).toList()
      });
    }

    final packageInfo = await PackageInfo.fromPlatform();

    var currentVersion = packageInfo.version;
    var currentBuild = packageInfo.buildNumber;

    var isFirstLaunchForCurrentVersion =
        !versionTrail[_versionsKey]!.contains(currentVersion);
    if (isFirstLaunchForCurrentVersion) {
      versionTrail[_versionsKey]!.add(currentVersion);
    }

    var isFirstLaunchForCurrentBuild =
        !versionTrail[_buildsKey]!.contains(currentBuild);
    if (isFirstLaunchForCurrentBuild) {
      versionTrail[_buildsKey]!.add(currentBuild);
    }

    if (isFirstLaunchForCurrentVersion || isFirstLaunchForCurrentBuild) {
      await _writeHistory(
          sharedPreferences, _versionsKey, versionTrail[_versionsKey]!);
      await _writeHistory(
          sharedPreferences, _buildsKey, versionTrail[_buildsKey]!);
    }

    _isFirstLaunchEver = isFirstLaunchEver;
    _isFirstLaunchForCurrentVersion = isFirstLaunchForCurrentVersion;
    _isFirstLaunchForCurrentBuild = isFirstLaunchForCurrentBuild;
    _currentVersion = currentVersion;
    _currentBuild = currentBuild;
    _previousVersion = _getPrevious(versionTrail, _versionsKey);
    _previousBuild = _getPrevious(versionTrail, _buildsKey);
    _firstInstalledVersion = versionTrail[_versionsKey]!.first;
    _firstInstalledBuild = versionTrail[_buildsKey]!.first;
    _versionHistory = versionTrail[_versionsKey]!.toList();
    _buildHistory = versionTrail[_buildsKey]!.toList();
  }

  List<String> _readHistory(
    SharedPreferences preferences,
    String key,
  ) =>
      preferences.getString(key)!.split('|');

  Future<void> _writeHistory(
    SharedPreferences preferences,
    String key,
    List<String> history,
  ) async =>
      await preferences.setString(key, history.join('|'));

  String? _getPrevious(
    Map<String, List<String>> versionTrail,
    String key,
  ) {
    var trail = versionTrail[key];
    return (trail!.length >= 2) ? trail[trail.length - 2] : null;
  }
}
