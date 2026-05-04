import '../../../../../../lib/func_typedefs.dart';
import 'ai_json_schema_create_context.dart';
import 'ai_json_schema_transform_options.dart';

/// Provides options for configuring the behavior of [AIJsonUtilities] JSON
/// schema creation functionality.
class AJsonSchemaCreateOptions {
  AJsonSchemaCreateOptions();

  /// Gets the default options instance.
  static final AJsonSchemaCreateOptions defaultValue =
      AIJsonSchemaCreateOptions();

  /// Gets a callback that is invoked for every schema that is generated within
  /// the type graph.
  Func2<AJsonSchemaCreateContext, JsonNode, JsonNode>? transformSchemaNode;

  /// Gets a callback that is invoked for every parameter in the [MethodBase]
  /// provided to [AIJsonSchemaCreateOptions)] in order to determine whether it
  /// should be included in the generated schema.
  ///
  /// Remarks: By default, when [IncludeParameter] is `null`, all parameters
  /// other than those of type [CancellationToken] are included in the generated
  /// schema. The delegate is not invoked for [CancellationToken] parameters.
  Func<ParameterInfo, bool>? includeParameter;

  /// Gets a callback that is invoked for each parameter in the [MethodBase]
  /// provided to [AIJsonSchemaCreateOptions)] to obtain a description for the
  /// parameter.
  ///
  /// Remarks: The delegate receives a [ParameterInfo] instance and returns a
  /// string describing the parameter. If `null`, or if the delegate returns
  /// `null`, the description will be sourced from the [MethodBase] metadata
  /// (like [DescriptionAttribute]), if available.
  Func<ParameterInfo, String?>? parameterDescriptionProvider;

  /// Gets a [AIJsonSchemaTransformOptions] governing transformations on the
  /// JSON schema after it has been generated.
  AJsonSchemaTransformOptions? transformOptions;

  /// Gets a value indicating whether to include the $schema keyword in created
  /// schemas.
  bool includeSchemaKeyword;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AJsonSchemaCreateOptions &&
        defaultValue == other.defaultValue &&
        transformSchemaNode == other.transformSchemaNode &&
        includeParameter == other.includeParameter &&
        parameterDescriptionProvider == other.parameterDescriptionProvider &&
        transformOptions == other.transformOptions &&
        includeSchemaKeyword == other.includeSchemaKeyword;
  }

  @override
  int get hashCode {
    return Object.hash(
      defaultValue,
      transformSchemaNode,
      includeParameter,
      parameterDescriptionProvider,
      transformOptions,
      includeSchemaKeyword,
    );
  }
}
