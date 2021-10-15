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

  void loadInternal(Map envVariables) {
    var data = LinkedHashMap<String, String>(
      equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
      hashCode: (k) => k.toLowerCase().hashCode,
    );
    var e = envVariables.entries.iterator;

    try {
      while (e.moveNext()) {
        var entry = e.current;
        var key = entry.key as String;
        String? provider;
        //String? prefix;

        if (key.toLowerCase().startsWith(_prefix.toLowerCase())) {
          // This prevents the prefix from being normalized.
          // We can also do a fast path branch,
          // I guess? No point in reallocating if the prefix is empty.
          key = normalizeKey(key.substring(_prefix.length));
          data[key] = entry.value as String;

          continue;
        } else {
          // Add the key-value pair for connection string, and
          // optionally provider name
          key = normalizeKey(key.substring(_prefix.length));
          _addIfPrefixed(data, 'ConnectionStrings:$key', entry.value as String);
          if (provider != null) {
            _addIfPrefixed(
                data, 'ConnectionStrings:${key}_ProviderName', provider);
          }
        }
      }
    } finally {}

    this.data = data;
  }

  void _addIfPrefixed(Map<String, String?> data, String key, String value) {
    if (key.toLowerCase().startsWith(_prefix.toLowerCase())) {
      key = key.substring(_prefix.length);
      data[key] = value;
    }
  }

  static String normalizeKey(String key) =>
      key.replaceAll('__', ConfigurationPath.keyDelimiter);
}
