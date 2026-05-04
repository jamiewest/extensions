import '../contents/hosted_file_content.dart';
import 'hosted_file_client_metadata.dart';
import 'hosted_file_client_options.dart';
import 'hosted_file_download_stream.dart';

/// Represents a client for uploading, downloading, and managing files hosted
/// by an AI service.
///
/// Remarks: File clients enable interaction with server-side file storage
/// used by AI services, particularly for code interpreter inputs and outputs.
/// Files uploaded through this interface can be referenced in AI requests
/// using [HostedFileContent]. Unless otherwise specified, all members of
/// [HostedFileClient] are thread-safe for concurrent use. It is expected that
/// all implementations of [HostedFileClient] support being used by multiple
/// requests concurrently. Instances must not be disposed of while the
/// instance is still in use.
abstract class HostedFileClient implements Disposable {
  /// Uploads a file to the AI service.
  ///
  /// Returns: Information about the uploaded file.
  ///
  /// [content] The stream containing the file content to upload.
  ///
  /// [mediaType] The media type (MIME type) of the content.
  ///
  /// [fileName] The name of the file.
  ///
  /// [options] Options to configure the upload.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests. The default is [None].
  Future<HostedFileContent> upload(
    Stream content, {
    String? mediaType,
    String? fileName,
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Downloads a file from the AI service.
  ///
  /// Returns: A [HostedFileDownloadStream] containing the file content. The
  /// stream should be disposed when no longer needed.
  ///
  /// [fileId] The ID of the file to download.
  ///
  /// [options] Options to configure the download.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests. The default is [None].
  Future<HostedFileDownloadStream> download(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Gets metadata about a file.
  ///
  /// Returns: Information about the file, or `null` if not found.
  ///
  /// [fileId] The ID of the file.
  ///
  /// [options] Options to configure the request.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests. The default is [None].
  Future<HostedFileContent?> getFileInfo(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Lists files accessible by this client.
  ///
  /// Returns: An async enumerable of file information.
  ///
  /// [options] Options to configure the listing.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests. The default is [None].
  Stream<HostedFileContent> listFiles({
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Deletes a file from the AI service.
  ///
  /// Returns: `true` if the file was deleted; `false` if the file was not
  /// found.
  ///
  /// [fileId] The ID of the file to delete.
  ///
  /// [options] Options to configure the request.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests. The default is [None].
  Future<bool> delete(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Asks the [HostedFileClient] for an object of the specified type
  /// `serviceType`.
  ///
  /// Remarks: The purpose of this method is to allow for the retrieval of
  /// strongly typed services that might be provided by the [HostedFileClient],
  /// including itself or any services it might be wrapping. For example, to
  /// access the [HostedFileClientMetadata] for the instance, [Object)] may be
  /// used to request it.
  ///
  /// Returns: The found object, otherwise `null`.
  ///
  /// [serviceType] The type of object being requested.
  ///
  /// [serviceKey] An optional key that can be used to help identify the target
  /// service.
  Object? getService(Type serviceType, {Object? serviceKey});
}
