import '../abstractions/files/hosted_file_client.dart';
import 'hosted_file_client_builder.dart';

/// Provides extension methods for working with [HostedFileClient] in the
/// context of [HostedFileClientBuilder].
extension HostedFileClientBuilderHostedFileClientExtensions
    on HostedFileClient {
  /// Creates a new [HostedFileClientBuilder] using `innerClient` as its inner
  /// client.
  ///
  /// Remarks: This method is equivalent to using the [HostedFileClientBuilder]
  /// constructor directly, specifying `innerClient` as the inner client.
  ///
  /// Returns: The new [HostedFileClientBuilder] instance.
  ///
  /// [innerClient] The client to use as the inner client.
  HostedFileClientBuilder asBuilder() {
    _ = Throw.ifNull(innerClient);
    return hostedFileClientBuilder(innerClient);
  }
}
