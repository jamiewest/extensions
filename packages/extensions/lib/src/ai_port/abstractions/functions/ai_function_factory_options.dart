import '../../../../../../lib/func_typedefs.dart';
import '../utilities/ai_json_schema_create_options.dart';
import 'ai_function.dart';
import 'ai_function_arguments.dart';
import 'ai_function_factory.dart';

/// Represents options that can be provided when creating an [AIFunction] from
/// a method.
class AFunctionFactoryOptions {
  /// Initializes a new instance of the [AIFunctionFactoryOptions] class.
  const AFunctionFactoryOptions();

  /// Gets or sets the [JsonSerializerOptions] used to marshal .NET values being
  /// passed to the underlying delegate.
  ///
  /// Remarks: If no value has been specified, the [DefaultOptions] instance
  /// will be used. The [UnmappedMemberHandling] setting is honored by the
  /// function parameter binder: when set to [Disallow], invoking the produced
  /// [AIFunction] throws if the supplied [AIFunctionArguments] contains keys
  /// that do not correspond to a bindable parameter of the underlying method.
  JsonSerializerOptions? serializerOptions;

  /// Gets or sets the [AIJsonSchemaCreateOptions] governing the generation of
  /// JSON schemas for the function's input parameters and return type.
  ///
  /// Remarks: If no value has been specified, the [Default] instance will be
  /// used. This setting affects both the [JsonSchema] (input parameters) and
  /// the [ReturnJsonSchema] (return type).
  AJsonSchemaCreateOptions? jsonSchemaCreateOptions;

  /// Gets or sets the name to use for the function.
  String? name;

  /// Gets or sets the description to use for the function.
  String? description;

  /// Gets or sets additional values to store on the resulting
  /// [AdditionalProperties] property.
  ///
  /// Remarks: This property can be used to provide arbitrary information about
  /// the function.
  Map<String, Object?>? additionalProperties;

  /// Gets or sets a delegate used to determine how a particular parameter to
  /// the function should be bound.
  ///
  /// Remarks: If `null`, the default parameter binding logic will be used. If
  /// non-`null` value, this delegate will be invoked once for each parameter in
  /// the function as part of creating the [AIFunction] instance. It is not
  /// invoked for parameters of type [CancellationToken], which are invariably
  /// bound to the token provided to the [CancellationToken)] invocation.
  /// Returning a default [ParameterBindingOptions] results in the same behavior
  /// as if [ConfigureParameterBinding] is `null`.
  Func<ParameterInfo, ParameterBindingOptions>? configureParameterBinding;

  /// Gets or sets a delegate used to determine the [Object] returned by
  /// [CancellationToken)].
  ///
  /// Remarks: By default, the return value of invoking the method wrapped into
  /// an [AIFunction] by [AIFunctionFactory] is then JSON serialized, with the
  /// resulting [JsonElement] returned from the [CancellationToken)] method.
  /// This default behavior is ideal for the common case where the result will
  /// be passed back to an AI service. However, if the caller requires more
  /// control over the result's marshaling, the [MarshalResult] property may be
  /// set to a delegate that is then provided with complete control over the
  /// result's marshaling. The delegate is invoked with the value returned by
  /// the method, and its return value is then returned from the
  /// [CancellationToken)] method. When set, the delegate is invoked even for
  /// `void`-returning methods, in which case it is invoked with a `null`
  /// argument. By default, `null` is returned from the [CancellationToken)]
  /// method for [AIFunction] instances produced by [AIFunctionFactory] to wrap
  /// `void`-returning methods). Methods strongly typed to return types of
  /// [Task], [Task], [ValueTask], and [ValueTask] are special-cased. For
  /// methods typed to return [Task] or [ValueTask], [MarshalResult] will be
  /// invoked with the `null` value after the returned task has successfully
  /// completed. For methods typed to return [Task] or [ValueTask], the delegate
  /// will be invoked with the task's result value after the task has
  /// successfully completed.These behaviors keep synchronous and asynchronous
  /// methods consistent. In addition to the returned value, which is provided
  /// to the delegate as the first argument, the delegate is also provided with
  /// a [Type] represented the declared return type of the method. This can be
  /// used to determine how to marshal the result. This may be different than
  /// the actual type of the object ([GetType]) if the method returns a derived
  /// type or `null`. If the method is typed to return [Task], [ValueTask], or
  /// `void`, the [Type] argument will be `null`.
  Func3<Object?, Type?, CancellationToken, Future<Object?>>? marshalResult;

  /// Gets or sets a value indicating whether to exclude generation of a JSON
  /// schema for the function's return type.
  ///
  /// Remarks: The default value is `false`, meaning a return type schema will
  /// be generated and exposed via [ReturnJsonSchema] when the method has a
  /// return type other than [Void], [Task], or [ValueTask]. When set to `true`,
  /// the produced [ReturnJsonSchema] will always be `null`.
  bool excludeResultSchema;
}

/// Provides configuration options produced by the [ConfigureParameterBinding]
/// delegate.
class ParameterBindingOptions extends ValueType {
  ParameterBindingOptions();

  /// Gets a delegate used to determine the value for a bound parameter.
  ///
  /// Remarks: The default value is `null`. If `null`, the default binding
  /// semantics are used for the parameter. If non- `null`, each time the
  /// [AIFunction] is invoked, this delegate will be invoked to select the
  /// argument value to use for the parameter. The return value of the delegate
  /// will be used for the parameter's value.
  Func2<ParameterInfo, AFunctionArguments, Object?>? bindParameter;

  /// Gets a value indicating whether the parameter should be excluded from the
  /// generated schema.
  ///
  /// Remarks: The default value is `false`. Typically, this property is set to
  /// `true` if and only if [BindParameter] is also set to non-`null`. While
  /// it's possible to exclude the schema when [BindParameter] is `null`, doing
  /// so means that default marshaling will be used but the AI service won't be
  /// aware of the parameter or able to generate an argument for it. This is
  /// likely to result in invocation errors, as the parameter information is
  /// unlikely to be available. It, however, is permissible for cases where
  /// invocation of the [AIFunction] is tightly controlled, and the caller is
  /// expected to augment the argument dictionary with the parameter value.
  bool excludeFromSchema;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParameterBindingOptions &&
        bindParameter == other.bindParameter &&
        excludeFromSchema == other.excludeFromSchema;
  }

  @override
  int get hashCode {
    return Object.hash(bindParameter, excludeFromSchema);
  }
}
