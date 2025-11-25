import 'dart:collection';
import 'dart:io' show Platform;

import '../../configuration_path.dart';
import '../../configuration_provider.dart';

class EnvironmentVariablesConfigurationProvider extends ConfigurationProvider
    with ConfigurationProviderMixin {
  final String _prefix;

  EnvironmentVariablesConfigurationProvider([String? prefix])
      : _prefix = prefix ?? '';

  @override
  void load() => loadInternal(Platform.environment);

  void loadInternal(Map<dynamic, dynamic> envVariables) {
    var data = LinkedHashMap<String, String>(
      equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
      hashCode: (k) => k.toLowerCase().hashCode,
    );
    var e = envVariables.entries.iterator;

    try {
      while (e.moveNext()) {
        var entry = e.current;
        var key = entry.key as String;

        if (key.toLowerCase().startsWith(_prefix.toLowerCase())) {
          // Strip the prefix and normalize the key
          key = normalizeKey(key.substring(_prefix.length));
          data[key] = entry.value as String;
        }
        // Note: In .NET, environment variables without the prefix are ignored
        // when a prefix is specified. The else block for ConnectionStrings
        // was incorrectly trying to strip a prefix that doesn't exist.
      }
    } finally {}

    this.data = data;
  }

  static String normalizeKey(String key) =>
      key.replaceAll('__', ConfigurationPath.keyDelimiter);
}
