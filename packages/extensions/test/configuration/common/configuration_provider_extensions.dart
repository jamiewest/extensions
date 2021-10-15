import 'package:extensions/src/configuration/configuration_provider.dart';

extension ConfigurationProviderExtensions on ConfigurationProvider {
  String get(String key) {
    var result = tryGet(key);
    if (result[0] as bool == false) {
      throw Exception('Key not found');
    }

    return result[1] as String;
  }
}
