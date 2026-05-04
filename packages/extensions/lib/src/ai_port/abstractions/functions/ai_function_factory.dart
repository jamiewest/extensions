import '../../../../../../lib/func_typedefs.dart';
import '../chat_completion/chat_message.dart';
import '../contents/ai_content.dart';
import '../utilities/ai_json_schema_create_options.dart';
import 'ai_function.dart';
import 'ai_function_arguments.dart';
import 'ai_function_declaration.dart';
import 'ai_function_factory_options.dart';

/// Provides factory methods for creating commonly-used implementations of
/// [AIFunction].
///
/// Remarks: The [AIFunctionFactory] class creates [AIFunction] instances that
/// wrap .NET methods (specified as [Delegate] or [MethodInfo]). As part of
/// this process, JSON schemas are automatically derived for both the
/// function's input parameters (exposed via [JsonSchema]) and, by default,
/// the function's return type (exposed via [ReturnJsonSchema]). These schemas
/// are produced using the [SerializerOptions] and [JsonSchemaCreateOptions],
/// and enable AI services to understand and interact with the function.
/// Return value serialization and schema derivation behavior can be
/// customized via [MarshalResult] and [ExcludeResultSchema], respectively.
class AFunctionFactory {
  AFunctionFactory();

  /// Holds the default options instance used when creating function.
  static final AFunctionFactoryOptions _defaultOptions;

  static final Regex _potentiallyJsonRegex = new(
    PotentiallyJsonRegexString,
    RegexOptions.IgnorePatternWhitespace | RegexOptions.Compiled,
  );

  static final Regex _compilerGeneratedNameRegex = new(
    @"^<([^>]+)>\w__(.+)",
    RegexOptions.Compiled,
  );

  static final Regex _invalidNameCharsRegex = new("[^0-9A-Za-z]+", RegexOptions.Compiled);

  /// Creates an [AIFunction] instance for a method, specified via a delegate.
  ///
  /// Remarks: By default, any parameters to `method` are sourced from the
  /// [AIFunctionArguments]'s dictionary of key/value pairs and are represented
  /// in the JSON schema for the function, as exposed in the returned
  /// [AIFunction]'s [JsonSchema]. There are a few exceptions to this:
  /// [CancellationToken] parameters are automatically bound to the
  /// [CancellationToken] passed into the invocation via [CancellationToken)]'s
  /// [CancellationToken] parameter. The parameter is not included in the
  /// generated JSON schema. The behavior of [CancellationToken] parameters
  /// can't be overridden. By default, [ServiceProvider] parameters are bound
  /// from the [Services] property and are not included in the JSON schema. If
  /// the parameter is optional, such that a default value is provided,
  /// [Services] is allowed to be `null`; otherwise, [Services] must be
  /// non-`null`, or else the invocation will fail with an exception due to the
  /// required nature of the parameter. The handling of [ServiceProvider]
  /// parameters can be overridden via [ConfigureParameterBinding]. By default,
  /// [AIFunctionArguments] parameters are bound directly to
  /// [AIFunctionArguments] instance passed into [CancellationToken)] and are
  /// not included in the JSON schema. If the [AIFunctionArguments] instance
  /// passed to [CancellationToken)] is `null`, the [AIFunction] implementation
  /// manufactures an empty instance, such that parameters of type
  /// [AIFunctionArguments] can always be satisfied, whether optional or not.
  /// The handling of [AIFunctionArguments] parameters can be overridden via
  /// [ConfigureParameterBinding]. All other parameter types are, by default,
  /// bound from the [AIFunctionArguments] dictionary passed into
  /// [CancellationToken)] and are included in the generated JSON schema. This
  /// can be overridden by the [ConfigureParameterBinding] provided via the
  /// `options` parameter; for every parameter, the delegate is enabled to
  /// choose if the parameter should be included in the generated schema and how
  /// its value should be bound, including handling of optionality (by default,
  /// required parameters that are not included in the [AIFunctionArguments]
  /// dictionary will result in an exception being thrown). Loosely-typed
  /// additional context information can be passed into [CancellationToken)] via
  /// the [AIFunctionArguments]'s [Context] dictionary; the default binding
  /// ignores this collection, but a custom binding supplied via
  /// [ConfigureParameterBinding] can choose to source arguments from this data.
  /// The default marshaling of parameters from the [AIFunctionArguments]
  /// dictionary permits values to be passed into the `method`'s invocation
  /// directly if the object is already of a compatible type. Otherwise, if the
  /// argument is a [JsonElement], [JsonDocument], or [JsonNode], it is
  /// deserialized into the parameter type, utilizing [SerializerOptions] if
  /// provided, or else using [DefaultOptions]. If the argument is anything
  /// else, it is round-tripped through JSON, serializing the object as JSON and
  /// then deserializing it to the expected type. In general, the data supplied
  /// via an [AIFunctionArguments]'s dictionary is supplied from an AI service
  /// and should be considered unvalidated and untrusted. To provide validated
  /// and trusted data to the invocation of `method`, consider having `method`
  /// point to an instance method on an instance configured to hold the
  /// appropriate state. An [ServiceProvider] parameter can also be used to
  /// resolve services from a dependency injection container. By default, return
  /// values are serialized to [JsonElement] using `options`'s
  /// [SerializerOptions] if provided, or else using [DefaultOptions]. However,
  /// return values whose declared type is [AIContent], a derived type of
  /// [AIContent], or any type assignable from [Enumerable] (e.g. `AIContent[]`,
  /// `List&lt;AIContent&gt;`) are special-cased and are not serialized: the
  /// created function returns the original instance(s) directly to enable
  /// callers (such as an `IChatClient`) to perform type tests and implement
  /// specialized handling. If [MarshalResult] is supplied, that delegate
  /// governs the behavior instead. In addition to the parameter schema, a JSON
  /// schema is also derived from the method's return type and exposed via the
  /// returned [AIFunction]'s [ReturnJsonSchema]. For methods returning [Void],
  /// [Task], or [ValueTask], no return schema is produced (the property is
  /// `null`). For methods returning [Task] or [ValueTask], the schema is
  /// derived from the unwrapped result type. Return schema generation can be
  /// excluded via [ExcludeResultSchema], and its generation is governed by
  /// `options`'s [JsonSchemaCreateOptions].
  ///
  /// Returns: The created [AIFunction] for invoking `method`.
  ///
  /// [method] The method to be represented via the created [AIFunction].
  ///
  /// [options] Metadata to use to override defaults inferred from `method`.
  static AFunction create({Delegate? method, AFunctionFactoryOptions? options, String? name, String? description, JsonSerializerOptions? serializerOptions, Object? target, Func<AFunctionArguments, Object>? createInstanceFunc, }) {
    _ = Throw.ifNull(method);
    return ReflectionAIFunction.build(method.method, method.target, options ?? _defaultOptions);
  }

