import '../../../../../../lib/func_typedefs.dart';
import 'hosted_file_client.dart';

/// Represents the options for a hosted file client request.
class HostedFileClientOptions {
  /// Initializes a new instance of the [HostedFileClientOptions] class by
  /// cloning the properties of another instance.
  ///
  /// [other] The instance to clone.
  HostedFileClientOptions(HostedFileClientOptions? other) : scope = other.scope, purpose = other.purpose, limit = other.limit, rawRepresentationFactory = other.rawRepresentationFactory, additionalProperties = other.additionalProperties?.clone() {
    if (other == null) {
      return;
    }
  }

  /// Gets or sets a provider-specific scope or location identifier for the file
  /// operation.
  ///
  /// Remarks: Some providers use scoped storage for files. For example, OpenAI
  /// uses containers to scope code interpreter files. If specified, the
  /// operation will target files within the specified scope.
  String? scope;

  /// Gets or sets the purpose of a file.
  ///
  /// Remarks: For creation operations, this typically indicates the intended
  /// use of the file being created, which may influence how the provider
  /// processes or validates the file. For listing operations, this typically
  /// filters the returned files to those matching the specified purpose. If not
  /// specified, implementations may default to a provider-specific value
  /// (typically "assistants" or equivalent for code interpreter use). Common
  /// values include "assistants", "fine-tune", "batch", and "vision", but the
  /// specific values supported depend on the provider.
  String? purpose;

  /// Gets or sets the maximum number of files to return in a list operation.
  ///
  /// Remarks: If not specified, the provider's default limit will be used.
  int? limit;

  /// Gets or sets a callback responsible for creating the raw representation of
  /// the file operation options from an underlying implementation.
  ///
  /// Remarks: The underlying [HostedFileClient] implementation may have its own
  /// representation of options. When an operation is invoked with a
  /// [HostedFileClientOptions], that implementation may convert the provided
  /// options into its own representation in order to use it while performing
  /// the operation. For situations where a consumer knows which concrete
  /// [HostedFileClient] is being used and how it represents options, a new
  /// instance of that implementation-specific options type may be returned by
  /// this callback, for the [HostedFileClient] implementation to use instead of
  /// creating a new instance. Such implementations may mutate the supplied
  /// options instance further based on other settings supplied on this
  /// [HostedFileClientOptions] instance or from other inputs, therefore, it is
  /// strongly recommended to not return shared instances and instead make the
  /// callback return a new instance on each call. This is typically used to set
  /// an implementation-specific setting that isn't otherwise exposed from the
  /// strongly typed properties on [HostedFileClientOptions].
  Func<HostedFileClient, Object?>? rawRepresentationFactory;

  /// Gets or sets additional properties for the request.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Creates a shallow clone of the current [HostedFileClientOptions] instance.
  ///
  /// Returns: A shallow clone of the current [HostedFileClientOptions]
  /// instance.
  HostedFileClientOptions clone() {
    return new(this);
  }
}
