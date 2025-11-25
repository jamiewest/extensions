import 'package:extensions/src/configuration/configuration_provider.dart';

extension ConfigurationProviderExtensions on ConfigurationProvider {
  String get(String key) {
    var result = tryGet(key);
    if (result.$1 == false) {
      throw Exception('Key not found');
    }

    return result.$2 as String;
  }
}
