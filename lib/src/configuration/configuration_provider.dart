import 'dart:collection';

import '../primitives/change_token.dart';
import 'configuration_key_comparator.dart';
import 'configuration_path.dart';
import 'configuration_reload_token.dart';

/// Provides configuration key/values for an application.
abstract class ConfigurationProvider {
  /// Tries to get a configuration value for the specified key.
  ///
  /// List[0] will return true if a value is found for the specified key.
  /// List[1] will contain the value if List[0] is not false.
  List<dynamic> tryGet(String key);

  /// Sets a configuration value for the specified key.
  void set(String key, String value);

  /// Returns a change token if this provider supports change
  /// tracking, null otherwise.
  ChangeToken getReloadToken();

  /// Loads configuration values from the source represented
  /// by this [ConfigurationProvider].
  void load();

  /// Returns the immediate descendant configuration keys for a
  /// given parent path based on this [ConfigurationProvider]s
  /// data and the set of keys returned by all the preceding
  /// [ConfigurationProvider]s.
  Iterable<String> getChildKeys(
    Iterable<String> earlierKeys,
    String? parentPath,
  );
}

/// Provides configuration key/values for an application.
mixin ConfigurationProviderMixin on ConfigurationProvider {
  ConfigurationReloadToken _reloadToken = ConfigurationReloadToken();

  /// The configuration key value pairs for this provider.
  LinkedHashMap<String, String?> data = LinkedHashMap<String, String?>(
    equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
    hashCode: (k) => k.toLowerCase().hashCode,
  );

  // ConfigurationProvider()
  //     : _reloadToken = ConfigurationReloadToken(),
  //       data = LinkedHashMap<String, String?>(
  //         equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
  //         hashCode: (k) => k.toLowerCase().hashCode,
  //       );

  // /// The configuration key value pairs for this provider.
  // /// TODO: Make this internal.
  // LinkedHashMap<String, String?> data;

  @override
  List<dynamic> tryGet(String key) {
    if (data.containsKey(key)) {
      return [true, data[key]];
    }
    return [false];
  }

  /// Sets a value for a given key.
  @override
  void set(String key, String value) => data[key] = value;

  /// Returns a [ChangeToken] that can be used to listen when this provider
  /// is reloaded.
  @override
  ChangeToken getReloadToken() => _reloadToken;

  // /// Loads (or reloads) the data for this provider.
  @override
  void load() {}

  /// Returns the list of keys that this provider has.
  @override
  Iterable<String> getChildKeys(
    Iterable<String> earlierKeys,
    String? parentPath,
  ) {
    var results = <String>[];
    if (parentPath == null) {
      data.forEach((key, value) {
        results.add(_segment(key, 0));
      });
    } else {
      assert(ConfigurationPath.keyDelimiter == ':');
      data.forEach((key, value) {
        if ((key.length > parentPath.length) &&
            key.toLowerCase().startsWith(parentPath.toLowerCase()) &&
            key[parentPath.length] == ':') {
          results.add(_segment(key, parentPath.length + 1));
        }
      });
    }

    results.addAll(earlierKeys);
    return results..sort(configurationKeyComparator);
  }

  String _segment(String key, int prefixLength) {
    var indexOf = key.indexOf(ConfigurationPath.keyDelimiter, prefixLength);
    return indexOf < 0
        ? key.substring(prefixLength)
        : key.substring(prefixLength, indexOf); // Was indexOf - prefixLength
  }

  /// Triggers the reload change token and creates a new one.
  void onReload() {
    _reloadToken.onReload();
    _reloadToken = ConfigurationReloadToken();
  }

  /// Generates a string representing this provider name and relevant details.
  @override
  String toString() => runtimeType.toString();
}

// mixin ConfigurationProviderHelper on ConfigurationProvider {
//   final ConfigurationReloadToken _reloadToken = ConfigurationReloadToken();

//   /// The configuration key value pairs for this provider.
//   LinkedHashMap<String, String?> data = LinkedHashMap<String, String?>(
//     equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
//     hashCode: (k) => k.toLowerCase().hashCode,
//   );

//   @override
//   List<dynamic> tryGet(String key) {
//     if (data.containsKey(key)) {
//       return [true, data[key]];
//     }
//     return [false];
//   }

//   /// Sets a value for a given key.
//   @override
//   void set(String key, String value) => data[key] = value;

//   /// Returns the list of keys that this provider has.
//   @override
//   Iterable<String> getChildKeys(
//     Iterable<String> earlierKeys,
//     String? parentPath,
//   ) {
//     var results = <String>[];
//     if (parentPath == null) {
//       data.forEach((key, value) {
//         results.add(_segment(key, 0));
//       });
//     } else {
//       assert(ConfigurationPath.keyDelimiter == ':');
//       data.forEach((key, value) {
//         if ((key.length > parentPath.length) &&
//             key.toLowerCase().startsWith(parentPath.toLowerCase()) &&
//             key[parentPath.length] == ':') {
//           results.add(_segment(key, parentPath.length + 1));
//         }
//       });
//     }

//     results.addAll(earlierKeys);
//     return results..sort(configurationKeyComparator);
//   }

//   @override
//   ChangeToken getReloadToken() => _reloadToken;

//   @override
//   void load() {}

//   String _segment(String key, int prefixLength) {
//     var indexOf = key.indexOf(ConfigurationPath.keyDelimiter, prefixLength);
//     return indexOf < 0
//         ? key.substring(prefixLength)
//         : key.substring(prefixLength, indexOf); // Was indexOf - prefixLength
//   }
// }
