import '../../../logging.dart';
import '../../../options.dart';
import '../http_client_factory_options.dart';
import '../http_client_factory_service_collection_extensions.dart';
import '../http_message_handler_builder.dart';
import '../http_message_handler_builder_filter.dart';
import 'logging_http_message_handler.dart';

/// A filter that adds a [LoggingHttpMessageHandler] to the HTTP client
/// pipeline for all named clients.
///
/// This filter is automatically registered when using
/// [HttpClientFactoryServiceCollectionExtensions.addHttpClient].
class LoggingHttpMessageHandlerBuilderFilter
    extends HttpMessageHandlerBuilderFilter {
  /// Creates a new [LoggingHttpMessageHandlerBuilderFilter].
  LoggingHttpMessageHandlerBuilderFilter(
    this._loggerFactory,
    this._optionsMonitor,
  );

  final LoggerFactory _loggerFactory;
  final OptionsMonitor<HttpClientFactoryOptions> _optionsMonitor;

  @override
  void configure(
    void Function(HttpMessageHandlerBuilder) next,
    HttpMessageHandlerBuilder builder,
  ) {
    // Call the next filter in the pipeline
    next(builder);

    // Get options for this named client
    final name = builder.name ?? Options.defaultName;
    final options = _optionsMonitor.get(name);

    // Skip logging if suppressed
    if (options.suppressDefaultLogging) {
      return;
    }

    // Create logger for this HTTP client
    final logger = _loggerFactory.createLogger(
      'System.Net.Http.HttpClient.$name.LogicalHandler',
    );

    // Add logging handler to the pipeline
    final loggingHandler = LoggingHttpMessageHandler(
      logger: logger,
      shouldRedactHeaderValue: options.shouldRedactHeaderValue,
    );

    builder.additionalHandlers.add(loggingHandler);
  }
}
