import 'package:tuple/tuple.dart';

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
        var valueAndProvider = _getValueAndProvider(this, child.path);

        if (valueAndProvider.item2 != null) {
          stringBuffer
            ..write(indent)
            ..write(child.key)
            ..write('=')
            ..write(valueAndProvider.item1)
            ..write(' (')
            ..write(valueAndProvider.item2)
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

  Tuple2<String?, ConfigurationProvider?> _getValueAndProvider(
    ConfigurationRoot root,
    String key,
  ) {
    for (var provider in root.providers.toList().reversed) {
      var value = provider.tryGet(key);
      if (value[0] == true) {
        return Tuple2<String, ConfigurationProvider>(
            value[1] as String, provider);
      }
    }

    return const Tuple2<String?, ConfigurationProvider?>(null, null);
  }
}
