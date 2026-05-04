import '../../open_telemetry_consts.dart';
import 'ai_content.dart';

/// Represents an error.
///
/// Remarks: Typically, [ErrorContent] is used for non-fatal errors, where
/// something went wrong as part of the operation but the operation was still
/// able to continue.
class ErrorContent extends AContent {
  /// Initializes a new instance of the [ErrorContent] class with the specified
  /// error message.
  ///
  /// [message] The error message to store in this content.
  const ErrorContent(String? message) : message = message;

  /// Gets or sets the error message.
  String message;

  /// Gets or sets an error code associated with the error.
  String? errorCode;

  /// Gets or sets additional details about the error.
  String? details;

  /// Gets a string representing this instance to display in the debugger.
  String get debuggerDisplay {
    return 'Error = \"${message}\"' +
        (!string.isNullOrWhiteSpace(errorCode)
            ? ' (${errorCode})'
            : string.empty) +
        (!string.isNullOrWhiteSpace(details)
            ? ' - \"${details}\"'
            : string.empty);
  }
}
