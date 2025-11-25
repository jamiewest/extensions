import 'dart:collection';

import 'package:xml/xml.dart';

import '../../configuration_path.dart';

/// Parses XML configuration data into key-value pairs.
class XmlConfigurationParser {
  XmlConfigurationParser._();

  /// Parses XML content from the input string and returns a dictionary of
  /// configuration key-value pairs.
  ///
  /// The method processes XML elements and attributes:
  /// - Element hierarchies create colon-delimited keys
  /// - Attributes become key-value pairs
  /// - The 'Name' attribute creates a hierarchical level
  /// - Repeated elements are indexed numerically (0, 1, 2, ...)
  /// - Empty elements map to empty strings
  ///
  /// Throws [FormatException] if:
  /// - A duplicate key is encountered
  /// - XML namespaces are used
  static Map<String, String?> parse(String input) {
    final data = LinkedHashMap<String, String?>(
      equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
      hashCode: (k) => k.toLowerCase().hashCode,
    );

    final document = XmlDocument.parse(input);

    // Process the root element
    _processElement(document.rootElement, '', data);

    return data;
  }

  static void _processElement(
    XmlElement element,
    String prefix,
    Map<String, String?> data,
  ) {
    // Check for namespaces
    if (element.name.namespaceUri != null &&
        element.name.namespaceUri!.isNotEmpty) {
      throw FormatException(
        'XML namespaces are not supported. '
        'Element: ${element.name.qualified}',
      );
    }

    // Build the current prefix
    var currentPrefix = prefix.isEmpty
        ? element.name.local
        : ConfigurationPath.combine([prefix, element.name.local]);

    // Check if this element has a 'Name' attribute (case-insensitive)
    String? nameAttrValue;
    for (final attr in element.attributes) {
      if (attr.name.local.toLowerCase() == 'name') {
        nameAttrValue = attr.value;
        break;
      }
    }

    // If 'Name' attribute exists, add it to the prefix
    if (nameAttrValue != null && nameAttrValue.isNotEmpty) {
      currentPrefix = ConfigurationPath.combine([currentPrefix, nameAttrValue]);
    }

    // Process attributes (excluding 'Name' attribute)
    for (final attr in element.attributes) {
      // Check for namespace
      if (attr.name.namespaceUri != null &&
          attr.name.namespaceUri!.isNotEmpty) {
        throw FormatException(
          'XML namespaces are not supported. '
          'Attribute: ${attr.name.qualified}',
        );
      }

      // Skip 'Name' attribute as it's used for hierarchy
      if (attr.name.local.toLowerCase() == 'name') {
        continue;
      }

      final attrKey =
          ConfigurationPath.combine([currentPrefix, attr.name.local]);

      if (data.containsKey(attrKey)) {
        throw FormatException('Duplicate key: $attrKey');
      }

      data[attrKey] = attr.value;
    }

    // Collect child elements and text content
    final childElements = <XmlElement>[];
    final textParts = <String>[];

    for (final node in element.children) {
      if (node is XmlElement) {
        childElements.add(node);
      } else if (node is XmlText || node is XmlCDATA) {
        final text = node.value?.trim() ?? '';
        if (text.isNotEmpty) {
          textParts.add(text);
        }
      }
    }

    // If there's text content, add it as the element's value
    if (textParts.isNotEmpty) {
      final textValue = textParts.join(' ');
      if (data.containsKey(currentPrefix)) {
        throw FormatException('Duplicate key: $currentPrefix');
      }
      data[currentPrefix] = textValue;
    } else if (childElements.isEmpty && element.attributes.isEmpty) {
      // Empty element with no attributes or children
      if (data.containsKey(currentPrefix)) {
        throw FormatException('Duplicate key: $currentPrefix');
      }
      data[currentPrefix] = '';
    }

    // Group child elements by name (case-insensitive)
    final childGroups = LinkedHashMap<String, List<XmlElement>>(
      equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
      hashCode: (k) => k.toLowerCase().hashCode,
    );

    for (final child in childElements) {
      final childName = child.name.local;
      childGroups.putIfAbsent(childName, () => []).add(child);
    }

    // Process child elements
    for (final entry in childGroups.entries) {
      final childName = entry.key;
      final children = entry.value;

      if (children.length == 1) {
        // Single child - process normally
        _processElement(children[0], currentPrefix, data);
      } else {
        // Multiple children with same name - add indices AFTER element name
        for (var i = 0; i < children.length; i++) {
          // Build prefix with element name first, then index
          final childElementPrefix =
              ConfigurationPath.combine([currentPrefix, childName]);
          final indexedPrefix =
              ConfigurationPath.combine([childElementPrefix, i.toString()]);

          // Process the element's content and children with the indexed prefix
          _processElementContent(children[i], indexedPrefix, data);
        }
      }
    }
  }

