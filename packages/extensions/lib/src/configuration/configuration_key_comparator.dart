import 'dart:math';

import 'configuration_path.dart';

int configurationKeyComparator(String? x, String? y) {
  var xParts = x?.split(ConfigurationPath.keyDelimiter) ?? List<String>.empty();
  var yParts = y?.split(ConfigurationPath.keyDelimiter) ?? List<String>.empty();

  // Compare each part until we get two parts that are not equal
  for (var i = 0; i < min(xParts.length, yParts.length); i++) {
    x = xParts[i];
    y = yParts[i];

    var value1 = int.tryParse(x);
    var value2 = int.tryParse(y);

    var xIsInt = value1 != null;
    var yIsInt = value2 != null;

    int result;
    if (!xIsInt && !yIsInt) {
      // Both are strings
      result = x.toLowerCase().compareTo(y.toLowerCase());
    } else if (xIsInt && yIsInt) {
      result = value1 - value2;
    } else {
      // Only one of them is int
      result = xIsInt ? -1 : 1;
    }
    if (result != 0) {
      // One of them is different
      return result;
    }
  }

  // If we get here, the common parts are equal.
  // If they are of the same length, then they are totally identical
  return xParts.length - yParts.length;
}
