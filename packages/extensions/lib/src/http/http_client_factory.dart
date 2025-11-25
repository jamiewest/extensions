import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../options/options.dart';

/// A factory abstraction for a component that can create [http.BaseClient]
/// instances with custom configuration for a given logical name.
///
/// A default `HttpClientFactory` can be registered by calling
/// `HttpClientFactoryServiceCollectionExtensions.addHttpClient`.
/// The default factory is registered in the service collection as a
/// singleton.
abstract class HttpClientFactory {
  /// Creates and configures a [http.BaseClient] instance using the
  /// configuration that corresponds to the logical name specified
  /// by [name].
  ///
  /// Each call to [createClient] is guaranteed to return a new
  /// [http.BaseClient] instance. It is generally not necessary to dispose
  /// of the [BaseClient] as the [HttpClientFactory] tracks and disposes
  /// resources used by the [BaseClient].
  ///
  /// If no name is provided, the [BaseClient] will be configured using
  /// the default configuration.
  http.BaseClient createClient([String? name = Options.defaultName]);
}
