import 'dart:developer' as developer;

import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import '../hosted_file_content.dart';
import 'delegating_hosted_file_client.dart';
import 'hosted_file_client.dart';

/// A [DelegatingHostedFileClient] that logs file operations.
///
/// This is an experimental feature.
@Source(
  name: 'LoggingHostedFileClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/Files/',
)
class LoggingHostedFileClient extends DelegatingHostedFileClient {
  /// Creates a new [LoggingHostedFileClient].
  LoggingHostedFileClient(super.innerClient, {String? loggerName})
      : _loggerName = loggerName ?? 'HostedFileClient';

  final String _loggerName;

  @override
  Future<HostedFileContent> upload(
    Stream<List<int>> content, {
    String? mediaType,
    String? fileName,
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    developer.log('Upload invoked: $fileName', name: _loggerName, level: 500);
    final result = await super.upload(
      content,
      mediaType: mediaType,
      fileName: fileName,
      options: options,
      cancellationToken: cancellationToken,
    );
    developer.log('Upload succeeded: ${result.fileId}', name: _loggerName, level: 500);
    return result;
  }

  @override
  Future<bool> delete(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    developer.log('Delete invoked: $fileId', name: _loggerName, level: 500);
    final result = await super.delete(fileId, options: options, cancellationToken: cancellationToken);
    developer.log('Delete result: $result', name: _loggerName, level: 500);
    return result;
  }
}
