import 'configuration_provider.dart';
import 'configuration_root.dart';
import 'configuration_section.dart';

/// Extension methods for [ConfigurationRoot].
extension ConfigurationRootExtensions on ConfigurationRoot {
  String getDebugView() {
    void recurseChildren(
      StringBuffer stringBuffer,
      Iterable<ConfigurationSection> children,
      String indent,
    ) {
      for (var child in children) {
        var (key, provider) = _getValueAndProvider(this, child.path);

        if (provider != null) {
          stringBuffer
            ..write(indent)
            ..write(child.key)
            ..write('=')
            ..write(key)
            ..write(' (')
            ..write(provider)
            ..writeln(')');
        } else {
          stringBuffer
            ..write(indent)
            ..write(child.key)
            ..writeln(':');
        }

        recurseChildren(stringBuffer, child.getChildren(), '$indent  ');
      }
    }

    var builder = StringBuffer();
    recurseChildren(builder, getChildren(), '');

    return builder.toString();
  }

  (String? key, ConfigurationProvider? provider) _getValueAndProvider(
    ConfigurationRoot root,
    String key,
  ) {
    for (var provider in root.providers.toList().reversed) {
      var value = provider.tryGet(key);
      if (value.$1 == true) {
        return (value.$2 as String, provider);
      }
    }

    return (null, null);
  }

  //   Tuple2<String?, ConfigurationProvider?> _getValueAndProvider(
  //   ConfigurationRoot root,
  //   String key,
  // ) {
  //   for (var provider in root.providers.toList().reversed) {
  //     var value = provider.tryGet(key);
  //     if (value[0] == true) {
  //       return Tuple2<String, ConfigurationProvider>(
  //           value[1] as String, provider);
  //     }
  //   }

  //   return const Tuple2<String?, ConfigurationProvider?>(null, null);
  // }
}
