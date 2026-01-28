import 'ai_content.dart';

/// Represents error content in a chat response.
class ErrorContent extends AIContent {
  /// Creates a new [ErrorContent] with the given [message].
  ErrorContent(this.message, {this.errorCode, this.details});

  /// The error message.
  final String message;

  /// An optional error code.
  final String? errorCode;

  /// Additional error details.
  final String? details;

  @override
  String toString() => message;
}
