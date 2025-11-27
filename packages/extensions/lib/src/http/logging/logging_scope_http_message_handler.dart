import 'package:http/http.dart';

import '../../../http.dart';
import '../../../logging.dart';

/// A delegating handler that establishes a logging scope for each HTTP request.
///
/// This handler creates a logging scope that includes the HTTP method and URI,
/// making it available to all loggers within the scope of the request.
///
/// The scope is automatically disposed when the request completes or fails.
class LoggingScopeHttpMessageHandler extends DelegatingHandler {
  /// Creates a new [LoggingScopeHttpMessageHandler] with the specified logger.
  LoggingScopeHttpMessageHandler({
    required this.logger,
    HttpMessageHandler? innerHandler,
  }) : super(innerHandler);

  /// The logger used for establishing the logging scope.
  final Logger logger;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final scope = logger.beginScope({
      'Method': request.method,
      'Uri': request.url.toString(),
    });

    try {
      return await super.send(request);
    } finally {
      scope?.dispose();
    }
  }
}
