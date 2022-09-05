import 'package:extensions_flutter_plugins/extensions_flutter_plugins.dart';
import 'package:package_info_plus/package_info_plus.dart';

extension PackageInfoFlutterBuilderExtensions on FlutterBuilder {}

class PackageInfoService extends BackgroundService {
  final Logger _logger;

  PackageInfoService(Logger logger) : _logger = logger;

  PackageInfo? packageInfo;

  @override
  Future<void> execute(CancellationToken stoppingToken) async {
    _logger.logTrace('PackageInfoService is starting...');
    packageInfo = await PackageInfo.fromPlatform();
  }
}
