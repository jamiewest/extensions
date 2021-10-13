class FileNotFoundException implements Exception {
  final String _name;

  FileNotFoundException(String name) : _name = name;

  @override
  String toString() => 'The file $_name does not exist.';
}
