import 'package:extensions/annotations.dart';

import '../../system/disposable.dart';
import '../../system/threading/cancellation_token.dart';
import '../additional_properties_dictionary.dart';
import '../hosted_file_content.dart';

/// Options for [HostedFileClient] requests.
///
/// This is an experimental feature.
@Source(
  name: 'HostedFileClientOptions.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Files/',
)
class HostedFileClientOptions {
  /// Creates a new [HostedFileClientOptions].
  const HostedFileClientOptions({this.additionalProperties});

  /// Additional properties.
  final AdditionalPropertiesDictionary? additionalProperties;
}

/// Provides metadata about a [HostedFileClient].
///
/// This is an experimental feature.
@Source(
  name: 'HostedFileClientMetadata.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Files/',
)
class HostedFileClientMetadata {
  /// Creates a new [HostedFileClientMetadata].
  const HostedFileClientMetadata({
    this.providerName,
    this.providerUri,
  });

  /// The name of the file storage provider.
  final String? providerName;

  /// The URL for accessing the provider.
  final Uri? providerUri;
}

/// A client for uploading, downloading, and managing files hosted by an AI
/// service.
///
/// Files uploaded through this interface can be referenced in AI requests
/// using [HostedFileContent].
///
/// This is an experimental feature.
@Source(
  name: 'IHostedFileClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Files/',
)
abstract class HostedFileClient implements Disposable {
  /// Uploads a file to the AI service.
  ///
  /// Returns a [HostedFileContent] with metadata about the uploaded file.
  Future<HostedFileContent> upload(
    Stream<List<int>> content, {
    String? mediaType,
    String? fileName,
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Downloads a file from the AI service as a byte stream.
  Stream<List<int>> download(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Gets metadata about a file, or `null` if not found.
  Future<HostedFileContent?> getFile(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Returns all files visible to this client.
  Stream<HostedFileContent> listFiles({
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Deletes a file. Returns `true` if deleted, `false` if not found.
  Future<bool> delete(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Gets a service of the specified type.
  T? getService<T>({Object? key}) => null;
}
