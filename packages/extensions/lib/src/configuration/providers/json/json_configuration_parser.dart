import 'dart:convert';

import 'package:collection/collection.dart';

import '../../configuration_path.dart';

class JsonConfigurationParser {
  final Map<String, String?> _data = <String, String?>{};
  final QueueList<String> _paths = QueueList<String>();

  static Map<String, String?> parse(String input) =>
      JsonConfigurationParser()._parse(input);

  static Future<Map<String, String?>> parseStream(
    Stream<dynamic> input,
  ) async =>
      JsonConfigurationParser()._parseStream(input);

  Map<String, String?> _parse(String input) {
    final rootElement = jsonDecode(input);

    _visitMapElement(rootElement as Map<String, dynamic>);

    return _data;
  }

  Future<Map<String, String?>> _parseStream(Stream<dynamic> input) async {
    final json = await input.last as String;

    return _parse(json);
  }

  void _visitMapElement(Map<String, dynamic> element) {
    var isEmpty = true;

    for (var property in element.entries) {
      isEmpty = false;
      _enterContext(property.key);
      _visitValue(property.value);
      _exitContext();
    }

    _setNullIfElementIsEmpty(isEmpty);
  }

  void _visitListElement(List<dynamic> element) {
    var index = 0;
    for (var listElement in element) {
      _enterContext(index.toString());
      _visitValue(listElement);
      _exitContext();
      index++;
    }

    _setNullIfElementIsEmpty(index == 0);
  }

  void _setNullIfElementIsEmpty(bool isEmpty) {
    if (isEmpty && _paths.isNotEmpty) {
      _data[_paths.last] = null;
    }
  }

  void _visitValue(dynamic value) {
    assert(_paths.isNotEmpty);

    if (value is Map<String, dynamic>) {
      _visitMapElement(value);
      return;
    }

    if (value is List) {
      _visitListElement(value);
      return;
    }

    var key = _paths.last;
    if (_data.containsKey(key)) {
      // throw an error
    }
    _data[key] = value.toString();
    return;
  }

  void _enterContext(String context) => _paths.add(
        _paths.isNotEmpty
            ? _paths.last + ConfigurationPath.keyDelimiter + context
            : context,
      );

  void _exitContext() => _paths.removeLast();
}
