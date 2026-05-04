import '../contents/hosted_file_content.dart';
import 'hosted_file_client.dart';
import 'hosted_file_client_options.dart';
import 'hosted_file_download_stream.dart';

/// A delegating file client that wraps an inner [HostedFileClient].
///
/// Remarks: This class provides a base for creating file clients that modify
/// or enhance the behavior of another [HostedFileClient]. By default, all
/// methods delegate to the inner client.
class DelegatingHostedFileClient implements HostedFileClient {
  /// Initializes a new instance of the [DelegatingHostedFileClient] class.
  ///
  /// [innerClient] The inner client to delegate to.
  const DelegatingHostedFileClient(HostedFileClient innerClient)
    : innerClient = Throw.ifNull(innerClient);

  /// Gets the inner [HostedFileClient].
  final HostedFileClient innerClient;

  @override
  Future<HostedFileContent> upload(
    Stream content, {
    String? mediaType,
    String? fileName,
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) {
    return innerClient.uploadAsync(
      content,
      mediaType,
      fileName,
      options,
      cancellationToken,
    );
  }

  @override
  Future<HostedFileDownloadStream> download(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) {
    return innerClient.downloadAsync(fileId, options, cancellationToken);
  }

  @override
  Future<HostedFileContent?> getFileInfo(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) {
    return innerClient.getFileInfoAsync(fileId, options, cancellationToken);
  }

  @override
  Stream<HostedFileContent> listFiles({
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) {
    return innerClient.listFilesAsync(options, cancellationToken);
  }

  @override
  Future<bool> delete(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) {
    return innerClient.deleteAsync(fileId, options, cancellationToken);
  }

  @override
  Object? getService(Type serviceType, {Object? serviceKey}) {
    _ = Throw.ifNull(serviceType);
    return serviceKey == null && serviceType.isInstanceOfType(this)
        ? this
        : innerClient.getService(serviceType, serviceKey);
  }

  /// Disposes the instance.
  ///
  /// [disposing] `true` if being called from [Dispose]; otherwise, `false`.
  @override
  void dispose({bool? disposing}) {
    if (disposing) {
      innerClient.dispose();
    }
  }
}
