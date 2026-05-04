/// Represents a tool that can be specified to an AI service.
abstract class ATool {
  /// Initializes a new instance of the [AITool] class.
  const ATool();

  /// Gets the string to display in the debugger for this instance.
  final String debuggerDisplay;

  /// Gets the name of the tool.
  String get name {
    return getType().name;
  }

  /// Gets a description of the tool, suitable for use in describing the purpose
  /// to a model.
  String get description {
    return string.empty;
  }

  /// Gets any additional properties associated with the tool.
  Map<String, Object?> get additionalProperties {
    return EmptyReadOnlyDictionary<String, Object?>.instance;
  }

  @override
  String toString() {
    return name;
  }

  /// Asks the [AITool] for an object of the specified type `serviceType`.
  ///
  /// Remarks: The purpose of this method is to allow for the retrieval of
  /// strongly typed services that might be provided by the [AITool], including
  /// itself or any services it might be wrapping.
  ///
  /// Returns: The found object, otherwise `null`.
  ///
  /// [serviceType] The type of object being requested.
  ///
  /// [serviceKey] An optional key that can be used to help identify the target
  /// service.
  Object? getService(Object? serviceKey, {Type? serviceType}) {
    _ = Throw.ifNull(serviceType);
    return serviceKey == null && serviceType.isInstanceOfType(this)
        ? this
        : null;
  }
}
