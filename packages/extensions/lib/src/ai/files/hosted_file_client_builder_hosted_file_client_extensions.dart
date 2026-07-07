import 'hosted_file_client.dart';
import 'hosted_file_client_builder.dart';

/// Provides extension methods for working with [HostedFileClient] in the
/// context of [HostedFileClientBuilder].
///
/// This is an experimental feature.
extension HostedFileClientBuilderHostedFileClientExtensions
    on HostedFileClient {
  /// Creates a new [HostedFileClientBuilder] using this client as its
  /// inner client.
  HostedFileClientBuilder asBuilder() => HostedFileClientBuilder(this);
}
