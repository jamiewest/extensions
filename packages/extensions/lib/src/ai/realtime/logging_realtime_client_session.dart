import 'dart:async';
import 'dart:convert';

import '../../logging/log_level.dart';
import '../../logging/logger.dart';
import '../../logging/logger_extensions.dart';
import '../../system/exceptions/operation_cancelled_exception.dart';
import '../../system/threading/cancellation_token.dart';
import 'realtime_client_message.dart';
import 'realtime_client_session.dart';
import 'realtime_server_message.dart';
import 'realtime_session_options.dart';

/// A [RealtimeClientSession] that logs operations to a [Logger].
///
/// This is an experimental feature.
class LoggingRealtimeClientSession implements RealtimeClientSession {
  /// Creates a new [LoggingRealtimeClientSession] wrapping [innerSession].
  LoggingRealtimeClientSession(
    this._innerSession, {
    required Logger logger,
  }) : _logger = logger;

  final RealtimeClientSession _innerSession;
  final Logger _logger;

  /// The [JsonEncoder] used to serialize log data.
  JsonEncoder jsonEncoder = const JsonEncoder.withIndent('  ');

  @override
  RealtimeSessionOptions? get options => _innerSession.options;

  @override
  Future<void> send(
    RealtimeClientMessage message, {
    CancellationToken? cancellationToken,
  }) async {
    if (_logger.isEnabled(LogLevel.debug)) {
      _logger.logDebug('send invoked.');
    }

    if (_logger.isEnabled(LogLevel.trace)) {
      _logger.logTrace('send invoked. Message: ${_loggable(message)}.');
    }

    try {
      await _innerSession.send(message, cancellationToken: cancellationToken);

      if (_logger.isEnabled(LogLevel.debug)) {
        _logger.logDebug('send completed.');
      }
    } on OperationCanceledException {
      if (_logger.isEnabled(LogLevel.debug)) {
        _logger.logDebug('send canceled.');
      }
      rethrow;
    } catch (e) {
      _logger.logError('send failed.', error: e);
      rethrow;
    }
  }

  @override
  Stream<RealtimeServerMessage> getStreamingResponse({
    CancellationToken? cancellationToken,
  }) {
    Stream<RealtimeServerMessage> streamFn() async* {
      if (_logger.isEnabled(LogLevel.debug)) {
        _logger.logDebug('getStreamingResponse invoked.');
      }

      try {
        await for (final message in _innerSession.getStreamingResponse(
          cancellationToken: cancellationToken,
        )) {
          if (_logger.isEnabled(LogLevel.trace)) {
            _logger.logTrace(
              'getStreamingResponse received message. '
              'Message: ${_loggable(message)}.',
            );
          }
          yield message;
        }

        if (_logger.isEnabled(LogLevel.debug)) {
          _logger.logDebug('getStreamingResponse completed.');
        }
      } on OperationCanceledException {
        if (_logger.isEnabled(LogLevel.debug)) {
          _logger.logDebug('getStreamingResponse canceled.');
        }
        rethrow;
      } catch (e) {
        _logger.logError('getStreamingResponse failed.', error: e);
        rethrow;
      }
    }

    return streamFn();
  }

  @override
  T? getService<T>({Object? key}) => _innerSession.getService<T>(key: key);

  @override
  Future<void> disposeAsync() => _innerSession.disposeAsync();

  String _loggable(Object message) {
    final Object? raw;
    final String? messageId;
    if (message is RealtimeClientMessage) {
      raw = message.rawRepresentation;
      messageId = message.messageId;
    } else if (message is RealtimeServerMessage) {
      raw = message.rawRepresentation;
      messageId = message.messageId;
    } else {
      raw = null;
      messageId = null;
    }

    final map = <String, Object?>{
      if (raw != null) 'content': raw is String ? raw : _asJson(raw),
      if (raw == null && messageId != null) 'messageId': messageId,
    };
    return _asJson(map);
  }

  String _asJson(Object? value) {
    try {
      return jsonEncoder.convert(value);
    } catch (_) {
      return value.toString();
    }
  }
}
