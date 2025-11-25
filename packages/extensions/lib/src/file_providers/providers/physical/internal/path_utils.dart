import 'package:path/path.dart' as p;
import '../../../../system/string.dart' as string;

void main() {
  print(PathUtils.ensureTrailingSlash('c:\\test'));
}

class PathUtils {
  static String ensureTrailingSlash(String path) {
    if (!string.isNullOrEmpty(path) &&
        path.substring(path.length - 1) != p.separator) {
      return path + p.separator;
    }

    return path;
  }

  static bool pathNavigatesAboveRoot(String path) {
    var items = path.split(p.separator);

    var depth = 0;

    for (var item in items) {
      if (item == '.' || item.isEmpty) {
        continue;
      } else if (item == '..') {
        depth--;

        if (depth == -1) {
          return true;
        }
      } else {
        depth++;
      }
    }

    return false;
  }
}
