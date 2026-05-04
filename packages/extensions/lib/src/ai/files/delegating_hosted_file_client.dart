import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import '../hosted_file_content.dart';
import 'hosted_file_client.dart';

/// A [HostedFileClient] that delegates all calls to an inner client.
///
/// Subclass this to build middleware that wraps specific methods while
/// delegating others.
///
/// This is an experimental feature.
@Source(
  name: 'DelegatingHostedFileClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Files/',
)
class DelegatingHostedFileClient implements HostedFileClient {
  /// Creates a new [DelegatingHostedFileClient] wrapping [innerClient].
  DelegatingHostedFileClient(this.innerClient);

  /// The inner client to delegate to.
  final HostedFileClient innerClient;

  @override
  Future<HostedFileContent> upload(
    Stream<List<int>> content, {
    String? mediaType,
    String? fileName,
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      innerClient.upload(
        content,
        mediaType: mediaType,
        fileName: fileName,
        options: options,
        cancellationToken: cancellationToken,
      );

  @override
  Stream<List<int>> download(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      innerClient.download(
        fileId,
        options: options,
        cancellationToken: cancellationToken,
      );

  @override
  Future<HostedFileContent?> getFile(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      innerClient.getFile(
        fileId,
        options: options,
        cancellationToken: cancellationToken,
      );

  @override
  Stream<HostedFileContent> listFiles({
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      innerClient.listFiles(
        options: options,
        cancellationToken: cancellationToken,
      );

  @override
  Future<bool> delete(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      innerClient.delete(
        fileId,
        options: options,
        cancellationToken: cancellationToken,
      );

  @override
  T? getService<T>({Object? key}) {
    if (this is T) return this as T;
    return innerClient.getService<T>(key: key);
  }

  @override
  void dispose() => innerClient.dispose();
}
