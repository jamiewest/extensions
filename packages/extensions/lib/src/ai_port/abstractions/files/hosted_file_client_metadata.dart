import 'hosted_file_client.dart';

/// Provides metadata about an [HostedFileClient].
class HostedFileClientMetadata {
  /// Initializes a new instance of the [HostedFileClientMetadata] class.
  ///
  /// [providerName] The name of the file client provider, if applicable.
  ///
  /// [providerUri] The URI of the provider's endpoint, if applicable.
  HostedFileClientMetadata({
    String? providerName = null,
    Uri? providerUri = null,
  }) : providerName = providerName,
       providerUri = providerUri;

  /// Gets the name of the file client provider.
  ///
  /// Remarks: Where possible, this maps to the name of the company or
  /// organization that provides the underlying file storage, such as "openai",
  /// "anthropic", or "google".
  final String? providerName;

  /// Gets the URI of the provider's endpoint.
  final Uri? providerUri;
}
