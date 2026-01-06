import '../../file_providers/file_provider.dart';

import '../host_environment.dart';

const String _emptyString = '';

class HostingEnvironment implements HostEnvironment {
  @override
  String applicationName = _emptyString;

  @override
  String contentRootPath = _emptyString;

  @override
  String environmentName = _emptyString;

  @override
  FileProvider? contentRootFileProvider;
}
