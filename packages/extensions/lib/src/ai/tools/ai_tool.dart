import '../additional_properties_dictionary.dart';

/// Base class for tools that can be provided to an AI model.
abstract class AITool {
  /// Creates a new [AITool].
  AITool({String? name, this.description}) : name = name ?? 'AITool';

  /// The name of the tool.
  final String name;

  /// A description of the tool.
  final String? description;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Gets a service of the specified type.
  T? getService<T>({Object? key}) => null;

  @override
  String toString() => name;
}