  /// Creates an [AIFunctionDeclaration] using the specified parameters as the
  /// implementation of its corresponding properties.
  ///
  /// Remarks: [JsonElement})] creates an [AIFunctionDeclaration] that can be
  /// used to describe a function but not invoke it. To create an invocable
  /// [AIFunction], use Create. A non-invocable [AIFunctionDeclaration] can also
  /// be created from an invocable [AIFunction] using that function's
  /// [AsDeclarationOnly] method.
  ///
  /// Returns: The created [AIFunctionDeclaration] that describes a function.
  ///
  /// [name] The name of the function.
  ///
  /// [description] A description of the function, suitable for use in
  /// describing the purpose to a model.
  ///
  /// [jsonSchema] A JSON schema describing the function and its input
  /// parameters.
  ///
  /// [returnJsonSchema] A JSON schema describing the function's return value.
  static AFunctionDeclaration createDeclaration(
    String name,
    String? description,
    JsonElement jsonSchema,
    {JsonElement? returnJsonSchema, },
  ) {
    return defaultAFunctionDeclaration(
            Throw.ifNullOrEmpty(name),
            description ?? string.empty,
            jsonSchema,
            returnJsonSchema);
  }

  /// Quickly checks if the specified string is potentially JSON by checking if
  /// the first non-whitespace characters are valid JSON start tokens.
  ///
  /// Returns: If `false` then the string is definitely not valid JSON.
  ///
  /// [value] The string to check.
  static bool isPotentiallyJson(String value) {
    return potentiallyJsonRegex().isMatch(value);
  }

  static Regex potentiallyJsonRegex() {
    return _potentiallyJsonRegex;
  }

  /// Removes characters from a .NET member name that shouldn't be used in an AI
  /// function name.
  ///
  /// Returns: Replaces non-alphanumeric characters in the identifier with the
  /// underscore character. Primarily intended to remove characters produced by
  /// compiler-generated method name mangling.
  ///
  /// [memberName] The .NET member name that should be sanitized.
  static String sanitizeMemberName(String memberName) {
    if (compilerGeneratedNameRegex().match(memberName) is { Success: true } match) {
      memberName = '${match.groups[1].value}_${match.groups[2].value}';
    }
    return invalidNameCharsRegex().replace(memberName, "_");
  }

  /// Regex that matches compiler-generated names (local functions and lambdas).
  static Regex compilerGeneratedNameRegex() {
    return _compilerGeneratedNameRegex;
  }

  /// Regex that flags any character other than ASCII digits or letters.
  ///
  /// Remarks: Underscore isn't included so that sequences of underscores are
  /// replaced by a single one.
  static Regex invalidNameCharsRegex() {
    return _invalidNameCharsRegex;
  }

