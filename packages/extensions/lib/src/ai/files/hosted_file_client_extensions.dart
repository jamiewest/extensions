import 'dart:typed_data';

import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import '../data_content.dart';
import '../hosted_file_content.dart';
import 'hosted_file_client.dart';

/// Convenience operations for [HostedFileClient].
///
/// Divergences from upstream, all deliberate:
///
/// * `DownloadToAsync` (write to a filesystem path) is not ported — the AI
///   abstractions avoid `dart:io`; pipe [HostedFileClient.download] into a
///   sink instead.
/// * `HostedFileDownloadStream` is not ported — [HostedFileClient.download]
///   returns a plain byte stream, and the file's media type and name come
///   from [HostedFileClient.getFile] rather than riding on the stream.
/// * Upstream's scope propagation is inert here: neither
///   [HostedFileClientOptions] nor [HostedFileContent] carries a scope in
///   this port.
///
/// This is an experimental feature.
@Source(
  name: 'HostedFileClientExtensions.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Files/',
)
extension HostedFileClientExtensions on HostedFileClient {
  /// Uploads the bytes carried by [content].
  ///
  /// The media type and name are taken from [content] unless overridden by
  /// [fileName]. Throws [ArgumentError] when the content carries no
  /// in-memory data (for example, a URI-only [DataContent]).
  Future<HostedFileContent> uploadDataContent(
    DataContent content, {
    String? fileName,
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) {
    final data = content.data;
    if (data == null) {
      throw ArgumentError.value(
        content,
        'content',
        'The DataContent must carry in-memory data.',
      );
    }
    return upload(
      Stream.value(data),
      mediaType: content.mediaType,
      fileName: fileName ?? content.name,
      options: options,
      cancellationToken: cancellationToken,
    );
  }

  /// Downloads the file referenced by [hostedFile].
  Stream<List<int>> downloadFromContent(
    HostedFileContent hostedFile, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) => download(
    hostedFile.fileId,
    options: options,
    cancellationToken: cancellationToken,
  );

  /// Downloads the file with [fileId] fully into memory as a [DataContent].
  ///
  /// The media type and name are looked up via [HostedFileClient.getFile];
  /// the media type falls back to `application/octet-stream` when the
  /// service reports none.
  Future<DataContent> downloadAsDataContent(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final metadata = await getFile(
      fileId,
      options: options,
      cancellationToken: cancellationToken,
    );
    final builder = BytesBuilder(copy: false);
    await for (final chunk in download(
      fileId,
      options: options,
      cancellationToken: cancellationToken,
    )) {
      builder.add(chunk);
    }
    return DataContent(
      builder.takeBytes(),
      mediaType: metadata?.mediaType ?? 'application/octet-stream',
      name: metadata?.name,
    );
  }

  /// Gets the [HostedFileClientMetadata] exposed by this client, if any.
  HostedFileClientMetadata? getMetadata() =>
      getService<HostedFileClientMetadata>();
}
