import '../contents/data_content.dart';
import '../contents/hosted_file_content.dart';
import 'hosted_file_client.dart';
import 'hosted_file_client_metadata.dart';
import 'hosted_file_client_options.dart';
import 'hosted_file_download_stream.dart';

/// Extension methods for [HostedFileClient].
extension HostedFileClientExtensions on HostedFileClient {
  /// Uploads content from a [DataContent].
///
/// Returns: Information about the uploaded file.
///
/// [client] The file client.
///
/// [content] The content to upload.
///
/// [options] Options to configure the upload.
///
/// [cancellationToken] The [CancellationToken] to monitor for cancellation
/// requests.
Future<HostedFileContent> upload(
  HostedFileClientOptions? options,
  CancellationToken cancellationToken,
  {DataContent? content, String? filePath, },
) async  {
_ = Throw.ifNull(client);
_ = Throw.ifNull(content);
var stream = MemoryMarshal.tryGetArray(content.data, out ArraySegment<byte> arraySegment) ?
            new(arraySegment.array!, arraySegment.offset, arraySegment.count) :
            new(content.data.toArray());
return client.uploadAsync(stream, content.mediaType, content.name, options, cancellationToken);
 }
/// Downloads a file and saves it to a local path.
///
/// Returns: The actual path where the file was saved.
///
/// [client] The file client.
///
/// [fileId] The ID of the file to download.
///
/// [destinationPath] The path to save the file to. If the path is a directory
/// or empty, the file name will be inferred. An empty path is treated as the
/// current directory.
///
/// [options] Options to configure the download.
///
/// [cancellationToken] The [CancellationToken] to monitor for cancellation
/// requests.
Future<String> downloadTo(
  String fileId,
  String destinationPath,
  {HostedFileClientOptions? options, CancellationToken? cancellationToken, },
) async  {
_ = Throw.ifNull(client);
_ = Throw.ifNullOrWhitespace(fileId);
_ = Throw.ifNull(destinationPath);
var downloadStream = await client.downloadAsync(
  fileId,
  options,
  cancellationToken,
) .configureAwait(false);
var finalPath = destinationPath;
if (destinationPath.length == 0 || Directory.exists(destinationPath)) {
  var fileName = null;
  if (downloadStream.fileName != null) {
    fileName = Path.getFileName(downloadStream.fileName);
  }

  if (string.isNullOrEmpty(fileName)) {
    fileName = '${fileId}${MediaTypeMap.getExtension(downloadStream.mediaType)}';
  }

  finalPath = destinationPath.length == 0 ? fileName! : Path.combine(destinationPath, fileName);
}
var fileStream = new(
            finalPath, FileMode.createNew, FileAccess.write, FileShare.read,
            bufferSize: 1, // buffering in FileStream is a nop as CopyToAsync will use its own, larger buffer
            useAsync: true);
await downloadStream.copyToAsync(fileStream,
#if !NET
            81920,
#endif
            cancellationToken).configureAwait(false);
return finalPath;
 }
/// Downloads a file referenced by a [HostedFileContent].
///
/// Returns: A [HostedFileDownloadStream] containing the file content.
///
/// [client] The file client.
///
/// [hostedFile] The hosted file reference.
///
/// [options] Options to configure the download.
///
/// [cancellationToken] The [CancellationToken] to monitor for cancellation
/// requests.
Future<HostedFileDownloadStream> download(
  HostedFileContent hostedFile,
  {HostedFileClientOptions? options, CancellationToken? cancellationToken, },
) {
_ = Throw.ifNull(client);
_ = Throw.ifNull(hostedFile);
if (hostedFile.scope is string scope && options?.scope == null) {
  options = options?.clone() ?? new();
  options.scope = scope;
}
return client.downloadAsync(hostedFile.fileId, options, cancellationToken);
 }
/// Downloads a file and returns its content as a buffered [DataContent].
///
/// Remarks: This method buffers the entire file content into memory. For
/// large files, consider using [CancellationToken)] and streaming directly to
/// the destination.
///
/// Returns: The file content as a [DataContent].
///
/// [client] The file client.
///
/// [fileId] The ID of the file to download.
///
/// [options] Options to configure the download.
///
/// [cancellationToken] The [CancellationToken] to monitor for cancellation
/// requests.
Future<DataContent> downloadAsDataContent(
  String fileId,
  {HostedFileClientOptions? options, CancellationToken? cancellationToken, },
) async  {
_ = Throw.ifNull(client);
_ = Throw.ifNullOrWhitespace(fileId);
var downloadStream = await client.downloadAsync(
  fileId,
  options,
  cancellationToken,
) .configureAwait(false);
return await downloadStream.toDataContentAsync(cancellationToken).configureAwait(false);
 }
/// Gets the [HostedFileClientMetadata] for this client.
///
/// Returns: The metadata for this client, or `null` if not available.
///
/// [client] The file client.
HostedFileClientMetadata? getMetadata() {
_ = Throw.ifNull(client);
return client.getService(typeof(HostedFileClientMetadata)) as HostedFileClientMetadata;
 }
/// Gets a service of the specified type from the file client.
///
/// Returns: The found service, or `null` if not available.
///
/// [client] The file client.
///
/// [serviceKey] An optional key that can be used to help identify the target
/// service.
///
/// [TService] The type of service to retrieve.
TService? getService<TService>({Object? serviceKey}) {
_ = Throw.ifNull(client);
return client.getService(typeof(TService), serviceKey) is TService service ? service : default;
 }
/// Asks the [HostedFileClient] for an object of the specified type
/// `serviceType` and throws an exception if one isn't available.
///
/// Remarks: The purpose of this method is to allow for the retrieval of
/// services that are required to be provided by the [HostedFileClient],
/// including itself or any services it might be wrapping.
///
/// Returns: The found object.
///
/// [client] The file client.
///
/// [serviceType] The type of object being requested.
///
/// [serviceKey] An optional key that can be used to help identify the target
/// service.
Object getRequiredService(Object? serviceKey, {Type? serviceType, }) {
_ = Throw.ifNull(client);
_ = Throw.ifNull(serviceType);
return client.getService(serviceType, serviceKey) ??
            throw Throw.createMissingServiceException(serviceType, serviceKey);
 }
 }
