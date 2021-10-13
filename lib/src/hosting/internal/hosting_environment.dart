import '../../file_providers/file_provider.dart';

import '../host_environment.dart';

class HostingEnvironment implements HostEnvironment {
  @override
  String? applicationName;

  @override
  String? contentRootPath;

  @override
  String? environmentName;

  @override
  FileProvider? contentRootFileProvider;
}