  static void _processElementContent(
    XmlElement element,
    String prefix,
    Map<String, String?> data,
  ) {
    // Check for namespaces
    if (element.name.namespaceUri != null &&
        element.name.namespaceUri!.isNotEmpty) {
      throw FormatException(
        'XML namespaces are not supported. '
        'Element: ${element.name.qualified}',
      );
    }

    // Check if this element has a 'Name' attribute (case-insensitive)
    String? nameAttrValue;
    for (final attr in element.attributes) {
      if (attr.name.local.toLowerCase() == 'name') {
        nameAttrValue = attr.value;
        break;
      }
    }

    // If 'Name' attribute exists, add it to the prefix
    var currentPrefix = prefix;
    if (nameAttrValue != null && nameAttrValue.isNotEmpty) {
      currentPrefix = ConfigurationPath.combine([currentPrefix, nameAttrValue]);
    }

    // Process attributes (excluding 'Name' attribute)
    for (final attr in element.attributes) {
      // Check for namespace
      if (attr.name.namespaceUri != null &&
          attr.name.namespaceUri!.isNotEmpty) {
        throw FormatException(
          'XML namespaces are not supported. '
          'Attribute: ${attr.name.qualified}',
        );
      }

      // Skip 'Name' attribute as it's used for hierarchy
      if (attr.name.local.toLowerCase() == 'name') {
        continue;
      }

      final attrKey =
          ConfigurationPath.combine([currentPrefix, attr.name.local]);

      if (data.containsKey(attrKey)) {
        throw FormatException('Duplicate key: $attrKey');
      }

      data[attrKey] = attr.value;
    }

    // Collect child elements and text content
    final childElements = <XmlElement>[];
    final textParts = <String>[];

    for (final node in element.children) {
      if (node is XmlElement) {
        childElements.add(node);
      } else if (node is XmlText || node is XmlCDATA) {
        final text = node.value?.trim() ?? '';
        if (text.isNotEmpty) {
          textParts.add(text);
        }
      }
    }

    // If there's text content, add it as the element's value
    if (textParts.isNotEmpty) {
      final textValue = textParts.join(' ');
      if (data.containsKey(currentPrefix)) {
        throw FormatException('Duplicate key: $currentPrefix');
      }
      data[currentPrefix] = textValue;
    } else if (childElements.isEmpty && element.attributes.isEmpty) {
      // Empty element with no attributes or children
      if (data.containsKey(currentPrefix)) {
        throw FormatException('Duplicate key: $currentPrefix');
      }
      data[currentPrefix] = '';
    }

    // Group child elements by name (case-insensitive)
    final childGroups = LinkedHashMap<String, List<XmlElement>>(
      equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
      hashCode: (k) => k.toLowerCase().hashCode,
    );

    for (final child in childElements) {
      final childName = child.name.local;
      childGroups.putIfAbsent(childName, () => []).add(child);
    }

    // Process child elements
    for (final entry in childGroups.entries) {
      final childName = entry.key;
      final children = entry.value;

      if (children.length == 1) {
        // Single child - process normally
        _processElement(children[0], currentPrefix, data);
      } else {
        // Multiple children with same name - add indices AFTER element name
        for (var i = 0; i < children.length; i++) {
          // Build prefix with element name first, then index
          final childElementPrefix =
              ConfigurationPath.combine([currentPrefix, childName]);
          final indexedPrefix =
              ConfigurationPath.combine([childElementPrefix, i.toString()]);

          // Process the element's content and children with the indexed prefix
          _processElementContent(children[i], indexedPrefix, data);
        }
      }
    }
  }
}
