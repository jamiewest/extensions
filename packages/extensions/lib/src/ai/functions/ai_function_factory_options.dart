import '../additional_properties_dictionary.dart';

/// Options for controlling how [AIFunctionFactory] creates an [AIFunction].
class AIFunctionFactoryOptions {
  /// Creates a new [AIFunctionFactoryOptions].
  const AIFunctionFactoryOptions({
    this.name,
    this.description,
    this.additionalProperties,
  });

  /// An override for the function name.
  final String? name;

  /// An override for the function description.
  final String? description;

  /// Additional properties to store on the resulting function.
  final AdditionalPropertiesDictionary? additionalProperties;
}
