import 'dart:async';

import '../../dependency_injection/service_provider.dart';
import '../../system/threading/cancellation_token.dart';
import '../empty_service_provider.dart';
import 'anonymous_delegating_chat_client.dart';
import 'chat_client.dart';
import 'chat_client_builder_service_collection_extensions.dart';
import 'chat_message.dart';
import 'chat_options.dart';
import 'chat_response.dart';
import 'chat_response_extensions.dart';
import 'chat_response_update.dart';

/// A factory that creates middleware by wrapping an inner [ChatClient].
typedef ChatClientFactory = ChatClient Function(ChatClient innerClient);

/// A factory that creates middleware by wrapping an inner [ChatClient] and
/// receiving the active [ServiceProvider].
typedef ChatClientFactoryWithServices = ChatClient Function(
  ChatClient innerClient,
  ServiceProvider services,
);

/// Delegate used to wrap both non-streaming and streaming operations.
///
/// The [next] callback must be invoked to run the inner client operation.
typedef ChatClientSharedDelegate = Future<void> Function(
  Iterable<ChatMessage> messages,
  ChatOptions? options,
  Future<void> Function(
    Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  )
  next,
  CancellationToken? cancellationToken,
);

/// Builds a pipeline of chat client middleware.
///
/// The pipeline is composed by calling [use], [useWithServices],
/// [useShared], or [useDelegates] one or more times, then calling [build]
/// to produce the final [ChatClient]. Middleware factories are applied in
/// reverse order so that the first call adds the outermost wrapper.
class ChatClientBuilder {
  late final InnerClientFactory _innerClientFactory;

  /// The registered middleware factory instances.
  List<ChatClientFactoryWithServices>? _clientFactories;

  ChatClientBuilder._(InnerClientFactory innerClientFactory)
    : _innerClientFactory = innerClientFactory;

  /// Creates a new [ChatClientBuilder] wrapping [innerClient].
  ChatClientBuilder(ChatClient innerClient) {
    _innerClientFactory = (_) => innerClient;
  }

  /// Creates a new [ChatClientBuilder] from a factory function.
  factory ChatClientBuilder.fromFactory(
    InnerClientFactory innerClientFactory,
  ) => ChatClientBuilder._(innerClientFactory);

  /// Adds a middleware factory to the pipeline.
  ///
  /// This corresponds to the single-parameter `Use` overload in .NET.
  ChatClientBuilder use(ChatClientFactory clientFactory) {
    ArgumentError.checkNotNull(clientFactory, 'clientFactory');
    return useWithServices((innerClient, _) => clientFactory(innerClient));
  }

  /// Adds a middleware factory to the pipeline.
  ///
  /// This corresponds to the `Use` overload that receives
  /// `IServiceProvider` in .NET.
  ChatClientBuilder useWithServices(
    ChatClientFactoryWithServices clientFactory,
  ) {
    ArgumentError.checkNotNull(clientFactory, 'clientFactory');

    (_clientFactories ??= <ChatClientFactoryWithServices>[]).add(clientFactory);
    return this;
  }

  /// Adds an anonymous delegating middleware that wraps both operations with
  /// a shared callback.
  ChatClientBuilder useShared(ChatClientSharedDelegate sharedFunc) {
    ArgumentError.checkNotNull(sharedFunc, 'sharedFunc');

    return useWithServices(
      (innerClient, _) => AnonymousDelegatingChatClient(
        innerClient,
        responseHandler: (messages, options, inner, cancellationToken) async {
          ChatResponse? response;

          await sharedFunc(messages, options, (
            nextMessages,
            nextOptions,
            nextCancellationToken,
          ) async {
            response = await inner.getResponse(
              messages: nextMessages,
              options: nextOptions,
              cancellationToken: nextCancellationToken,
            );
          }, cancellationToken);

          final result = response;
          if (result == null) {
            throw StateError(
              'The wrapper completed successfully without producing '
              'a ChatResponse.',
            );
          }

          return result;
        },
        streamingResponseHandler:
            (messages, options, inner, cancellationToken) {
              final controller = StreamController<ChatResponseUpdate>();

              Future<void>(() async {
                Object? error;
                StackTrace? stackTrace;

                try {
                  await sharedFunc(messages, options, (
                    nextMessages,
                    nextOptions,
                    nextCancellationToken,
                  ) async {
                    await for (final update in inner.getStreamingResponse(
                      messages: nextMessages,
                      options: nextOptions,
                      cancellationToken: nextCancellationToken,
                    )) {
                      controller.add(update);
                    }
                  }, cancellationToken);
                } catch (e, st) {
                  error = e;
                  stackTrace = st;
                } finally {
                  if (error != null) {
                    controller.addError(error, stackTrace);
                  }
                  await controller.close();
                }
              });

              return controller.stream;
            },
      ),
    );
  }

  /// Adds an anonymous delegating middleware based on one or both delegates.
  ///
  /// If only [getResponseFunc] is supplied, it is used for streaming via
  /// [ChatResponse.toChatResponseUpdates].
  /// If only [getStreamingResponseFunc] is supplied, it is used for
  /// non-streaming via conversion to a [ChatResponse].
  ChatClientBuilder useDelegates(
    ChatClientResponseHandler? getResponseFunc,
    ChatClientStreamingResponseHandler? getStreamingResponseFunc,
  ) {
    if (getResponseFunc == null && getStreamingResponseFunc == null) {
      throw ArgumentError(
        'At least one of getResponseFunc or getStreamingResponseFunc '
        'must be non-null.',
      );
    }

    final responseHandler =
        getResponseFunc ??
        (messages, options, innerClient, cancellationToken) =>
            getStreamingResponseFunc!(
              messages,
              options,
              innerClient,
              cancellationToken,
            ).toChatResponse();

    final streamingHandler =
        getStreamingResponseFunc ??
        (messages, options, innerClient, cancellationToken) async* {
          final response = await getResponseFunc!(
            messages,
            options,
            innerClient,
            cancellationToken,
          );

          for (final update in response.toChatResponseUpdates()) {
            yield update;
          }
        };

    return useWithServices(
      (innerClient, _) => AnonymousDelegatingChatClient(
        innerClient,
        responseHandler: responseHandler,
        streamingResponseHandler: streamingHandler,
      ),
    );
  }

  /// Builds the pipeline and returns the outermost [ChatClient].
  ChatClient build([ServiceProvider? services]) {
    services ??= EmptyServiceProvider.instance;
    var chatClient = _innerClientFactory(services);

    final clientFactories = _clientFactories;
    if (clientFactories != null) {
      for (var i = clientFactories.length - 1; i >= 0; i--) {
        chatClient = clientFactories[i](chatClient, services);
      }
    }

    return chatClient;
  }
}