  /// Invokes the MethodInfo with the specified target object and arguments.
  static Object? reflectionInvoke(MethodInfo method, Object? target, List<Object?>? arguments, ) {
    try {
      return method.invoke(
        target,
        BindingFlags.defaultValue,
        binder: null,
        arguments,
        culture: null,
      );
    } catch (e, s) {
      if (e is TargetInvocationException) {
        final e = e as TargetInvocationException;
        {
          // If we're targeting .net Framework, such that BindingFlags.doNotWrapExceptions
            // is ignored, the original exception will be wrapped in a TargetInvocationException.
            // Unwrap it and throw that original exception, maintaining its stack information.
            System.runtime.exceptionServices.exceptionDispatchInfo.capture(e.innerException).throwValue();
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }
}
class DefaultAFunctionDeclaration extends AFunctionDeclaration {
  const DefaultAFunctionDeclaration(
    String name,
    String description,
    JsonElement jsonSchema,
    JsonElement? returnJsonSchema,
  ) :
      name = name,
      description = description,
      jsonSchema = jsonSchema,
      returnJsonSchema = returnJsonSchema;

  String get name {
    return name;
  }

  String get description {
    return description;
  }

  JsonElement get jsonSchema {
    return jsonSchema;
  }

  JsonElement? get returnJsonSchema {
    return returnJsonSchema;
  }
}
/// Implements a simple write-only memory stream that uses pooled buffers.
class PooledMemoryStream extends Stream {
  PooledMemoryStream({int? initialCapacity = null}) : _buffer = ArrayPool<int>.shared.rent(initialCapacity), _position = 0;

  List<int> _buffer;

  int _position;

  long position;

  ReadOnlySpan<int> getBuffer() {
    return _buffer.asSpan(0, _position);
  }

  bool get canWrite {
    return true;
  }

  bool get canRead {
    return false;
  }

  bool get canSeek {
    return false;
  }

  long get length {
    return _position;
  }

  @override
  void write(List<int> buffer, int offset, int count, ) {
    ensureNotDisposed();
    ensureCapacity(_position + count);
    Buffer.blockCopy(buffer, offset, _buffer, _position, count);
    _position += count;
  }

  @override
  void flush() {

  }

  @override
  Future flushAsync(CancellationToken cancellationToken) {
    return Task.completedFuture;
  }

  @override
  Future writeAsync(
    CancellationToken cancellationToken,
    {List<int>? buffer, int? offset, int? count, },
  ) {
    return writeAsync(ReadOnlyMemory<int>(buffer, offset, count), cancellationToken).asFuture();
  }

  @override
  int read(List<int> buffer, int offset, int count, ) {
    return throw notSupportedException();
  }

  @override
  long seek(long offset, SeekOrigin origin, ) {
    return throw notSupportedException();
  }

  @override
  void setLength(long value) {
    throw notSupportedException();
  }

  @override
  void dispose(bool disposing) {
    if (_buffer != null) {
      ArrayPool<int>.shared.returnValue(_buffer);
      _buffer = null!;
    }
    base.dispose(disposing);
  }

  void ensureCapacity(int requiredCapacity) {
    if (requiredCapacity <= _buffer.length) {
      return;
    }
    var newCapacity = Math.max(requiredCapacity, _buffer.length * 2);
    var newBuffer = ArrayPool<int>.shared.rent(newCapacity);
    Buffer.blockCopy(_buffer, 0, newBuffer, 0, _position);
    ArrayPool<int>.shared.returnValue(_buffer);
    _buffer = newBuffer;
  }

  void ensureNotDisposed() {
    if (_buffer == null) {
      throwValue();
      /* TODO: unsupported node kind "unknown" */
      // static void Throw() => throw new ObjectDisposedException(nameof(PooledMemoryStream));
    }
  }
}
class ReflectionAFunction extends AFunction {
  ReflectionAFunction(
    ReflectionAFunctionDescriptor functionDescriptor,
    AFunctionFactoryOptions options,
    {Object? target = null, Func<AFunctionArguments, Object>? createInstanceFunc = null, },
  ) :
      functionDescriptor = functionDescriptor,
      target = target,
      additionalProperties = options.additionalProperties ?? EmptyReadOnlyDictionary<String, Object?>.instance;

  final ReflectionAFunctionDescriptor functionDescriptor;

  final Object? target;

  final Func<AFunctionArguments, Object>? createInstanceFunc;

  final Map<String, Object?> additionalProperties;

  static ReflectionAFunction build(
    MethodInfo method,
    AFunctionFactoryOptions options,
    {Object? target, Func<AFunctionArguments, Object>? createInstanceFunc, },
  ) {
    _ = Throw.ifNull(method);
    if (method.containsGenericParameters) {
      Throw.argumentException(nameof(method), "Open generic methods are not supported");
    }
    if (!method.isStatic && target == null) {
      Throw.argumentNullException(
        nameof(target),
        "target must not be null for an instance method.",
      );
    }
    var functionDescriptor = ReflectionAIFunctionDescriptor.getOrCreate(method, options);
    if (target == null&& options.additionalProperties == null) {
      return functionDescriptor.cachedDefaultInstance ??= new(functionDescriptor, target, options);
    }
    return new(functionDescriptor, target, options);
  }

  String get name {
    return functionDescriptor.name;
  }

  String get description {
    return functionDescriptor.description;
  }

  MethodInfo get underlyingMethod {
    return functionDescriptor.method;
  }

  JsonElement get jsonSchema {
    return functionDescriptor.jsonSchema;
  }

  JsonElement? get returnJsonSchema {
    return functionDescriptor.returnJsonSchema;
  }

  JsonSerializerOptions get jsonSerializerOptions {
    return functionDescriptor.jsonSerializerOptions;
  }

  @override
  Future<Object?> invokeCore(
    AFunctionArguments arguments,
    CancellationToken cancellationToken,
  ) async  {
    var disposeTarget = false;
    var target = target;
    try {
      if (createInstanceFunc is { } func) {
        Debug.assertValue(
          target == null,
          "Expected target to be null when we have a non-null target type",
        );
        Debug.assertValue(!functionDescriptor.method.isStatic, "Expected an instance method");
        target = func(arguments);
        if (target == null) {
          Throw.invalidOperationException("Unable to create an instance of the target type.");
        }
        disposeTarget = true;
      }
      var paramMarshallers = functionDescriptor.parameterMarshallers;
      var args = paramMarshallers.length != 0 ? List.filled(paramMarshallers.length, null) : [];
      if (functionDescriptor.jsonSerializerOptions.unmappedMemberHandling is JsonUnmappedMemberHandling.disallow &&
                    arguments.count > 0 &&
                    !functionDescriptor.hasCustomParameterBinding) {
        var expectedNames = functionDescriptor.expectedArgumentNames;
        var matched = 0;
        for (final name in expectedNames) {
          if (arguments.containsKey(name)) {
            matched++;
          }
        }
        if (matched != arguments.count) {
          for (final kvp in arguments) {
            if (!expectedNames.contains(kvp.key)) {
              Throw.argumentException(
                                    nameof(arguments),
                                    'The arguments dictionary contains an unexpected key '${kvp.key}' that does not correspond to any parameter of '${name}'.');
            }
          }
          // Fallback for comparer mismatches (e.g. case-insensitive arguments dictionary
                        // with duplicate-casing keys aliasing to the same parameter).
                        Throw.argumentException(
                            nameof(arguments),
                            'The arguments dictionary contains keys that do not correspond to any parameter of '${name}'.');
        }
      }
      for (var i = 0; i < args.length; i++) {
        args[i] = paramMarshallers[i](arguments, cancellationToken);
      }
      return await functionDescriptor.returnParameterMarshaller(
                    reflectionInvoke(
                      functionDescriptor.method,
                      target,
                      args,
                    ), cancellationToken).configureAwait(true);
    } finally {
      if (disposeTarget) {
        if (target is AsyncDisposable) {
          final ad = target as AsyncDisposable;
          await ad.disposeAsync().configureAwait(true);
        } else if (target is Disposable) {
          final d = target as Disposable;
          d.dispose();
        }
      }
    }
  }
}
/// A descriptor for a .NET method-backed AIFunction that precomputes its
/// marshalling delegates and JSON schema.
class ReflectionAFunctionDescriptor {
  ReflectionAFunctionDescriptor(
    DescriptorKey key,
    JsonSerializerOptions serializerOptions,
  ) :
      expectedArgumentNames = expectedArgumentNames,
      hasCustomParameterBinding = hasCustomParameterBinding,
      returnParameterMarshaller = getReturnParameterMarshaller(key, serializerOptions, out Type? returnType),
      method = key.method,
      name = key.name ?? key.method.getCustomAttribute<DisplayNameAttribute>(inherit: true)?.displayName ?? getFunctionName(key.method),
      description = key.description ?? key.method.getCustomAttribute<DescriptionAttribute>(inherit: true)?.description ?? string.empty,
      jsonSerializerOptions = serializerOptions,
      returnJsonSchema = returnType == null || key.excludeResultSchema ? null : AIJsonUtilities.createJsonSchema(
                normalizeReturnType(returnType, serializerOptions),
                description: getReturnParameterDescription(key.method),
                serializerOptions: serializerOptions,
                inferenceOptions: schemaOptions), jsonSchema = AIJsonUtilities.createFunctionJsonSchema(
                key.method,
                title: string.empty, // Forces skipping of the title keyword
                description: string.empty, // Forces skipping of the description keyword
                serializerOptions: serializerOptions,
                inferenceOptions: schemaOptions) {
    var parameters = key.method.getParameters();
    var boundParameters = null;
    if (parameters.length != 0 && key.getBindParameterOptions != null) {
      boundParameters = new(parameters.length);
      for (var i = 0; i < parameters.length; i++) {
        boundParameters[parameters[i]] = key.getBindParameterOptions(parameters[i]);
      }
    }
    var schemaOptions = key.schemaOptions with
            {
                IncludeParameter = (parameterInfo) =>
                {
                    // AIFunctionArguments and IServiceProvider parameters are always excluded from the schema.
                    if (parameterInfo.parameterType == typeof(AIFunctionArguments) ||
                        parameterInfo.parameterType == typeof(IServiceProvider))
                    {
                        return false;
        }

                    // If the parameter is marked as excluded by GetBindParameterOptions, exclude it.
                    if (boundParameters?.tryGetValue(parameterInfo, out var options) is true &&
                        options.excludeFromSchema)
                    {
                        return false;
        }

                    // If there was an existing IncludeParameter delegate, now defer to it as we've
                    // excluded everything we need to exclude.
                    if (key.schemaOptions.includeParameter is { } existingIncludeParameter)
                    {
                        return existingIncludeParameter(parameterInfo);
        }

                    // Everything else is included.
                    return true;
                },
            };
    // Get marshaling delegates for parameters.
            parameterMarshallers = parameters.length > 0 ? new Func<AFunctionArguments, CancellationToken, Object?>[parameters.length] : [];
    var expectedArgumentNames = new(StringComparer.ordinal);
    var hasCustomParameterBinding = false;
    for (var i = 0; i < parameters.length; i++) {
      ParameterBindingOptions options;
      if (boundParameters?.tryGetValue(parameters[i]) is! true) {
        options = default;
      }
      parameterMarshallers[i] = getParameterMarshaller(serializerOptions, options, parameters[i]);
      if (options.bindParameter != null) {
        // Custom BindParameter callbacks can legally source their value from arbitrary keys in the
                    // AIFunctionArguments dictionary, so we cannot know in advance which keys are "expected".
                    // Note this down so that strict unmapped-member validation is skipped in InvokeCoreAsync.
                    hasCustomParameterBinding = true;
      }
      var pType = parameters[i].parameterType;
      if (pType != typeof(CancellationToken) &&
                    pType != typeof(AIFunctionArguments) &&
                    pType != typeof(IServiceProvider) &&
                    !string.isNullOrEmpty(parameters[i].name)) {
        _ = expectedArgumentNames.add(parameters[i].name!);
      }
    }
  }

  static final ConditionalWeakTable<JsonSerializerOptions, ConcurrentDictionary<DescriptorKey, ReflectionAFunctionDescriptor>> _descriptorCache;

  /// A boxed [None].
  static final Object? _boxedDefaultCancellationToken = default(CancellationToken);

  final String name;

  final String description;

  final MethodInfo method;

  final JsonSerializerOptions jsonSerializerOptions;

  final JsonElement jsonSchema;

  final JsonElement? returnJsonSchema;

  final List<Func2<AFunctionArguments, CancellationToken, Object?>> parameterMarshallers;

  final Func2<Object?, CancellationToken, Future<Object?>> returnParameterMarshaller;

  final Set<String> expectedArgumentNames;

  final bool hasCustomParameterBinding;

  ReflectionAFunction? cachedDefaultInstance;

  static final MethodInfo _taskGetResult = typeof(Task<>).GetProperty(nameof(Task<int>.Result), BindingFlags.Instance | BindingFlags.Public)!.GetMethod!;

  static final MethodInfo _valueFutureAsFuture = typeof(ValueTask<>).GetMethod(nameof(ValueTask<int>.AsTask), BindingFlags.Instance | BindingFlags.Public)!;

  /// Gets or creates a descriptors using the specified method and options.
  static ReflectionAFunctionDescriptor getOrCreate(
    MethodInfo method,
    AFunctionFactoryOptions options,
  ) {
    var serializerOptions = options.serializerOptions ?? AIJsonUtilities.defaultOptions;
    var schemaOptions = options.jsonSchemaCreateOptions ?? AIJsonSchemaCreateOptions.defaultValue;
    serializerOptions.makeReadOnly();
    var innerCache = _descriptorCache.getOrCreateValue(serializerOptions);
    var key = new(
      method,
      options.name,
      options.description,
      options.configureParameterBinding,
      options.marshalResult,
      options.excludeResultSchema,
      schemaOptions,
    );
    ReflectionAFunctionDescriptor descriptor;
    if (innerCache.tryGetValue(key)) {
      return descriptor;
    }
    descriptor = new(key, serializerOptions);
    return innerCache.count < InnerCacheSoftLimit
                ? innerCache.getOrAdd(key, descriptor)
                : descriptor;
  }

  static String getFunctionName(MethodInfo method) {
    var name = sanitizeMemberName(method.name);
    var AsyncSuffix = "Async";
    if (isAsyncMethod(method)) {
      var asyncIndex = name.lastIndexOf(AsyncSuffix, StringComparison.ordinal);
      if (asyncIndex > 0 &&
                    (asyncIndex + AsyncSuffix.length == name.length ||
                     ((asyncIndex + AsyncSuffix.length < name.length) && (name[asyncIndex + AsyncSuffix.length] == '_')))) {
        name =
        #if NET
                        string.concat(
                          name.asSpan(0, asyncIndex),
                          name.asSpan(asyncIndex + AsyncSuffix.length),
                        );
        #else
                        string.concat(
                          name.substring(0, asyncIndex),
                          name.substring(asyncIndex + AsyncSuffix.length),
                        );
      }
    }
    return name;
    /* TODO: unsupported node kind "unknown" */
    // static bool IsAsyncMethod(MethodInfo method)
    //             {
      //                 Type t = method.ReturnType;
      //
      //                 if (t == typeof(Task) || t == typeof(ValueTask))
      //                 {
        //                     return true;
        //                 }
      //
      //                 if (t.IsGenericType)
      //                 {
        //                     t = t.GetGenericTypeDefinition();
        //                     if (t == typeof(Task<>) || t == typeof(ValueTask<>) || t == typeof(IAsyncEnumerable<>))
        //                     {
          //                         return true;
          //                     }
        //                 }
      //
      //                 return false;
      //             }
  }

  /// Gets a delegate for handling the marshaling of a parameter.
  static Func2<AFunctionArguments, CancellationToken, Object?> getParameterMarshaller(
    JsonSerializerOptions serializerOptions,
    ParameterBindingOptions bindingOptions,
    ParameterInfo parameter,
  ) {
    if (string.isNullOrWhiteSpace(parameter.name)) {
      Throw.argumentException(nameof(parameter), "Parameter is missing a name.");
    }
    var parameterType = parameter.parameterType;
    if (parameterType == typeof(CancellationToken)) {
      return (_, cancellationToken) =>
                    cancellationToken == default ? _boxedDefaultCancellationToken : // optimize common case of a default CT to avoid boxing
                    cancellationToken;
    }
    if (bindingOptions.bindParameter is { } bindParameter) {
      return (arguments, _) => bindParameter(parameter, arguments);
    }
    if (parameterType == typeof(AIFunctionArguments)) {
      return (arguments, _) => arguments;
    }
    if (parameterType == typeof(IServiceProvider)) {
      var hasDefault = AIJsonUtilities.tryGetEffectiveDefaultValue(parameter, out _);
      return (arguments, _) =>
                {
                    IServiceProvider? services = arguments.services;
                    if (!hasDefault && services == null)
                    {
                        throwNullServices(parameter.name);
        }

                    return services;
                };
    }
    var typeInfo = serializerOptions.getTypeInfo(parameterType);
    var hasDefaultValue = AIJsonUtilities.tryGetEffectiveDefaultValue(
      parameter,
      out object? effectiveDefaultValue,
    );
    return (arguments, _) =>
            {
                // If the parameter has an argument specified in the dictionary, return that argument.
                if (arguments.tryGetValue(parameter.name, out object? value))
                {
                    return value switch
                    {
                        (null) => null, // Return as-is if null -- if the parameter is a struct this will be handled by MethodInfo.invoke
                        _ when parameterType.isInstanceOfType(value) => value, // Do nothing if value is assignable to parameter type
                        JsonElement (element) => JsonSerializer.deserialize(element, typeInfo),
                        JsonDocument (doc) => JsonSerializer.deserialize(doc, typeInfo),
                        JsonNode (node) => JsonSerializer.deserialize(node, typeInfo),
                        (_) => marshallViaJsonRoundtrip(value),
                    };

                    object? marshallViaJsonRoundtrip(object value)
                    {
                        try
                        {
                            if (value is string text && isPotentiallyJson(text))
                            {
                                Debug.assertValue(
                                  typeInfo.type != typeof(string),
                                  "string parameters should not enter this branch.",
                                );

                                // Account for the parameter potentially being a JSON string.
                                // The value is a string but the type is not. Try to deserialize it under the assumption that it's JSON.
                                // If it's not, we'll fall through to the default path that makes it valid JSON and then tries to deserialize.
                                try
                                {
                                    return JsonSerializer.deserialize(text, typeInfo);
              }
                                catch (JsonException)
                                {
                                    // If the string is! valid JSON, fall through to the round-trip.
              }
            }

                            string json = JsonSerializer.serialize(
                              value,
                              serializerOptions.getTypeInfo(value.getType()),
                            );
                            return JsonSerializer.deserialize(json, typeInfo);
          }
                        catch
                        {
                            // Eat any exceptions and fall back to the original value to force a cast exception later on.
                            return value;
          }
        }
      }

                // If the parameter is required and there's no argument specified for it, throw.
                if (!hasDefaultValue)
                {
                    Throw.argumentException(
                      nameof(arguments),
                      'The arguments dictionary is missing a value for the required parameter '${parameter.name}'.',
                    );
      }

                // Otherwise, use the optional parameter's default value.
                return effectiveDefaultValue;
            };
    /* TODO: unsupported node kind "unknown" */
    // // Throws an ArgumentNullException indicating that AIFunctionArguments.Services must be provided.
    //             static void ThrowNullServices(string parameterName) =>
    //                 Throw.ArgumentNullException($"arguments.{nameof(AIFunctionArguments.Services)}", $"Services are required for parameter '{parameterName}'.");
  }

  /// Gets a delegate for handling the result value of a method, converting it
  /// into the [Task] to return from the invocation.
  static (
    Func2<Object?, CancellationToken, Future<Object?>>,
    Type??,
  ) getReturnParameterMarshaller(DescriptorKey key, JsonSerializerOptions serializerOptions, ) {
    var returnType = null;
    returnType = key.method.returnType;
    var returnTypeInfo;
    var marshalResult = key.marshalResult;
    if (returnType == typeof(void)) {
      returnType = null;
      if (marshalResult != null) {
        return (
          (result, cancellationToken) => marshalResult(null, null, cancellationToken),
          returnType,
        );
      }
      return ((_, _) => new ValueTask<Object?>((object?)null), returnType);
    }
    if (returnType == typeof(Task)) {
      returnType = null;
      if (marshalResult != null) {
        return (async (result, cancellationToken) =>
                          {
                              await ((Task)throwIfNullResult(result)).configureAwait(true);
                              return await marshalResult(
                                null,
                                null,
                                cancellationToken,
                              ) .configureAwait(true);
                          }, returnType);
      }
      return (async (result, _) =>
                  {
                      await ((Task)throwIfNullResult(result)).configureAwait(true);
                      return null;
                  }, returnType);
    }
    if (returnType == typeof(ValueTask)) {
      returnType = null;
      if (marshalResult != null) {
        return (async (result, cancellationToken) =>
                          {
                              await ((ValueTask)throwIfNullResult(result)).configureAwait(true);
                              return await marshalResult(
                                null,
                                null,
                                cancellationToken,
                              ) .configureAwait(true);
                          }, returnType);
      }
      return (async (result, _) =>
                  {
                      await ((ValueTask)throwIfNullResult(result)).configureAwait(true);
                      return null;
                  }, returnType);
    }
    if (returnType.isGenericType) {
      if (returnType.getGenericTypeDefinition() == typeof(Task<>)) {
        var taskResultGetter = getMethodFromGenericMethodDefinition(returnType, _taskGetResult);
        returnType = taskResultGetter.returnType;
        if (marshalResult != null) {
            return (async (taskObj, cancellationToken) =>
                                    {
                                        await ((Task)throwIfNullResult(taskObj)).configureAwait(true);
                                        object? result = reflectionInvoke(
                                          taskResultGetter,
                                          taskObj,
                                          null,
                                        );
                                        return await marshalResult(
                                          result,
                                          taskResultGetter.returnType,
                                          cancellationToken,
                                        ) .configureAwait(true);
                                    }, returnType);
        }
        if (isAIContentRelatedType(returnType)) {
            return (async (taskObj, cancellationToken) =>
                                    {
                                        await ((Task)throwIfNullResult(taskObj)).configureAwait(true);
                                        return reflectionInvoke(taskResultGetter, taskObj, null);
                                    }, returnType);
        }
        // For everything else, just serialize the result as-is.
                          returnTypeInfo = serializerOptions.getTypeInfo(returnType);
        return (async (taskObj, cancellationToken) =>
                          {
                              await ((Task)throwIfNullResult(taskObj)).configureAwait(true);
                              object? result = reflectionInvoke(taskResultGetter, taskObj, null);
                              return await serializeResultAsync(
                                result,
                                returnTypeInfo,
                                cancellationToken,
                              ) .configureAwait(true);
                          }, returnType);
      }
      if (returnType.getGenericTypeDefinition() == typeof(ValueTask<>)) {
        var valueTaskAsTask = getMethodFromGenericMethodDefinition(returnType, _valueTaskAsTask);
        var asTaskResultGetter = getMethodFromGenericMethodDefinition(
          valueTaskAsTask.returnType,
          _taskGetResult,
        );
        returnType = asTaskResultGetter.returnType;
        if (marshalResult != null) {
            return (async (taskObj, cancellationToken) =>
                                    {
                                        var task = (Task)reflectionInvoke(valueTaskAsTask, throwIfNullResult(taskObj), null)!;
                                        await task.configureAwait(true);
                                        object? result = reflectionInvoke(
                                          asTaskResultGetter,
                                          task,
                                          null,
                                        );
                                        return await marshalResult(
                                          result,
                                          asTaskResultGetter.returnType,
                                          cancellationToken,
                                        ) .configureAwait(true);
                                    }, returnType);
        }
        if (isAIContentRelatedType(returnType)) {
            return (async (taskObj, cancellationToken) =>
                                    {
                                        var task = (Task)reflectionInvoke(valueTaskAsTask, throwIfNullResult(taskObj), null)!;
                                        await task.configureAwait(true);
                                        return reflectionInvoke(asTaskResultGetter, task, null);
                                    }, returnType);
        }
        // For everything else, just serialize the result as-is.
                          returnTypeInfo = serializerOptions.getTypeInfo(returnType);
        return (async (taskObj, cancellationToken) =>
                          {
                              var task = (Task)reflectionInvoke(valueTaskAsTask, throwIfNullResult(taskObj), null)!;
                              await task.configureAwait(true);
                              object? result = reflectionInvoke(asTaskResultGetter, task, null);
                              return await serializeResultAsync(
                                result,
                                returnTypeInfo,
                                cancellationToken,
                              ) .configureAwait(true);
                          }, returnType);
      }
    }
    if (marshalResult != null) {
      var returnTypeCopy = returnType;
      return (
        (result, cancellationToken) => marshalResult(result, returnTypeCopy, cancellationToken),
        returnType,
      );
    }
    if (isAIContentRelatedType(returnType)) {
      return ((result, _) => new ValueTask<Object?>(result), returnType);
    }
    // For everything else, just serialize the result as-is.
            returnTypeInfo = serializerOptions.getTypeInfo(returnType);
    return (
      (result, cancellationToken) => serializeResultAsync(result, returnTypeInfo, cancellationToken),
      returnType,
    );
    /* TODO: unsupported node kind "unknown" */
    // static async ValueTask<object?> SerializeResultAsync(object? result, JsonTypeInfo returnTypeInfo, CancellationToken cancellationToken)
    //             {
      //                 if (returnTypeInfo.Kind is JsonTypeInfoKind.None)
      //                 {
        //                     // Special-case trivial contracts to avoid the more expensive general-purpose serialization path.
        //                     return JsonSerializer.SerializeToElement(result, returnTypeInfo);
        //                 }
      //
      //                 // Serialize asynchronously to support potential IAsyncEnumerable responses.
      //                 using PooledMemoryStream stream = new();
      //                 await JsonSerializer.SerializeAsync(stream, result, returnTypeInfo, cancellationToken).ConfigureAwait(true);
      //                 Utf8JsonReader reader = new(stream.GetBuffer());
      //                 return JsonElement.ParseValue(ref reader);
      //             }
    /* TODO: unsupported node kind "unknown" */
    // // Throws an exception if a result is found to be null unexpectedly
    //             static object ThrowIfNullResult(object? result) => result ?? throw new InvalidOperationException("Function returned null unexpectedly.");
  }

  static MethodInfo getMethodFromGenericMethodDefinition(
    Type specializedType,
    MethodInfo genericMethodDefinition,
  ) {
    Debug.assertValue(
      specializedType.isGenericType && specializedType.getGenericTypeDefinition() == genericMethodDefinition.declaringType,
      "generic member definition doesn't match type.",
    );
    var All = BindingFlags.public | BindingFlags.nonPublic | BindingFlags.staticValue | BindingFlags.instance;
    return specializedType.getMethods(All).first((m) => m.metadataToken == genericMethodDefinition.metadataToken);
  }

  static bool isAIContentRelatedType(Type type) {
    return typeof(AIContent).isAssignableFrom(type) ||
            typeof(IEnumerable<AContent>).isAssignableFrom(type);
  }

  static String? getReturnParameterDescription(MethodInfo method) {
    try {
      return method.returnParameter.getCustomAttribute<DescriptionAttribute>(inherit: true)?.description;
    } catch (e, s) {
      if (e is Exception) {
        final e = e as Exception;
        {
          return null;
        }
      } else {
        rethrow;
      }
    }
  }

  static Type normalizeReturnType(Type type, JsonSerializerOptions? options, ) {
    options ??= AIJsonUtilities.defaultOptions;
    if (options == AIJsonUtilities.defaultOptions && !options.tryGetTypeInfo(type, out _)) {
      if (typeof(IEnumerable<AContent>).isAssignableFrom(type)) {
        return typeof(IEnumerable<AContent>);
      }
      if (typeof(IEnumerable<ChatMessage>).isAssignableFrom(type)) {
        return typeof(IEnumerable<ChatMessage>);
      }
      if (typeof(IEnumerable<String>).isAssignableFrom(type)) {
        return typeof(IEnumerable<String>);
      }
    }
    return type;
  }
}
class DescriptorKey extends ValueType {
  const DescriptorKey(
    MethodInfo Method,
    String? Name,
    String? Description,
    Func<ParameterInfo, ParameterBindingOptions>? GetBindParameterOptions,
    Func3<Object?, Type?, CancellationToken, Future<Object?>>? MarshalResult,
    bool ExcludeResultSchema,
    AJsonSchemaCreateOptions SchemaOptions,
  ) :
      method = Method,
      name = Name,
      description = Description,
      getBindParameterOptions = GetBindParameterOptions,
      marshalResult = MarshalResult,
      excludeResultSchema = ExcludeResultSchema,
      schemaOptions = SchemaOptions;

  MethodInfo method;

  String? name;

  String? description;

  Func<ParameterInfo, ParameterBindingOptions>? getBindParameterOptions;

  Func3<Object?, Type?, CancellationToken, Future<Object?>>? marshalResult;

  bool excludeResultSchema;

  AJsonSchemaCreateOptions schemaOptions;

  @override
  bool operator ==(Object other) { if (identical(this, other)) return true;
    return other is DescriptorKey &&
    method == other.method &&
    name == other.name &&
    description == other.description &&
    getBindParameterOptions == other.getBindParameterOptions &&
    marshalResult == other.marshalResult &&
    excludeResultSchema == other.excludeResultSchema &&
    schemaOptions == other.schemaOptions; }
  @override
  int get hashCode { return Object.hash(
    method,
    name,
    description,
    getBindParameterOptions,
    marshalResult,
    excludeResultSchema,
    schemaOptions,
  ); }
}
