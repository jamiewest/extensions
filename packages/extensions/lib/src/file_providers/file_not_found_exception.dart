class FileNotFoundException implements Exception {
  FileNotFoundException(String name) : _name = name;
  final String _name;

  // TODO(jamiewest): test.
  @override
  String toString() => 'The file $_name does not exist.';
}

class Test {
  static bool hi = true;

  static String yes = 'test';
}
