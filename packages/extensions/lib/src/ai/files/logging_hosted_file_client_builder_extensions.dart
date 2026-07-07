import 'hosted_file_client_builder.dart';
import 'logging_hosted_file_client.dart';

/// Provides extensions for adding [LoggingHostedFileClient] to a
/// [HostedFileClientBuilder] pipeline.
///
/// This is an experimental feature.
extension LoggingHostedFileClientBuilderExtensions on HostedFileClientBuilder {
  /// Adds logging around hosted file operations.
  HostedFileClientBuilder useLogging({String? loggerName}) =>
      use((inner) => LoggingHostedFileClient(inner, loggerName: loggerName));
}
